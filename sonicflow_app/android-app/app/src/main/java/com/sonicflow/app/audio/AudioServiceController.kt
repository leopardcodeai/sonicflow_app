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
    private var pendingStart = false
    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            isBound = true
            val localBinder = service as? AudioService.LocalBinder
            val active = localBinder?.service()?.isSessionActive ?: false
            if (pendingStart && active) {
                pendingStart = false
            }
            mutableState.value = mutableState.value.copy(isActive = active)
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            isBound = false
            pendingStart = false
            mutableState.value = mutableState.value.copy(isActive = false)
        }
    }

    override fun send(command: SessionCommand) {
        when (command) {
            is SessionCommand.Start -> {
                bindIfNeeded()
                pendingStart = true
                val intent = AudioService.buildStartIntent(
                    context,
                    command.mode,
                    command.beatVolume,
                    command.selectedFile
                )
                context.startForegroundService(intent)
                mutableState.value = SessionState(
                    mode = command.mode,
                    isActive = false,
                    beatVolume = command.beatVolume,
                    selectedFile = command.selectedFile
                )
            }

            SessionCommand.Stop -> {
                pendingStart = false
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
    }
}
