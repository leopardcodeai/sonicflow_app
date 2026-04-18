package com.sonicflow.beatengine

import android.media.AudioFormat
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.AudioTrack

internal class AndroidAudioTrackPlayer : PcmPlayer {
    private var audioTrack: AudioTrack? = null

    override fun play(pcm: ShortArray, sampleRate: Int) {
        stop()

        val minBufferSize = AudioTrack.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT
        )
        val bufferSize = if (minBufferSize > 0) {
            maxOf(minBufferSize, pcm.size * 2)
        } else {
            pcm.size * 2
        }

        val format = AudioFormat.Builder()
            .setSampleRate(sampleRate)
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
            .build()
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val track = AudioTrack.Builder()
            .setAudioFormat(format)
            .setAudioAttributes(attributes)
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()

        track.write(pcm, 0, pcm.size)
        track.play()
        audioTrack = track
    }

    override fun stop() {
        audioTrack?.run {
            stop()
            release()
        }
        audioTrack = null
    }
}
