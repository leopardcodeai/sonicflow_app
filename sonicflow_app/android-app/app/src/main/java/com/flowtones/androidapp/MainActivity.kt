package com.flowtones.androidapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.sonicflow.beatengine.BeatEngine
import com.sonicflow.beatengine.FlowMode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class UiState(
    val selectedMode: FlowMode = FlowMode.FOCUS,
    val volumePercent: Int = 30,
    val isPlaying: Boolean = false,
    val status: String = "Ready"
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val vm: FlowTonesViewModel = viewModel(factory = FlowTonesViewModel.Factory)
            MaterialTheme {
                FlowTonesScreen(vm)
            }
        }
    }
}

class FlowTonesViewModel(
    private val controller: BeatPlaybackController = BeatPlaybackController()
) : ViewModel() {
    private val _state = MutableStateFlow(UiState())
    val state: StateFlow<UiState> = _state.asStateFlow()

    fun setMode(mode: FlowMode) {
        _state.update { it.copy(selectedMode = mode) }
        if (_state.value.isPlaying) {
            start()
        }
    }

    fun setVolume(value: Float) {
        _state.update { it.copy(volumePercent = value.toInt()) }
    }

    fun start() {
        val snapshot = _state.value
        viewModelScope.launch(Dispatchers.Default) {
            controller.stop()
            runCatching {
                controller.play(snapshot.selectedMode, snapshot.volumePercent)
            }.onSuccess {
                _state.update { it.copy(isPlaying = true, status = "Playing ${snapshot.selectedMode.name} @ ${snapshot.volumePercent}%") }
            }.onFailure { error ->
                _state.update {
                    it.copy(
                        isPlaying = false,
                        status = "Audio init failed. Try Stop and Start again."
                    )
                }
            }
        }
    }

    fun stop() {
        controller.stop()
        _state.update { it.copy(isPlaying = false, status = "Stopped") }
    }

    override fun onCleared() {
        controller.stop()
        super.onCleared()
    }

    object Factory : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return FlowTonesViewModel() as T
        }
    }
}

class BeatPlaybackController(
    private val engine: BeatEngine = BeatEngine()
) {
    private val sampleRate = 44_100

    fun play(mode: FlowMode, volumePercent: Int) {
        val pcm = engine.generatePCM(mode, durationSeconds = 20.0, sampleRate = sampleRate)
        val scaled = scalePcm(pcm, (volumePercent.coerceIn(0, 100) / 100f))
        engine.play(scaled, sampleRate)
    }

    fun stop() {
        engine.stop()
    }
}

fun scalePcm(input: ShortArray, gain: Float): ShortArray {
    val safeGain = gain.coerceIn(0f, 1f)
    return ShortArray(input.size) { index ->
        val scaled = (input[index] * safeGain).toInt()
            .coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt())
        scaled.toShort()
    }
}

@Composable
private fun FlowTonesScreen(vm: FlowTonesViewModel) {
    val state by vm.state.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("FlowTones Android Demo", style = MaterialTheme.typography.headlineSmall)
        Text(state.status)

        val modes = FlowMode.entries.toList()
        for (rowModes in modes.chunked(2)) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                rowModes.forEach { mode ->
                    val selected = state.selectedMode == mode
                    Button(
                        onClick = { vm.setMode(mode) },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = if (selected) MaterialTheme.colorScheme.primary else Color(0xFF6F5BAE)
                        )
                    ) {
                        Text(mode.name)
                    }
                }
                if (rowModes.size == 1) {
                    Spacer(modifier = Modifier.weight(1f))
                }
            }
        }

        Text("Volume: ${state.volumePercent}%")
        Slider(
            value = state.volumePercent.toFloat(),
            onValueChange = vm::setVolume,
            valueRange = 0f..100f
        )

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
            Button(onClick = vm::start, modifier = Modifier.weight(1f)) {
                Text(if (state.isPlaying) "Restart" else "Start")
            }
            Button(onClick = vm::stop, modifier = Modifier.weight(1f)) {
                Text("Stop")
            }
        }
    }
}
