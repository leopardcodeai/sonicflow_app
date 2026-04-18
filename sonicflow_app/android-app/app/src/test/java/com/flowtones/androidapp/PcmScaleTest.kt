package com.flowtones.androidapp

import org.junit.Assert.assertArrayEquals
import org.junit.Test

class PcmScaleTest {
    @Test
    fun `scalePcm scales and clamps to short range`() {
        val source = shortArrayOf(1000, -1000, Short.MAX_VALUE, Short.MIN_VALUE)
        val half = scalePcm(source, 0.5f)
        assertArrayEquals(shortArrayOf(500, -500, 16383, -16384), half)

        val muted = scalePcm(source, -1f)
        assertArrayEquals(shortArrayOf(0, 0, 0, 0), muted)

        val full = scalePcm(source, 5f)
        assertArrayEquals(source, full)
    }
}
