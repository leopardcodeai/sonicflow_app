package com.sonicflow.app.ui

data class SonicFlowExample(
    val id: String,
    val title: String,
    val subtitle: String,
    val preset: SonicFlowPreset,
    val durationMinutes: Int
) {
    val ambientMix: Float = preset.defaultAmbientMix
    val pulseDepth: Float = preset.defaultPulseDepth

    companion object {
        val starterPack = listOf(
            SonicFlowExample(
                id = "focus-primer",
                title = "Focus Primer",
                subtitle = "5 min gamma warmup",
                preset = SonicFlowPreset.FOCUS,
                durationMinutes = 5
            ),
            SonicFlowExample(
                id = "flow-reset",
                title = "Flow Reset",
                subtitle = "5 min alpha reset",
                preset = SonicFlowPreset.FLOW,
                durationMinutes = 5
            ),
            SonicFlowExample(
                id = "night-drift",
                title = "Night Drift",
                subtitle = "5 min delta wind-down",
                preset = SonicFlowPreset.SLEEP,
                durationMinutes = 5
            )
        )
    }
}
