package com.sonicflow.app.audio

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

@Singleton
class AudioServiceController @Inject constructor(
    @ApplicationContext private val context: Context
) : FlowTonesSessionController {

    private val mutableState = MutableStateFlow(SessionState())
    override val state: StateFlow<SessionState> = mutableState.asStateFlow()

    private var isBound = false
    private var boundService: AudioService? = null
    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            isBound = true
            boundService = (service as? AudioService.LocalBinder)?.service()
            syncStateFromService()
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            isBound = false
            boundService = null
            mutableState.value = mutableState.value.copy(isActive = false)
        }
    }

    override fun send(command: SessionCommand) {
        when (command) {
            is SessionCommand.Start -> {
                bindIfNeeded()
                val intent = AudioService.buildStartIntent(
                    context,
                    command.mode,
                    command.beatVolume,
                    command.durationMinutes,
                    command.ambientMix,
                    command.pulseDepth,
                    command.selectedFile
                )
                context.startForegroundService(intent)
                mutableState.value = SessionState(
                    mode = command.mode,
                    isActive = false,
                    beatVolume = command.beatVolume,
                    durationMinutes = command.durationMinutes,
                    ambientMix = command.ambientMix,
                    pulseDepth = command.pulseDepth,
                    selectedFile = command.selectedFile
                )
            }

            SessionCommand.Stop -> {
                context.startService(AudioService.buildStopIntent(context))
                unbindIfNeeded()
                mutableState.value = mutableState.value.copy(isActive = false)
            }
        }
    }

    private fun bindIfNeeded() {
        if (isBound) return
        val intent = Intent(context, AudioService::class.java)
        context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
    }

    private fun unbindIfNeeded() {
        if (!isBound) return
        context.unbindService(connection)
        isBound = false
        boundService = null
    }

    private fun syncStateFromService() {
        val service = boundService ?: return
        mutableState.value = service.sessionState()
    }
}
