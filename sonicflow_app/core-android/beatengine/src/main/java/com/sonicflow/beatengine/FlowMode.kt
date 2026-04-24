package com.sonicflow.beatengine

enum class FlowMode(val beatHz: Int, val carrierHz: Int) {
    FOCUS(40, 200),
    FLOW(10, 200),
    MEDITATION(6, 180),
    SLEEP(2, 150)
}

enum class NeuralIntensity(
    val modulationDepth: Double,
    val outputGain: Double,
    val stereoPhaseOffset: Double
) {
    LOW(0.35, 0.55, 0.0),
    MEDIUM(0.65, 0.8, kotlin.math.PI / 9.0),
    HIGH(0.95, 1.0, kotlin.math.PI / 4.0)
}

enum class ModulationProgram(val mode: FlowMode) {
    FOCUS(FlowMode.FOCUS),
    RELAX(FlowMode.FLOW),
    SLEEP(FlowMode.SLEEP),
    MEDITATE(FlowMode.MEDITATION)
}

enum class ResearchCondition {
    MODULATED,
    CONTROL
}

enum class SleepSpatializationLevel(val profile: SleepSpatializationProfile) {
    OFF(SleepSpatializationProfile(enabled = false, rockingHz = 0.0, panDepth = 0.0)),
    LOW(SleepSpatializationProfile(enabled = true, rockingHz = 0.04, panDepth = 0.12)),
    MEDIUM(SleepSpatializationProfile(enabled = true, rockingHz = 0.04, panDepth = 0.28)),
    HIGH(SleepSpatializationProfile(enabled = true, rockingHz = 0.04, panDepth = 0.48))
}

data class SleepSpatializationProfile(
    val enabled: Boolean,
    val rockingHz: Double,
    val panDepth: Double
)

data class ModulationProfile(
    val program: ModulationProgram?,
    val mode: FlowMode,
    val intensity: NeuralIntensity,
    val researchCondition: ResearchCondition,
    val targetBeatHz: Double,
    val carrierHz: Double,
    val modulationDepth: Double,
    val outputGain: Double,
    val stereoPhaseOffset: Double,
    val sleepSpatialization: SleepSpatializationProfile
) {
    companion object {
        fun program(
            program: ModulationProgram,
            intensity: NeuralIntensity,
            researchCondition: ResearchCondition = ResearchCondition.MODULATED,
            sleepSpatialization: SleepSpatializationLevel = SleepSpatializationLevel.OFF
        ): ModulationProfile {
            val mode = program.mode
            val isControl = researchCondition == ResearchCondition.CONTROL
            return ModulationProfile(
                program = program,
                mode = mode,
                intensity = intensity,
                researchCondition = researchCondition,
                targetBeatHz = mode.beatHz.toDouble(),
                carrierHz = mode.carrierHz.toDouble(),
                modulationDepth = if (isControl) 0.0 else intensity.modulationDepth,
                outputGain = intensity.outputGain,
                stereoPhaseOffset = if (isControl) 0.0 else intensity.stereoPhaseOffset,
                sleepSpatialization = if (mode == FlowMode.SLEEP) {
                    sleepSpatialization.profile
                } else {
                    SleepSpatializationLevel.OFF.profile
                }
            )
        }

        fun legacy(mode: FlowMode): ModulationProfile {
            return ModulationProfile(
                program = null,
                mode = mode,
                intensity = NeuralIntensity.HIGH,
                researchCondition = ResearchCondition.MODULATED,
                targetBeatHz = mode.beatHz.toDouble(),
                carrierHz = mode.carrierHz.toDouble(),
                modulationDepth = 1.0,
                outputGain = 1.0,
                stereoPhaseOffset = 0.0,
                sleepSpatialization = SleepSpatializationLevel.OFF.profile
            )
        }
    }
}
