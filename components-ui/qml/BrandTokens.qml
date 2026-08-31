pragma Singleton

import QtQuick

// Berlin-Vegan brand identity, independent of any platform toolkit.
//
// Platform layers own the chassis: navigation, gestures, safe areas, control
// behaviour, and the base unit a platform measures in. This file owns what the
// brand looks like, and it must read the same on Felgo, Kirigami and Silica.
// Sizes here are ratios, never pixels, so each Theme can scale them by its own
// platform base and stay native while staying recognisably Berlin-Vegan.
QtObject {

    // -- Identity -------------------------------------------------------------
    readonly property color green:      "#5F7F0C"   // AA on white, calmer than the fill
    readonly property color greenBright: "#97BF0F"  // the historical brand fill
    readonly property color greenSoft:  "#F1F5E6"   // tinted surface behind green

    // -- Veg categories, the primary filter axis ------------------------------
    readonly property color vegan:      "#6B8F0E"
    readonly property color vegetarian: "#B87500"
    readonly property color omnivore:   "#C2453B"

    // -- Neutrals -------------------------------------------------------------
    readonly property color ink:        "#1A1D19"   // primary text
    readonly property color inkMuted:   "#5F6560"   // secondary text
    readonly property color inkFaint:   "#8E948F"   // tertiary / disabled
    readonly property color hairline:   "#E3E6E1"
    readonly property color surface:    "#FFFFFF"
    readonly property color canvas:     "#F6F7F4"   // page behind cards

    // -- Semantic -------------------------------------------------------------
    readonly property color warning:    "#C2453B"
    readonly property color success:    "#7CA511"

    // -- Type scale -----------------------------------------------------------
    // One ratio, five steps. Platforms supply the body size; every other step
    // derives from it, so hierarchy is identical everywhere while absolute
    // sizes stay native.
    readonly property real  typeRatio:   1.25
    readonly property int   weightNormal: Font.Normal
    readonly property int   weightMedium: Font.DemiBold

    function caption(body)  { return Math.round(body / typeRatio) }
    function title(body)    { return Math.round(body * typeRatio) }
    function headline(body) { return Math.round(body * typeRatio * typeRatio) }

    // -- Shape ----------------------------------------------------------------
    // Multiples of the platform base unit, not pixels. Radii stay small and
    // consistent: stacking several generous ones reads as toy-like rather than
    // soft, and the effect compounds when a card, a thumbnail and a badge all
    // curve at different rates.
    readonly property real radiusCardUnits:  0.35
    readonly property real radiusChipUnits:  0.2
    readonly property real thumbUnits:       2.75

    // Metadata set in small caps: wide tracking is what keeps it legible.
    readonly property real metaTracking:     1.2

    // -- Rhythm ---------------------------------------------------------------
    // Spacing steps as multiples of the platform base unit.
    readonly property real tightUnits:  0.25
    readonly property real snugUnits:   0.5
    readonly property real baseUnits:   1.0
    readonly property real looseUnits:  1.5
}
