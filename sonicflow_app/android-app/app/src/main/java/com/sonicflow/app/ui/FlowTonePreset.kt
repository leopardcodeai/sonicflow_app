package com.sonicflow.app.ui

import com.sonicflow.beatengine.FlowMode

enum class FlowTonePreset(
    val mode: FlowMode,
    val displayName: String,
    val subtitle: String,
    val beatFrequencyHz: Double,
    val defaultAmbientMix: Float,
    val defaultPulseDepth: Float
) {
    FOCUS(
        mode = FlowMode.FOCUS,
        displayName = "Focus",
        subtitle = "Gamma lift for deep concentration.",
        beatFrequencyHz = 40.0,
        defaultAmbientMix = 0.45f,
        defaultPulseDepth = 0.95f
    ),
    FLOW(
        mode = FlowMode.FLOW,
        displayName = "Flow",
        subtitle = "Alpha pulse for smooth momentum.",
        beatFrequencyHz = 10.0,
        defaultAmbientMix = 0.55f,
        defaultPulseDepth = 0.78f
    ),
    MEDITATION(
        mode = FlowMode.MEDITATION,
        displayName = "Meditation",
        subtitle = "Theta drift for breathwork and stillness.",
        beatFrequencyHz = 6.0,
        defaultAmbientMix = 0.68f,
        defaultPulseDepth = 0.62f
    ),
    SLEEP(
        mode = FlowMode.SLEEP,
        displayName = "Sleep",
        subtitle = "Delta wash for gentle wind-down.",
        beatFrequencyHz = 2.0,
        defaultAmbientMix = 0.78f,
        defaultPulseDepth = 0.46f
    );

    companion object {
        fun from(mode: FlowMode): FlowTonePreset = entries.first { it.mode == mode }
    }
}
