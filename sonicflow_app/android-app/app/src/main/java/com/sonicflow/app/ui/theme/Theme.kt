package com.sonicflow.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.sonicflow.app.ui.fromHex

private val FlowTonesDarkScheme = darkColorScheme(
    primary = Color.fromHex("#378ADD"),
    secondary = Color.fromHex("#7F77DD"),
    tertiary = Color.fromHex("#1D9E75")
)

@Composable
fun FlowTonesTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = FlowTonesDarkScheme,
        content = content
    )
}
