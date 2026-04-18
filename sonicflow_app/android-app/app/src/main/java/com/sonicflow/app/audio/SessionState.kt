package com.sonicflow.app.audio

import com.sonicflow.beatengine.FlowMode

data class SessionState(
    val mode: FlowMode = FlowMode.FOCUS,
    val isActive: Boolean = false,
    val beatVolume: Float = 0.15f,
    val selectedFile: String? = null
)
