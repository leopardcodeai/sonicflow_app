package com.sonicflow.app.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.sonicflow.app.brand.BrandTokens
import com.sonicflow.app.ui.label
import com.sonicflow.app.ui.modeColor
import com.sonicflow.beatengine.FlowMode

@Composable
fun ModeCard(
    mode: FlowMode,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val accent = mode.modeColor
    val cardShape = RoundedCornerShape(BrandTokens.Radius.md.dp)

    // Active cards get a layered glow: a tight inner shadow plus a softer outer
    // bloom at 30% alpha, matching the CSS `modeGlow` token from brand/tokens.json.
    val glowModifier = if (selected) {
        Modifier
            .shadow(
                elevation = 64.dp,
                shape = cardShape,
                ambientColor = accent.copy(alpha = 0.30f),
                spotColor = accent.copy(alpha = 0.30f)
            )
            .shadow(
                elevation = 24.dp,
                shape = cardShape,
                ambientColor = accent,
                spotColor = accent
            )
    } else {
        Modifier
    }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .then(glowModifier)
            .clickable(onClick = onClick),
        shape = cardShape,
        colors = CardDefaults.cardColors(
            containerColor = BrandTokens.Neutral.panel
        ),
        border = BorderStroke(
            width = if (selected) 2.dp else 1.dp,
            color = if (selected) accent else BrandTokens.Neutral.border
        )
    ) {
        Column(
            modifier = Modifier.padding(BrandTokens.Spacing.md.dp),
            verticalArrangement = Arrangement.spacedBy(BrandTokens.Spacing.xs.dp + 2.dp)
        ) {
            Icon(Icons.Default.GraphicEq, contentDescription = null, tint = accent)
            Text(text = mode.label, fontSize = 16.sp, color = BrandTokens.Neutral.fg)
            Text(
                text = "${mode.beatHz} Hz",
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                fontSize = 12.sp
            )
        }
    }
}
