package com.sonicflow.app.ui

import androidx.compose.ui.graphics.Color
import com.sonicflow.app.brand.BrandTokens
import com.sonicflow.beatengine.FlowMode

val FlowMode.label: String
    get() = when (this) {
        FlowMode.FOCUS -> "Focus"
        FlowMode.FLOW -> "Flow"
        FlowMode.MEDITATION -> "Meditation"
        FlowMode.SLEEP -> "Sleep"
    }

val FlowMode.modeColor: Color
    get() = when (this) {
        FlowMode.FOCUS -> BrandTokens.Mode.focus
        FlowMode.FLOW -> BrandTokens.Mode.flow
        FlowMode.MEDITATION -> BrandTokens.Mode.meditation
        FlowMode.SLEEP -> BrandTokens.Mode.sleep
    }

val FlowMode.chakraColor: Color
    get() = when (this) {
        FlowMode.FOCUS -> BrandTokens.Chakra.throat
        FlowMode.FLOW -> BrandTokens.Chakra.thirdEye
        FlowMode.MEDITATION -> BrandTokens.Chakra.heart
        FlowMode.SLEEP -> BrandTokens.Chakra.crown
    }

/**
 * Legacy string form of the mode accent color. Derived from the brand tokens so the
 * canonical hex values live only in [BrandTokens]. Kept for source compatibility with
 * callers that expect a `#RRGGBB` string (e.g. test assertions, persistence).
 */
val FlowMode.accentColor: String
    get() = this.modeColor.toHexString()
