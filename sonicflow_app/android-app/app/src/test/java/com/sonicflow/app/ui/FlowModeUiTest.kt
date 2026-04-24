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

    @Test
    fun `session taxonomy maps activities timers and existing engine modes`() {
        assertEquals(
            listOf(SessionProductMode.FOCUS, SessionProductMode.RELAX, SessionProductMode.SLEEP, SessionProductMode.MEDITATE),
            SessionProductMode.entries
        )
        assertEquals(15, SessionActivity.entries.size)

        assertEquals(SessionProductMode.FOCUS, SessionActivity.CREATIVE_FLOW.productMode)
        assertEquals(FlowMode.FLOW, SessionActivity.CREATIVE_FLOW.engineMode)
        assertEquals(SessionTimer.POMODORO, SessionActivity.CREATIVE_FLOW.defaultTimer)
        assertEquals(SessionProductMode.SLEEP, SessionActivity.WIND_DOWN.productMode)
        assertEquals(SessionTimer.INFINITE_SLEEP, SessionActivity.WIND_DOWN.defaultTimer)
        assertEquals(25, SessionTimer.POMODORO.durationMinutes)
        assertEquals(null, SessionTimer.INFINITE_SLEEP.durationMinutes)
    }
}
