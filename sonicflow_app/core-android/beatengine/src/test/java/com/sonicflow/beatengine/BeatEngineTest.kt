package com.sonicflow.beatengine

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BeatEngineTest {

    @Test
    fun `flow modes expose the exact SF-3 constants`() {
        val modes = FlowMode.values().toList()

        assertEquals(listOf(FlowMode.FOCUS, FlowMode.FLOW, FlowMode.MEDITATION, FlowMode.SLEEP), modes)
        assertEquals(40, FlowMode.FOCUS.beatHz)
        assertEquals(200, FlowMode.FOCUS.carrierHz)
        assertEquals(10, FlowMode.FLOW.beatHz)
        assertEquals(200, FlowMode.FLOW.carrierHz)
        assertEquals(6, FlowMode.MEDITATION.beatHz)
        assertEquals(180, FlowMode.MEDITATION.carrierHz)
        assertEquals(2, FlowMode.SLEEP.beatHz)
        assertEquals(150, FlowMode.SLEEP.carrierHz)
    }

    @Test
    fun `generatePCM returns stereo interleaved 16-bit PCM with the expected length`() {
        val engine = BeatEngine()

        val pcm = engine.generatePCM(FlowMode.FOCUS, durationSeconds = 2.0, sampleRate = 100)

        assertEquals(2 * 100 * 2, pcm.size)
    }

    @Test
    fun `generatePCM mirrors left and right channels`() {
        val engine = BeatEngine()

        val pcm = engine.generatePCM(FlowMode.FLOW, durationSeconds = 1.0, sampleRate = 120)

        for (frame in 0 until 20) {
            val left = pcm[frame * 2]
            val right = pcm[frame * 2 + 1]
            assertEquals(left, right)
        }
    }

    @Test
    fun `generatePCM fades in and out over five seconds`() {
        val engine = BeatEngine()
        val sampleRate = 100

        val pcm = engine.generatePCM(FlowMode.MEDITATION, durationSeconds = 12.0, sampleRate = sampleRate)

        val firstSecondMax = (0 until sampleRate).maxOf { frame ->
            kotlin.math.abs(pcm[frame * 2].toInt())
        }
        val totalFrames = pcm.size / 2
        val middleSecondStart = totalFrames / 2 - sampleRate / 2
        val middleSecondMax = (middleSecondStart until middleSecondStart + sampleRate).maxOf { frame ->
            kotlin.math.abs(pcm[frame * 2].toInt())
        }
        val lastSecondStart = totalFrames - sampleRate
        val lastSecondMax = (lastSecondStart until lastSecondStart + sampleRate).maxOf { frame ->
            kotlin.math.abs(pcm[frame * 2].toInt())
        }

        assertTrue(firstSecondMax < middleSecondMax)
        assertTrue(lastSecondMax < middleSecondMax)
    }

    @Test
    fun `play and stop delegate to the pcm player`() {
        val player = RecordingPcmPlayer()
        val engine = BeatEngine(player)
        val pcm = shortArrayOf(1, 1, 2, 2)

        engine.play(pcm, 44100)
        engine.stop()

        assertArrayEquals(pcm, player.lastPcm)
        assertEquals(44100, player.lastSampleRate)
        assertTrue(player.stopCalled)
    }
}

private class RecordingPcmPlayer : PcmPlayer {
    var lastPcm: ShortArray = shortArrayOf()
    var lastSampleRate: Int = -1
    var stopCalled: Boolean = false

    override fun play(pcm: ShortArray, sampleRate: Int) {
        lastPcm = pcm.copyOf()
        lastSampleRate = sampleRate
    }

    override fun stop() {
        stopCalled = true
    }
}
