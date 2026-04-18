package com.sonicflow.beatengine

import android.media.AudioAttributes
import android.media.AudioFormat
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
        require(minBufferSize > 0) { "AudioTrack min buffer size unavailable." }

        val track = AudioTrack.Builder()
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAudioFormat(
                AudioFormat.Builder()
                    .setSampleRate(sampleRate)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
                    .build()
            )
            .setBufferSizeInBytes(minBufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()

        require(track.state == AudioTrack.STATE_INITIALIZED) {
            track.release()
            "AudioTrack failed to initialize."
        }

        val written = track.write(pcm, 0, pcm.size, AudioTrack.WRITE_BLOCKING)
        require(written > 0) {
            track.release()
            "AudioTrack write failed: $written"
        }

        track.play()
        audioTrack = track
    }

    override fun stop() {
        audioTrack?.run {
            if (playState == AudioTrack.PLAYSTATE_PLAYING) {
                stop()
            }
            release()
        }
        audioTrack = null
    }
}
