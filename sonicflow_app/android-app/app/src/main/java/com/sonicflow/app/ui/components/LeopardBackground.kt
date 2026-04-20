package com.sonicflow.app.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.sonicflow.app.R

@Composable
fun LeopardBackground(modifier: Modifier = Modifier) {
    Image(
        painter = painterResource(id = R.drawable.leopard_wallpaper),
        contentDescription = null,
        contentScale = ContentScale.Crop,
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFF09090B))
            .alpha(0.9f)
    )
}
