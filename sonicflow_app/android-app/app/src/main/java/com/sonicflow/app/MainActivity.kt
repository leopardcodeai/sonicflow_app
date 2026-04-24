package com.sonicflow.app

import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.lifecycle.lifecycleScope
import com.sonicflow.app.ui.MainScreen
import com.sonicflow.app.ui.SonicFlowViewModel
import com.sonicflow.app.ui.theme.SonicFlowTheme
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.launch

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private val viewModel: SonicFlowViewModel by viewModels()

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
            SonicFlowTheme {
                MainScreen(viewModel)
            }
        }
    }
}
