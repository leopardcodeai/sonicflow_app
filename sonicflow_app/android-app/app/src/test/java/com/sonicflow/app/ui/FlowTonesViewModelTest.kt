package com.sonicflow.app.ui

import com.sonicflow.app.audio.FlowTonesSessionController
import com.sonicflow.app.audio.SessionCommand
import com.sonicflow.app.audio.SessionState
import com.sonicflow.beatengine.FlowMode
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class FlowTonesViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun `startSession forwards full FlowTones session settings to controller and flips isActive`() = runTest {
        val controller = FakeController()
        val viewModel = FlowTonesViewModel(controller)

        viewModel.onModeSelected(FlowMode.MEDITATION)
        viewModel.onBeatVolumeChanged(0.25f)
        viewModel.onDurationMinutesChanged(35)
        viewModel.onAmbientMixChanged(0.64f)
        viewModel.onPulseDepthChanged(0.58f)
        viewModel.onFileSelected("content://demo/file.mp3")
        viewModel.startSession()

        assertEquals(
            SessionCommand.Start(
                mode = FlowMode.MEDITATION,
                beatVolume = 0.25f,
                durationMinutes = 35,
                ambientMix = 0.64f,
                pulseDepth = 0.58f,
                selectedFile = "content://demo/file.mp3"
            ),
            controller.lastCommand
        )
        assertTrue(viewModel.isActive.value)
    }

    @Test
    fun `stopSession forwards stop command and flips state inactive`() = runTest {
        val controller = FakeController()
        val viewModel = FlowTonesViewModel(controller)

        viewModel.startSession()
        viewModel.stopSession()

        assertEquals(SessionCommand.Stop, controller.lastCommand)
        assertFalse(viewModel.isActive.value)
    }

    @Test
    fun `pickFile emits an event`() = runTest(UnconfinedTestDispatcher()) {
        val controller = FakeController()
        val viewModel = FlowTonesViewModel(controller)

        val emitted = MutableSharedFlow<Unit>(replay = 1)
        val job = launch {
            emitted.emit(viewModel.filePickerEvents.first())
        }

        viewModel.pickFile()

        assertEquals(Unit, emitted.first())
        job.cancel()
    }

    @Test
    fun `setMode updates the current mode immediately`() = runTest {
        val controller = FakeController()
        val viewModel = FlowTonesViewModel(controller)

        viewModel.setMode(FlowMode.SLEEP)

        assertEquals(FlowMode.SLEEP, viewModel.currentMode.value)
    }

    private class FakeController : FlowTonesSessionController {
        override val state = MutableStateFlow(SessionState())
        var lastCommand: SessionCommand? = null

        override fun send(command: SessionCommand) {
            lastCommand = command
            when (command) {
                is SessionCommand.Start -> {
                    state.value = state.value.copy(
                        mode = command.mode,
                        beatVolume = command.beatVolume,
                        durationMinutes = command.durationMinutes,
                        ambientMix = command.ambientMix,
                        pulseDepth = command.pulseDepth,
                        selectedFile = command.selectedFile,
                        isActive = true
                    )
                }
                SessionCommand.Stop -> state.value = state.value.copy(isActive = false)
            }
        }
    }
}
