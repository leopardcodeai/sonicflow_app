package com.sonicflow.app.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.sonicflow.app.R
import com.sonicflow.app.brand.BrandTokens
import com.sonicflow.app.ui.components.LeopardBackground
import com.sonicflow.app.ui.components.ModeCard
import com.sonicflow.app.ui.components.VisualizerBars
import com.sonicflow.beatengine.FlowMode

@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(viewModel: FlowTonesViewModel) {
    val currentMode by viewModel.currentMode.collectAsState()
    val isActive by viewModel.isActive.collectAsState()
    val beatVolume by viewModel.beatVolume.collectAsState()
    val durationMinutes by viewModel.durationMinutes.collectAsState()
    val ambientMix by viewModel.ambientMix.collectAsState()
    val pulseDepth by viewModel.pulseDepth.collectAsState()
    val selectedFile by viewModel.selectedFile.collectAsState()

    val accent = currentMode.modeColor

    Box(modifier = Modifier.fillMaxSize()) {
        LeopardBackground()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(
                    horizontal = BrandTokens.Spacing.md.dp,
                    vertical = BrandTokens.Spacing.sm.dp
                ),
            verticalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.md.dp)
        ) {
            TopAppBar(
                title = { Text("SonicFlow") },
                actions = {
                    AssistChip(
                        onClick = {},
                        label = { Text(if (isActive) "Active" else "Off") }
                    )
                }
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.sm.dp)
            ) {
                Image(
                    painter = painterResource(id = R.drawable.bowl_hero),
                    contentDescription = "Golden singing bowl",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier
                        .size(72.dp)
                        .clip(RoundedCornerShape(24.dp))
                )

                Column(
                    verticalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.xs.dp)
                ) {
                    Text(
                        text = "FlowTones Runtime",
                        style = MaterialTheme.typography.labelMedium,
                        color = BrandTokens.Accent.gold
                    )
                    Text(
                        text = "${currentMode.label} session",
                        style = MaterialTheme.typography.titleLarge,
                        color = BrandTokens.Neutral.fg
                    )
                    Text(
                        text = "Leopard-backed ambience with preset-driven pulse shaping and timed playback.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.sm.dp),
                verticalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.sm.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 220.dp)
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

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Duration", style = MaterialTheme.typography.labelLarge)
                Text("$durationMinutes min", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Slider(
                value = durationMinutes.toFloat(),
                onValueChange = { viewModel.onDurationMinutesChanged(it.toInt()) },
                valueRange = 5f..60f,
                steps = 10
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Ambient mix", style = MaterialTheme.typography.labelLarge)
                Text("${(ambientMix * 100).toInt()}%", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Slider(
                value = ambientMix,
                onValueChange = viewModel::onAmbientMixChanged,
                valueRange = 0.2f..1f
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Pulse depth", style = MaterialTheme.typography.labelLarge)
                Text("${(pulseDepth * 100).toInt()}%", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Slider(
                value = pulseDepth,
                onValueChange = viewModel::onPulseDepthChanged,
                valueRange = 0.2f..1f
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
}
