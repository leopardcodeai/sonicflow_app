package com.sonicflow.app.audio

import com.sonicflow.beatengine.FlowMode

data class SessionState(
    val mode: FlowMode = FlowMode.FOCUS,
    val isActive: Boolean = false,
    val beatVolume: Float = 0.15f,
    val durationMinutes: Int = 25,
    val ambientMix: Float = 0.45f,
    val pulseDepth: Float = 0.95f,
    val selectedFile: String? = null
)
