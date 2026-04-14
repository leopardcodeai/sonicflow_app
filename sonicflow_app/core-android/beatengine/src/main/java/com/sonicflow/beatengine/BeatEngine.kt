package com.sonicflow.beatengine

import kotlin.math.PI
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sin

class BeatEngine(
    private val player: PcmPlayer = AndroidAudioTrackPlayer()
) {
    fun generatePCM(mode: FlowMode, durationSeconds: Double, sampleRate: Int = DEFAULT_SAMPLE_RATE): ShortArray {
        val totalFrames = max(0, floor(durationSeconds * sampleRate).toInt())
        val pcm = ShortArray(totalFrames * 2)
        val fadeFrames = min(floor(FADE_SECONDS * sampleRate).toInt(), totalFrames / 2)

        for (frame in 0 until totalFrames) {
            val timeSeconds = frame.toDouble() / sampleRate
            val carrier = sin(2.0 * PI * mode.carrierHz * timeSeconds)
            val modulation = 0.5 + 0.5 * sin(2.0 * PI * mode.beatHz * timeSeconds)
            val envelope = envelopeAt(frame, totalFrames, fadeFrames)
            val sample = carrier * modulation * AMPLITUDE * envelope
            val pcmSample = (sample * Short.MAX_VALUE).roundToInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
            val offset = frame * 2

            pcm[offset] = pcmSample
            pcm[offset + 1] = pcmSample
        }

        return pcm
    }

    fun play(pcm: ShortArray, sampleRate: Int) {
        player.play(pcm, sampleRate)
    }

    fun stop() {
        player.stop()
    }

    private fun envelopeAt(index: Int, totalFrames: Int, fadeFrames: Int): Double {
        if (totalFrames <= 1) return 0.0
        if (fadeFrames <= 0) return 1.0

        if (index < fadeFrames) {
            return index.toDouble() / fadeFrames
        }

        val fadeOutStart = totalFrames - fadeFrames
        if (index >= fadeOutStart) {
            return max((totalFrames - 1 - index).toDouble() / fadeFrames, 0.0)
        }

        return 1.0
    }

    private companion object {
        const val DEFAULT_SAMPLE_RATE = 44_100
        const val FADE_SECONDS = 5.0
        const val AMPLITUDE = 0.12
    }
}
