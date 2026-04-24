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

enum class SessionProductMode {
    FOCUS,
    RELAX,
    SLEEP,
    MEDITATE
}

enum class SessionTimer(val durationMinutes: Int?) {
    POMODORO(25),
    SHORT(5),
    STANDARD(25),
    POWER_NAP(20),
    INFINITE_SLEEP(null)
}

enum class SessionActivity(
    val productMode: SessionProductMode,
    val engineMode: FlowMode,
    val defaultTimer: SessionTimer
) {
    DEEP_WORK(SessionProductMode.FOCUS, FlowMode.FOCUS, SessionTimer.POMODORO),
    CREATIVE_FLOW(SessionProductMode.FOCUS, FlowMode.FLOW, SessionTimer.POMODORO),
    LIGHT_WORK(SessionProductMode.FOCUS, FlowMode.FLOW, SessionTimer.STANDARD),
    LEARNING(SessionProductMode.FOCUS, FlowMode.FOCUS, SessionTimer.POMODORO),
    MOTIVATION(SessionProductMode.FOCUS, FlowMode.FOCUS, SessionTimer.SHORT),
    UNWIND(SessionProductMode.RELAX, FlowMode.FLOW, SessionTimer.STANDARD),
    DESTRESS(SessionProductMode.RELAX, FlowMode.MEDITATION, SessionTimer.STANDARD),
    RECHARGE(SessionProductMode.RELAX, FlowMode.FLOW, SessionTimer.SHORT),
    CHILL(SessionProductMode.RELAX, FlowMode.FLOW, SessionTimer.STANDARD),
    DEEP_SLEEP(SessionProductMode.SLEEP, FlowMode.SLEEP, SessionTimer.INFINITE_SLEEP),
    WIND_DOWN(SessionProductMode.SLEEP, FlowMode.SLEEP, SessionTimer.INFINITE_SLEEP),
    POWER_NAP(SessionProductMode.SLEEP, FlowMode.SLEEP, SessionTimer.POWER_NAP),
    GUIDED_SLEEP(SessionProductMode.SLEEP, FlowMode.SLEEP, SessionTimer.INFINITE_SLEEP),
    GUIDED_MEDITATION(SessionProductMode.MEDITATE, FlowMode.MEDITATION, SessionTimer.STANDARD),
    UNGUIDED_MEDITATION(SessionProductMode.MEDITATE, FlowMode.MEDITATION, SessionTimer.STANDARD)
}
