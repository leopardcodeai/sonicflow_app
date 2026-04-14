package com.sonicflow.beatengine

import android.media.AudioFormat
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

        val track = AudioTrack(
            AudioManager.STREAM_MUSIC,
            sampleRate,
            AudioFormat.CHANNEL_OUT_STEREO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize,
            AudioTrack.MODE_STREAM
        )

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
