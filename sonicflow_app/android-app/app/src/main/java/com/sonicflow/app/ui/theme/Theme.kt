package com.sonicflow.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import com.sonicflow.app.brand.BrandTokens

private val FlowTonesDarkScheme = darkColorScheme(
    primary = BrandTokens.Chakra.throat,
    onPrimary = BrandTokens.Neutral.fg,
    secondary = BrandTokens.Chakra.thirdEye,
    onSecondary = BrandTokens.Neutral.fg,
    tertiary = BrandTokens.Chakra.heart,
    onTertiary = BrandTokens.Neutral.fg,
    background = BrandTokens.Neutral.bg,
    onBackground = BrandTokens.Neutral.fg,
    surface = BrandTokens.Neutral.ink,
    onSurface = BrandTokens.Neutral.fg,
    surfaceVariant = BrandTokens.Neutral.border,
    onSurfaceVariant = BrandTokens.Neutral.muted,
    outline = BrandTokens.Neutral.border,
    error = BrandTokens.Accent.danger,
    onError = BrandTokens.Neutral.fg
)

@Composable
fun FlowTonesTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = FlowTonesDarkScheme,
        content = content
    )
}
