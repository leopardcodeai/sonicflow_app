package com.sonicflow.app.ui

data class FlowToneExample(
    val id: String,
    val title: String,
    val subtitle: String,
    val preset: FlowTonePreset,
    val durationMinutes: Int
) {
    val ambientMix: Float = preset.defaultAmbientMix
    val pulseDepth: Float = preset.defaultPulseDepth

    companion object {
        val starterPack = listOf(
            FlowToneExample(
                id = "focus-primer",
                title = "Focus Primer",
                subtitle = "5 min gamma warmup",
                preset = FlowTonePreset.FOCUS,
                durationMinutes = 5
            ),
            FlowToneExample(
                id = "flow-reset",
                title = "Flow Reset",
                subtitle = "5 min alpha reset",
                preset = FlowTonePreset.FLOW,
                durationMinutes = 5
            ),
            FlowToneExample(
                id = "night-drift",
                title = "Night Drift",
                subtitle = "5 min delta wind-down",
                preset = FlowTonePreset.SLEEP,
                durationMinutes = 5
            )
        )
    }
}
