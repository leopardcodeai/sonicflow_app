package com.sonicflow.app

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.lifecycleScope
import com.sonicflow.app.ui.FlowTonesViewModel
import com.sonicflow.beatengine.FlowMode
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private val viewModel: FlowTonesViewModel by viewModels()

    private val picker = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        viewModel.onFileSelected(uri?.toString())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        lifecycleScope.launch {
            viewModel.filePickerEvents.collect {
                picker.launch("audio/*")
            }
        }

        setContent {
            MaterialTheme {
                FlowTonesScreen(viewModel)
            }
        }
    }
}

@Composable
private fun FlowTonesScreen(viewModel: FlowTonesViewModel) {
    val currentMode by viewModel.currentMode.collectAsState()
    val isActive by viewModel.isActive.collectAsState()
    val beatVolume by viewModel.beatVolume.collectAsState()
    val selectedFile by viewModel.selectedFile.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text(text = "FlowTones", style = MaterialTheme.typography.headlineSmall)
        Text(text = if (isActive) "Active" else "Stopped")

        FlowMode.entries.forEach { mode ->
            Button(
                onClick = { viewModel.onModeSelected(mode) },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(text = "${mode.name.lowercase().replaceFirstChar(Char::uppercase)} (${mode.beatHz}Hz)")
            }
        }

        Text(text = "Beat volume: ${"%.2f".format(beatVolume)}")
        Slider(value = beatVolume, onValueChange = viewModel::onBeatVolumeChanged)

        Button(onClick = viewModel::pickFile, modifier = Modifier.fillMaxWidth()) {
            Text(if (selectedFile == null) "Pick file" else "Change file")
        }

        Text(text = selectedFile ?: "No file selected")

        if (isActive) {
            Button(onClick = viewModel::stopSession, modifier = Modifier.fillMaxWidth()) {
                Text("Stop Session")
            }
        } else {
            Button(onClick = viewModel::startSession, modifier = Modifier.fillMaxWidth()) {
                Text("Start Session")
            }
        }

        Text(text = "Current mode: ${currentMode.name.lowercase().replaceFirstChar(Char::uppercase)}")
    }
}
