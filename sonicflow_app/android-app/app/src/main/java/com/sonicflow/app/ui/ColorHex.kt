package com.sonicflow.app.ui

import androidx.compose.ui.graphics.Color

fun Color.Companion.fromHex(hex: String): Color {
    val normalized = hex.removePrefix("#")
    val colorLong = when (normalized.length) {
        6 -> ("FF" + normalized).toLong(16)
        8 -> normalized.toLong(16)
        else -> error("Invalid hex color: $hex")
    }
    return Color(colorLong)
}

fun Color.toHexString(): String {
    val r = (red * 255f).toInt().coerceIn(0, 255)
    val g = (green * 255f).toInt().coerceIn(0, 255)
    val b = (blue * 255f).toInt().coerceIn(0, 255)
    return "#%02X%02X%02X".format(r, g, b)
}
