package com.sonicflow.app.audio

import com.sonicflow.beatengine.FlowMode

sealed interface SessionCommand {
    data class Start(
        val mode: FlowMode,
        val beatVolume: Float,
        val durationMinutes: Int,
        val ambientMix: Float,
        val pulseDepth: Float,
        val selectedFile: String?,
        val offlineAssetId: String? = null
    ) : SessionCommand

    data object Stop : SessionCommand
}
