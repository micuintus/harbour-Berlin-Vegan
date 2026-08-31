#!/usr/bin/env python3
"""Score how *Kirigami-native* the platform layer is.

The port's goal is not to look like Felgo. It is to present the same information
and the same affordances through genuinely native Kirigami controls. Semantic
coverage measures the first half; this measures the second, and the two together
are what "faithful but not a pixel copy" means operationally.

Two independent signals:

  static  — the QML source: hardcoded sizes and colours instead of Kirigami.Units
            and Kirigami.Theme, hand-rolled Rectangle+MouseArea where a Control
            exists, and a forced QQuickStyle.
  runtime — the rendered item tree: what fraction of the interactive items the
            user actually touches are real QQC2/Kirigami types rather than bare
            QQuickRectangle/QQuickMouseArea.
"""

import argparse
import json
import math
import pathlib
import re
import sys

# Brand colours are legitimately hardcoded; they are the identity that must
# survive a restyle. Everything else should come from Kirigami.Theme.
BRAND_COLOURS = {"#97bf0f", "#ffffff", "#000000", "transparent"}

COLOUR = re.compile(r'"(#[0-9a-fA-F]{6,8})"')
# A bare number assigned to a geometry/typography property is a magic constant;
# Kirigami.Units.* or a binding is what we want to see instead.
MAGIC_SIZE = re.compile(
    r'^\s*(?:width|height|spacing|padding|topMargin|bottomMargin|leftMargin|'
    r'rightMargin|anchors\.margins|font\.pixelSize|font\.pointSize|radius|'
    r'implicitWidth|implicitHeight)\s*:\s*(\d+(?:\.\d+)?)\s*$',
    re.MULTILINE)

# Types that mean "we built a control by hand instead of using one".
HANDROLLED = re.compile(r'^\s*(MouseArea)\s*\{', re.MULTILINE)

# Whitelisting native types does not work: QQC2 and Kirigami types are declared
# in QML, so they arrive as bare names like "Switch" that are indistinguishable
# from ours. Detect the defect directly instead. A MouseArea is Qt Quick's
# gesture primitive; reaching for it to build something that behaves like a
# button means a Control was available and was not used.
HANDROLLED_RUNTIME = ("QQuickMouseArea",)
INTERACTIVE_HINT = ("Button", "Switch", "Slider", "CheckBox", "TextField",
                    "Delegate", "MouseArea")


def static_scan(qml_dir):
    findings = []
    for path in sorted(qml_dir.glob("*.qml")):
        source = path.read_text(encoding="utf-8", errors="replace")
        # Strip comments so documentation examples do not count as code.
        source = re.sub(r"//[^\n]*", "", source)
        source = re.sub(r"/\*.*?\*/", "", source, flags=re.S)

        # Theme.qml *is* the palette; literals are the point there. Everywhere
        # else a literal colour is a token that escaped the theme.
        if path.name != "Theme.qml":
            for match in COLOUR.finditer(source):
                if match.group(1).lower() not in BRAND_COLOURS:
                    findings.append((path.name, "hardcoded-colour", match.group(1)))
        for match in MAGIC_SIZE.finditer(source):
            value = float(match.group(1))
            # 0 and 1 are structural (hidden, hairline), not design decisions.
            if value > 1:
                findings.append((path.name, "magic-size", match.group(0).strip()))
        for match in HANDROLLED.finditer(source):
            findings.append((path.name, "handrolled-control", "MouseArea"))
    return findings


def walk(node):
    yield node
    for child in node.get("children", []):
        yield from walk(child)


def runtime_scan(run_dir):
    native = foreign = 0
    foreign_types = {}
    for page_json in sorted(run_dir.glob("page*.json")):
        tree = json.loads(page_json.read_text()).get("tree", {})
        for node in walk(tree):
            if not node.get("visible") or node.get("opacity", 1) <= 0.01:
                continue
            type_name = node.get("type", "")
            if not any(hint in type_name for hint in INTERACTIVE_HINT):
                continue
            if type_name in HANDROLLED_RUNTIME:
                foreign += 1
                foreign_types[type_name] = foreign_types.get(type_name, 0) + 1
            else:
                native += 1
    total = native + foreign
    return (native / total if total else None), foreign_types


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--qml", type=pathlib.Path,
                        default=pathlib.Path("components-platform/kirigami/qml"))
    parser.add_argument("--run", type=pathlib.Path,
                        help="harness output dir, for the runtime half")
    parser.add_argument("--main", type=pathlib.Path, default=pathlib.Path("src/main.cpp"))
    args = parser.parse_args()

    findings = static_scan(args.qml)
    counts = {}
    for _, kind, _ in findings:
        counts[kind] = counts.get(kind, 0) + 1

    forced_style = False
    if args.main.exists():
        forced_style = 'QQuickStyle::setStyle' in args.main.read_text(errors="replace")

    # Each class of violation is scored on its own curve so a pile of magic
    # numbers cannot drown out the single structural problem of a forced style.
    static_score = (
        0.40 * math.exp(-counts.get("magic-size", 0) / 25.0)
        + 0.25 * math.exp(-counts.get("hardcoded-colour", 0) / 8.0)
        + 0.20 * math.exp(-counts.get("handrolled-control", 0) / 5.0)
        + 0.15 * (0.0 if forced_style else 1.0)
    )

    runtime_score, foreign_types = (None, {})
    if args.run:
        runtime_score, foreign_types = runtime_scan(args.run)

    if runtime_score is None:
        nativeness = static_score
    else:
        nativeness = 0.5 * static_score + 0.5 * runtime_score

    print(json.dumps({
        "nativeness": round(nativeness, 4),
        "static": round(static_score, 4),
        "runtime": round(runtime_score, 4) if runtime_score is not None else None,
        "violations": counts,
        "forced_qquickstyle": forced_style,
        "foreign_interactive_types": dict(sorted(
            foreign_types.items(), key=lambda kv: -kv[1])[:8]),
        "worst_files": dict(sorted(
            {name: sum(1 for n, _, _ in findings if n == name)
             for name, _, _ in findings}.items(),
            key=lambda kv: -kv[1])[:6]),
    }, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
