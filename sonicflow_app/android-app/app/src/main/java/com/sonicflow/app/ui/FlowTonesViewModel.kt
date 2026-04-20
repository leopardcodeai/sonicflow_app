package com.sonicflow.app.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sonicflow.app.audio.FlowTonesSessionController
import com.sonicflow.app.audio.SessionCommand
import com.sonicflow.beatengine.FlowMode
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class FlowTonesViewModel @Inject constructor(
    private val controller: FlowTonesSessionController
) : ViewModel() {

    private val mutableCurrentMode = MutableStateFlow(FlowMode.FOCUS)
    val currentMode: StateFlow<FlowMode> = mutableCurrentMode.asStateFlow()

    private val mutableIsActive = MutableStateFlow(false)
    val isActive: StateFlow<Boolean> = mutableIsActive.asStateFlow()

    private val mutableBeatVolume = MutableStateFlow(0.15f)
    val beatVolume: StateFlow<Float> = mutableBeatVolume.asStateFlow()

    private val mutableDurationMinutes = MutableStateFlow(25)
    val durationMinutes: StateFlow<Int> = mutableDurationMinutes.asStateFlow()

    private val mutableAmbientMix = MutableStateFlow(0.45f)
    val ambientMix: StateFlow<Float> = mutableAmbientMix.asStateFlow()

    private val mutablePulseDepth = MutableStateFlow(0.95f)
    val pulseDepth: StateFlow<Float> = mutablePulseDepth.asStateFlow()

    private val mutableSelectedFile = MutableStateFlow<String?>(null)
    val selectedFile: StateFlow<String?> = mutableSelectedFile.asStateFlow()

    private val mutableFilePickerEvents = MutableSharedFlow<Unit>()
    val filePickerEvents: SharedFlow<Unit> = mutableFilePickerEvents.asSharedFlow()

    init {
        viewModelScope.launch {
            controller.state.collectLatest { session ->
                mutableCurrentMode.value = session.mode
                mutableIsActive.value = session.isActive
                mutableBeatVolume.value = session.beatVolume
                mutableDurationMinutes.value = session.durationMinutes
                mutableAmbientMix.value = session.ambientMix
                mutablePulseDepth.value = session.pulseDepth
                mutableSelectedFile.value = session.selectedFile
            }
        }
    }

    fun onModeSelected(mode: FlowMode) {
        mutableCurrentMode.value = mode
    }

    fun setMode(mode: FlowMode) {
        onModeSelected(mode)
    }

    fun onBeatVolumeChanged(volume: Float) {
        mutableBeatVolume.value = volume.coerceIn(0f, 1f)
    }

    fun onDurationMinutesChanged(minutes: Int) {
        mutableDurationMinutes.value = minutes.coerceIn(5, 60)
    }

    fun onAmbientMixChanged(value: Float) {
        mutableAmbientMix.value = value.coerceIn(0.2f, 1f)
    }

    fun onPulseDepthChanged(value: Float) {
        mutablePulseDepth.value = value.coerceIn(0.2f, 1f)
    }

    fun onFileSelected(file: String?) {
        mutableSelectedFile.value = file
    }

    fun startSession() {
        controller.send(
            SessionCommand.Start(
                mode = currentMode.value,
                beatVolume = beatVolume.value,
                durationMinutes = durationMinutes.value,
                ambientMix = ambientMix.value,
                pulseDepth = pulseDepth.value,
                selectedFile = selectedFile.value
            )
        )
    }

    fun stopSession() {
        controller.send(SessionCommand.Stop)
    }

    fun pickFile() {
        viewModelScope.launch {
            mutableFilePickerEvents.emit(Unit)
        }
    }
}
