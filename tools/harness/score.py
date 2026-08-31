#!/usr/bin/env python3
"""Score one harness run for Kirigami platform-layer fidelity.

Reads a harness output directory (page*.json, page*.png, messages.json) and
prints a JSON verdict. With --reference, also scores semantic coverage against
a reference run produced by the Felgo platform layer.

Score is in [0, 1]; higher is better. Gates are reported separately and are
pass/fail: a run that trips a gate is invalid regardless of its score.
"""

import argparse
import json
import math
import pathlib
import re
import sys

# Weights sum to 1. The goal is not a pixel copy of Felgo: it is the same
# information and the same affordances, presented through native Kirigami
# controls. Semantic coverage measures the first half, nativeness the second,
# and neither alone is the target.
W_SEMANTIC = 0.35
W_NATIVE = 0.25
W_LAYOUT = 0.20
W_CONSOLE = 0.15
W_BRAND = 0.05

# Warnings the app cannot fix and that the fixture deliberately provokes:
# every network request is refused by design so the bundled data is used.
FIXTURE_NOISE = re.compile(
    r"Proxy connection refused|trying cache|Overpass endpoint|"
    r"all Overpass endpoints failed|Populating font family aliases"
)


def walk(node):
    yield node
    for child in node.get("children", []):
        yield from walk(child)


def semantic_tokens(tree):
    """User-visible strings plus interactive types, as a set.

    This is what "the port shows the same thing" means operationally: the same
    text reaches the screen and the same kinds of control are there to act on.
    """
    tokens = set()
    for node in walk(tree):
        if not node.get("visible") or node.get("opacity", 1) <= 0.01:
            continue
        text = node.get("text", "").strip()
        if text:
            tokens.add("t:" + " ".join(text.split()))
        type_name = node.get("type", "")
        if any(k in type_name for k in
               ("Button", "Switch", "Slider", "CheckBox", "TextField", "ItemDelegate")):
            tokens.add("c:%s@%d" % (type_name, node.get("y", 0) // 40))
    return tokens


def brand_score(png_path, palette):
    """Fraction of the brand palette actually present in the render.

    Catches a theme token silently resolving to a default (the green going
    grey) without demanding pixel identity with another toolkit.
    """
    try:
        from PIL import Image
    except ImportError:
        return None
    try:
        image = Image.open(png_path).convert("RGB")
    except Exception:
        return None
    seen = {c for _, c in image.getcolors(maxcolors=1 << 24) or []}
    hits = 0
    for target in palette:
        if any(abs(r - target[0]) + abs(g - target[1]) + abs(b - target[2]) <= 24
               for (r, g, b) in seen):
            hits += 1
    return hits / len(palette) if palette else None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("run", type=pathlib.Path, nargs="+",
                        help="one or more harness passes; results are unioned")
    parser.add_argument("--reference", type=pathlib.Path,
                        help="Felgo harness run to score semantic coverage against")
    parser.add_argument("--palette", default="97BF0F",
                        help="comma-separated brand hex colours")
    parser.add_argument("--qml", type=pathlib.Path,
                        default=pathlib.Path("components-platform/kirigami/qml"),
                        help="platform layer to score for Kirigami nativeness")
    args = parser.parse_args()

    # The app's startup is not bit-reproducible: async loads and lazy attached
    # pages mean a single pass samples a random subset of what can go wrong.
    # Union the passes so the score describes the app rather than the sampling.
    runs = args.run
    pages = sorted(runs[0].glob("page*.json"))
    if not pages:
        print(json.dumps({"error": "no page*.json in %s" % runs[0]}))
        return 2

    palette = [tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
               for h in (p.strip().lstrip("#") for p in args.palette.split(","))]

    per_page, gates = {}, {"render": True, "pages": len(pages), "qml_errors": 0}
    total_items = total_defects = 0
    distinct_defects = set()
    semantic_hits = semantic_total = 0
    brand_values = []

    for page_json in pages:
        name = page_json.name
        best_tree, best_items, best_defects, tag = {}, -1, [], None
        for run in runs:
            candidate = run / name
            if not candidate.exists():
                continue
            document = json.loads(candidate.read_text())
            tag = document["page"]
            tree = document.get("tree", {})
            items = list(walk(tree))
            defects = document.get("defects", [])
            for defect in defects:
                distinct_defects.add((tag, defect["kind"], defect["type"],
                                      defect.get("text", "")))
            # Most-loaded pass wins: a pass that sampled before the page
            # finished under-reports everything, including its defects.
            if len(items) > best_items:
                best_tree, best_items, best_defects = tree, len(items), defects
        if tag is None:
            continue
        tree, items = best_tree, range(best_items)
        total_items += best_items
        total_defects += len(best_defects)

        entry = {"items": best_items, "defects": len(best_defects)}

        png = runs[0] / (page_json.stem + ".png")
        if not png.exists():
            gates["render"] = False
        else:
            value = brand_score(png, palette)
            if value is not None:
                brand_values.append(value)
                entry["brand"] = round(value, 3)

        if args.reference:
            reference_json = args.reference / page_json.name
            if reference_json.exists():
                want = semantic_tokens(json.loads(reference_json.read_text()).get("tree", {}))
                got = semantic_tokens(tree)
                if want:
                    semantic_hits += len(want & got)
                    semantic_total += len(want)
                    entry["semantic"] = round(len(want & got) / len(want), 3)
                    entry["missing"] = sorted(want - got)[:10]

        per_page[tag] = entry

    messages = []
    for run in runs:
        messages_file = run / "messages.json"
        if messages_file.exists():
            messages += json.loads(messages_file.read_text()).get("messages", [])
    real = [m for m in messages if not FIXTURE_NOISE.search(m["text"])]
    errors = {m["text"].split("\n")[0] for m in real if m["type"] == "error"}
    # Distinct texts, not occurrences. The same ReferenceError fires once per
    # delegate, and how many delegates exist depends on scroll timing, so
    # counting occurrences measures the harness rather than the code.
    warnings = sorted({m["text"].split("\n")[0] for m in real if m["type"] == "warning"})
    gates["qml_errors"] = len(errors)

    # Components. Each is 0..1.
    # Distinct defect signatures, for the same reason: a clipped label in a
    # recycled delegate must not score differently because more rows happened
    # to be realised on this run.
    layout = math.exp(-len(distinct_defects) / 4.0)
    # A handful of warnings should hurt a lot; the tail should not dominate.
    console = math.exp(-len(warnings) / 4.0)
    brand = sum(brand_values) / len(brand_values) if brand_values else 1.0
    semantic = (semantic_hits / semantic_total) if semantic_total else None

    native = None
    if args.qml.is_dir():
        import subprocess
        tool = pathlib.Path(__file__).with_name("nativeness.py")
        result = subprocess.run(
            [sys.executable, str(tool), "--qml", str(args.qml), "--run", str(runs[0])],
            capture_output=True, text=True)
        if result.returncode == 0:
            native = json.loads(result.stdout)["nativeness"]

    measured = {
        "semantic": (W_SEMANTIC, semantic),
        "native": (W_NATIVE, native),
        "layout": (W_LAYOUT, layout),
        "console": (W_CONSOLE, console),
        "brand": (W_BRAND, brand),
    }
    # Renormalise over whatever is available so the number stays comparable
    # across iterations of the same setup. Without a Felgo reference run the
    # semantic term is simply absent.
    live = {k: (w, v) for k, (w, v) in measured.items() if v is not None}
    total_weight = sum(w for w, _ in live.values())
    score = sum(w * v for w, v in live.values()) / total_weight

    verdict = {
        "score": round(score, 4),
        "components": {
            "semantic": round(semantic, 4) if semantic is not None else None,
            "native": round(native, 4) if native is not None else None,
            "layout": round(layout, 4),
            "console": round(console, 4),
            "brand": round(brand, 4),
        },
        "counts": {
            "items": total_items,
            "defects": total_defects,
            "distinct_defects": len(distinct_defects),
            "warnings": len(warnings),
            "errors": len(errors),
        },
        "gates": gates,
        "passes": len(runs),
        "gates_pass": bool(gates["render"] and gates["qml_errors"] == 0),
        "pages": per_page,
        "top_warnings": [w[:140] for w in warnings[:8]],
    }
    print(json.dumps(verdict, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
