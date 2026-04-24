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

data class ModulationProfile(
    val program: ModulationProgram?,
    val mode: FlowMode,
    val intensity: NeuralIntensity,
    val targetBeatHz: Double,
    val carrierHz: Double,
    val modulationDepth: Double,
    val outputGain: Double,
    val stereoPhaseOffset: Double
) {
    companion object {
        fun program(program: ModulationProgram, intensity: NeuralIntensity): ModulationProfile {
            val mode = program.mode
            return ModulationProfile(
                program = program,
                mode = mode,
                intensity = intensity,
                targetBeatHz = mode.beatHz.toDouble(),
                carrierHz = mode.carrierHz.toDouble(),
                modulationDepth = intensity.modulationDepth,
                outputGain = intensity.outputGain,
                stereoPhaseOffset = intensity.stereoPhaseOffset
            )
        }

        fun legacy(mode: FlowMode): ModulationProfile {
            return ModulationProfile(
                program = null,
                mode = mode,
                intensity = NeuralIntensity.HIGH,
                targetBeatHz = mode.beatHz.toDouble(),
                carrierHz = mode.carrierHz.toDouble(),
                modulationDepth = 1.0,
                outputGain = 1.0,
                stereoPhaseOffset = 0.0
            )
        }
    }
}
