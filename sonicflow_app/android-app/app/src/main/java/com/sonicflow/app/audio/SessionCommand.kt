package com.sonicflow.app.audio

import com.sonicflow.beatengine.FlowMode

sealed interface SessionCommand {
    data class Start(
        val mode: FlowMode,
        val beatVolume: Float,
        val selectedFile: String?
    ) : SessionCommand

    data object Stop : SessionCommand
}
