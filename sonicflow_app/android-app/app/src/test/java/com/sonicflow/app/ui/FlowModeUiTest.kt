package com.sonicflow.app.ui

import com.sonicflow.beatengine.FlowMode
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FlowModeUiTest {

    @Test
    fun `every mode exposes UI label and accent color`() {
        val all = FlowMode.entries
        assertEquals(4, all.size)

        assertEquals("Focus", FlowMode.FOCUS.label)
        assertEquals("Flow", FlowMode.FLOW.label)
        assertEquals("Meditation", FlowMode.MEDITATION.label)
        assertEquals("Sleep", FlowMode.SLEEP.label)

        assertTrue(FlowMode.FOCUS.accentColor.startsWith("#"))
        assertTrue(FlowMode.FLOW.accentColor.startsWith("#"))
        assertTrue(FlowMode.MEDITATION.accentColor.startsWith("#"))
        assertTrue(FlowMode.SLEEP.accentColor.startsWith("#"))
    }
}
