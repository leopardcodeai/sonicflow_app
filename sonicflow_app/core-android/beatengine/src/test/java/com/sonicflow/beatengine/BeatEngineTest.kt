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
    fun `modulation programs expose parity taxonomy and intensity depths`() {
        assertEquals(
            listOf(ModulationProgram.FOCUS, ModulationProgram.RELAX, ModulationProgram.SLEEP, ModulationProgram.MEDITATE),
            ModulationProgram.values().toList()
        )
        assertTrue(NeuralIntensity.LOW.modulationDepth < NeuralIntensity.MEDIUM.modulationDepth)
        assertTrue(NeuralIntensity.MEDIUM.modulationDepth < NeuralIntensity.HIGH.modulationDepth)

        assertEquals(10.0, ModulationProfile.program(ModulationProgram.RELAX, NeuralIntensity.MEDIUM).targetBeatHz, 0.0001)
        assertEquals(6.0, ModulationProfile.program(ModulationProgram.MEDITATE, NeuralIntensity.HIGH).targetBeatHz, 0.0001)
    }

    @Test
    fun `generatePCM returns stereo interleaved 16-bit PCM with the expected length`() {
        val engine = BeatEngine()

        val pcm = engine.generatePCM(FlowMode.FOCUS, durationSeconds = 2.0, sampleRate = 100)

        assertEquals(2 * 100 * 2, pcm.size)
    }

    @Test
    fun `intensity controls modulation depth`() {
        val engine = BeatEngine()
        val sampleRate = 1000
        val low = engine.generatePCM(
            ModulationProfile.program(ModulationProgram.FOCUS, NeuralIntensity.LOW),
            durationSeconds = 12.0,
            sampleRate = sampleRate
        )
        val high = engine.generatePCM(
            ModulationProfile.program(ModulationProgram.FOCUS, NeuralIntensity.HIGH),
            durationSeconds = 12.0,
            sampleRate = sampleRate
        )

        assertTrue(peakChannel(high, 6 * sampleRate, sampleRate) > peakChannel(low, 6 * sampleRate, sampleRate) * 1.25)
    }

    @Test
    fun `high intensity uses independent stereo modulation while staying bounded`() {
        val engine = BeatEngine()
        val sampleRate = 1000
        val pcm = engine.generatePCM(
            ModulationProfile.program(ModulationProgram.MEDITATE, NeuralIntensity.HIGH),
            durationSeconds = 12.0,
            sampleRate = sampleRate
        )
        var accumulatedDifference = 0
        var peak = 0

        for (frame in 6 * sampleRate until 7 * sampleRate) {
            val left = pcm[frame * 2].toInt()
            val right = pcm[frame * 2 + 1].toInt()
            accumulatedDifference += kotlin.math.abs(left - right)
            peak = maxOf(peak, kotlin.math.abs(left), kotlin.math.abs(right))
        }

        assertTrue(accumulatedDifference > 100)
        assertTrue(peak <= (Short.MAX_VALUE * 0.120001).toInt())
    }

    @Test
    fun `long rendered loops remain finite and fade to silence`() {
        val engine = BeatEngine()
        val pcm = engine.generatePCM(
            ModulationProfile.program(ModulationProgram.SLEEP, NeuralIntensity.MEDIUM),
            durationSeconds = 60.0,
            sampleRate = 200
        )

        assertEquals(0, pcm.first().toInt())
        assertEquals(0, pcm.last().toInt())
        assertTrue(pcm.maxOf { kotlin.math.abs(it.toInt()) } <= (Short.MAX_VALUE * 0.120001).toInt())
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

private fun peakChannel(pcm: ShortArray, startFrame: Int, frameCount: Int): Int {
    var peak = 0
    for (frame in startFrame until startFrame + frameCount) {
        peak = maxOf(peak, kotlin.math.abs(pcm[frame * 2].toInt()))
    }
    return peak
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
