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
                mutableSelectedFile.value = session.selectedFile
            }
        }
    }

    fun onModeSelected(mode: FlowMode) {
        mutableCurrentMode.value = mode
    }

    fun onBeatVolumeChanged(volume: Float) {
        mutableBeatVolume.value = volume.coerceIn(0f, 1f)
    }

    fun onFileSelected(file: String?) {
        mutableSelectedFile.value = file
    }

    fun startSession() {
        controller.send(
            SessionCommand.Start(
                mode = currentMode.value,
                beatVolume = beatVolume.value,
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
