package com.sonicflow.app.audio

import kotlinx.coroutines.flow.StateFlow

interface FlowTonesSessionController {
    val state: StateFlow<SessionState>
    fun send(command: SessionCommand)
}
