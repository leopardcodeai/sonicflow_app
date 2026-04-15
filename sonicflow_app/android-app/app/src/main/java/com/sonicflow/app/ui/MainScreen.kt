package com.sonicflow.app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.AssistChip
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.sonicflow.app.ui.components.ModeCard
import com.sonicflow.app.ui.components.VisualizerBars
import com.sonicflow.beatengine.FlowMode

@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(viewModel: FlowTonesViewModel) {
    val currentMode by viewModel.currentMode.collectAsState()
    val isActive by viewModel.isActive.collectAsState()
    val beatVolume by viewModel.beatVolume.collectAsState()
    val selectedFile by viewModel.selectedFile.collectAsState()

    val accent = androidx.compose.ui.graphics.Color.fromHex(currentMode.accentColor)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        TopAppBar(
            title = { Text("FlowTones") },
            actions = {
                AssistChip(
                    onClick = {},
                    label = { Text(if (isActive) "Active" else "Off") }
                )
            }
        )

        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            items(FlowMode.entries) { mode ->
                ModeCard(
                    mode = mode,
                    selected = currentMode == mode,
                    onClick = { viewModel.setMode(mode) }
                )
            }
        }

        Text(text = "Neural layer", style = MaterialTheme.typography.labelLarge)
        Slider(
            value = beatVolume,
            onValueChange = viewModel::onBeatVolumeChanged,
            valueRange = 0f..1f
        )

        VisualizerBars(isActive = isActive, color = accent)

        Button(onClick = viewModel::pickFile, modifier = Modifier.fillMaxWidth()) {
            Text(if (selectedFile.isNullOrBlank()) "Pick file" else "Change file")
        }

        Button(
            onClick = { if (isActive) viewModel.stopSession() else viewModel.startSession() },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (isActive) "Stop" else "Start")
        }

        Text(
            text = selectedFile ?: "No file selected",
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
