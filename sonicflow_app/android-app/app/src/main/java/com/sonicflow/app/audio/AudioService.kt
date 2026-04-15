package com.sonicflow.app.audio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.sonicflow.app.R
import com.sonicflow.beatengine.BeatEngine
import com.sonicflow.beatengine.FlowMode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class AudioService : Service() {
    private val binder = LocalBinder()
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    private val beatEngine = BeatEngine()
    private var beatJob: Job? = null
    private var mediaPlayer: MediaPlayer? = null

    private lateinit var audioManager: AudioManager
    private lateinit var audioFocusRequest: AudioFocusRequest

    override fun onCreate() {
        super.onCreate()
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .build()

        ensureNotificationChannel()
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val started = startSession(
                    mode = parseMode(intent.getStringExtra(EXTRA_MODE)),
                    beatVolume = intent.getFloatExtra(EXTRA_BEAT_VOLUME, DEFAULT_BEAT_VOLUME),
                    selectedFile = intent.getStringExtra(EXTRA_SELECTED_FILE)
                )
                if (!started) {
                    stopSelfResult(startId)
                    return START_NOT_STICKY
                }
            }

            ACTION_STOP -> stopSession()
        }

        return START_STICKY
    }

    fun startSession(mode: FlowMode, beatVolume: Float, selectedFile: String?): Boolean {
        val focusResult = audioManager.requestAudioFocus(audioFocusRequest)
        if (focusResult != AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
            return false
        }

        val normalizedVolume = beatVolume.coerceIn(0f, 1f)
        val title = "FlowTones – ${mode.name.lowercase().replaceFirstChar(Char::uppercase)} ${mode.beatHz}Hz ●"
        startForeground(NOTIFICATION_ID, buildNotification(title))

        startBeatLoop(mode, normalizedVolume)
        startMediaLayer(selectedFile)
        return true
    }

    fun stopSession() {
        beatJob?.cancel()
        beatJob = null
        beatEngine.stop()

        mediaPlayer?.run {
            stop()
            release()
        }
        mediaPlayer = null

        audioManager.abandonAudioFocusRequest(audioFocusRequest)

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopSession()
        super.onDestroy()
    }

    private fun startBeatLoop(mode: FlowMode, beatVolume: Float) {
        beatJob?.cancel()
        beatEngine.stop()

        beatJob = serviceScope.launch {
            while (isActive) {
                val pcm = beatEngine.generatePCM(mode = mode, durationSeconds = LOOP_SECONDS.toDouble())
                beatEngine.play(scalePcm(pcm, beatVolume), SAMPLE_RATE)
                delay((LOOP_SECONDS * 1000L) - 500L)
            }
        }
    }

    private fun startMediaLayer(selectedFile: String?) {
        mediaPlayer?.run {
            stop()
            release()
        }
        mediaPlayer = null

        if (selectedFile.isNullOrBlank()) return

        runCatching {
            MediaPlayer().apply {
                setDataSource(applicationContext, Uri.parse(selectedFile))
                isLooping = true
                prepare()
                start()
            }
        }.onSuccess { created ->
            mediaPlayer = created
        }
    }

    private fun scalePcm(source: ShortArray, volume: Float): ShortArray {
        if (volume >= 0.999f) return source

        val scaled = ShortArray(source.size)
        for (i in source.indices) {
            scaled[i] = (source[i] * volume).toInt()
                .coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
                .toShort()
        }
        return scaled
    }

    private fun buildNotification(title: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_music)
            .setContentTitle(title)
            .setContentText("Foreground session active")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "FlowTones Playback",
            NotificationManager.IMPORTANCE_LOW
        )
        manager.createNotificationChannel(channel)
    }

    private fun parseMode(raw: String?): FlowMode {
        return runCatching { FlowMode.valueOf(raw.orEmpty()) }.getOrDefault(FlowMode.FOCUS)
    }

    inner class LocalBinder : Binder() {
        fun service(): AudioService = this@AudioService
    }

    companion object {
        private const val CHANNEL_ID = "flowtones-playback"
        private const val NOTIFICATION_ID = 2001
        private const val SAMPLE_RATE = 44_100
        private const val LOOP_SECONDS = 30
        private const val DEFAULT_BEAT_VOLUME = 0.15f

        const val ACTION_START = "com.sonicflow.app.audio.START"
        const val ACTION_STOP = "com.sonicflow.app.audio.STOP"
        const val EXTRA_MODE = "mode"
        const val EXTRA_BEAT_VOLUME = "beatVolume"
        const val EXTRA_SELECTED_FILE = "selectedFile"

        fun buildStartIntent(
            context: Context,
            mode: FlowMode,
            beatVolume: Float,
            selectedFile: String?
        ): Intent {
            return Intent(context, AudioService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_MODE, mode.name)
                putExtra(EXTRA_BEAT_VOLUME, beatVolume)
                putExtra(EXTRA_SELECTED_FILE, selectedFile)
            }
        }

        fun buildStopIntent(context: Context): Intent {
            return Intent(context, AudioService::class.java).apply {
                action = ACTION_STOP
            }
        }
    }
}
