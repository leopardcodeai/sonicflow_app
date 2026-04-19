package com.sonicflow.app.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.sonicflow.app.brand.BrandTokens
import kotlin.random.Random

/**
 * Deterministic seed for the procedural leopard pattern. Keeping it constant means
 * the spot layout doesn't shift between recompositions or cold starts.
 */
private const val LEOPARD_SEED: Long = 0x1E07A2DA1L

/**
 * Procedural leopard-print background layer. Draws filled and ringed circles at
 * deterministic positions on top of [BrandTokens.Leopard.base], blurred for the
 * Leopard Look. Sits behind a blurred panel — never directly under body text.
 */
@Composable
fun LeopardBackground(
    modifier: Modifier = Modifier,
    spotCount: Int = BrandTokens.Leopard.spotCount,
    seed: Long = LEOPARD_SEED
) {
    Canvas(
        modifier = modifier
            .fillMaxSize()
            .background(BrandTokens.Leopard.base)
            .blur(BrandTokens.Leopard.blurPx.dp)
    ) {
        val random = Random(seed)
        val minRadius = BrandTokens.Leopard.spotMinPx.toFloat() / 2f
        val maxRadius = BrandTokens.Leopard.spotMaxPx.toFloat() / 2f
        val w = size.width
        val h = size.height
        val spotColor = BrandTokens.Leopard.spot.copy(alpha = BrandTokens.Leopard.opacity)
        val ringColor = BrandTokens.Leopard.ring.copy(alpha = BrandTokens.Leopard.opacity)

        repeat(spotCount) {
            val radius = minRadius + random.nextFloat() * (maxRadius - minRadius)
            val cx = random.nextFloat() * w
            val cy = random.nextFloat() * h
            val center = Offset(cx, cy)

            drawCircle(
                color = ringColor,
                radius = radius * 1.35f,
                center = center,
                style = Stroke(width = radius * 0.22f)
            )
            drawCircle(
                color = spotColor,
                radius = radius,
                center = center
            )
        }
    }
}
