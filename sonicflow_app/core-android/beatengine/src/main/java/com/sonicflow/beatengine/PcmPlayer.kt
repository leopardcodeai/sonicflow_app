package com.sonicflow.beatengine

interface PcmPlayer {
    fun play(pcm: ShortArray, sampleRate: Int)
    fun stop()
}
