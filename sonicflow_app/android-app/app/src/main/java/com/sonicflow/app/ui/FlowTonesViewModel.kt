package com.sonicflow.app.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.sonicflow.app.audio.FlowTonesSessionController
import com.sonicflow.app.audio.SessionCommand
import com.sonicflow.beatengine.FlowMode
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class FlowTonesViewModel @Inject constructor(
    private val controller: FlowTonesSessionController
) : ViewModel() {

    private val mutableCurrentMode = MutableStateFlow(FlowMode.FOCUS)
    val currentMode: StateFlow<FlowMode> = mutableCurrentMode.asStateFlow()

    private val mutableIsActive = MutableStateFlow(false)
    val isActive: StateFlow<Boolean> = mutableIsActive.asStateFlow()

    private val mutableBeatVolume = MutableStateFlow(0.15f)
    val beatVolume: StateFlow<Float> = mutableBeatVolume.asStateFlow()

    private val mutableDurationMinutes = MutableStateFlow(25)
    val durationMinutes: StateFlow<Int> = mutableDurationMinutes.asStateFlow()

    private val mutableAmbientMix = MutableStateFlow(0.45f)
    val ambientMix: StateFlow<Float> = mutableAmbientMix.asStateFlow()

    private val mutablePulseDepth = MutableStateFlow(0.95f)
    val pulseDepth: StateFlow<Float> = mutablePulseDepth.asStateFlow()

    private val mutableSelectedFile = MutableStateFlow<String?>(null)
    val selectedFile: StateFlow<String?> = mutableSelectedFile.asStateFlow()

    private val offlineCache = OfflineSessionCache()
    private val mutableNetworkAvailable = MutableStateFlow(true)
    private val mutableOfflineAssetId = MutableStateFlow<String?>(null)
    val offlineAssetId: StateFlow<String?> = mutableOfflineAssetId.asStateFlow()

    private val mutableOfflineAvailability = MutableStateFlow(OfflineSessionAvailability.NOT_DOWNLOADED.label)
    val offlineAvailability: StateFlow<String> = mutableOfflineAvailability.asStateFlow()

    private val mutableOverlayModeStatus = MutableStateFlow(
        "Overlay Mode: Android external app capture requires policy review; local sessions remain available."
    )
    val overlayModeStatus: StateFlow<String> = mutableOverlayModeStatus.asStateFlow()

    private val mutableFilePickerEvents = MutableSharedFlow<Unit>()
    val filePickerEvents: SharedFlow<Unit> = mutableFilePickerEvents.asSharedFlow()

    init {
        viewModelScope.launch {
            controller.state.collectLatest { session ->
                mutableCurrentMode.value = session.mode
                mutableIsActive.value = session.isActive
                mutableBeatVolume.value = session.beatVolume
                mutableDurationMinutes.value = session.durationMinutes
                mutableAmbientMix.value = session.ambientMix
                mutablePulseDepth.value = session.pulseDepth
                mutableSelectedFile.value = session.selectedFile
                mutableOfflineAssetId.value = session.offlineAssetId
            }
        }
    }

    fun onModeSelected(mode: FlowMode) {
        mutableCurrentMode.value = mode
        refreshOfflineAvailability()
    }

    fun setMode(mode: FlowMode) {
        onModeSelected(mode)
    }

    fun onBeatVolumeChanged(volume: Float) {
        mutableBeatVolume.value = volume.coerceIn(0f, 1f)
    }

    fun onDurationMinutesChanged(minutes: Int) {
        mutableDurationMinutes.value = minutes.coerceIn(5, 60)
        refreshOfflineAvailability()
    }

    fun onAmbientMixChanged(value: Float) {
        mutableAmbientMix.value = value.coerceIn(0.2f, 1f)
        refreshOfflineAvailability()
    }

    fun onPulseDepthChanged(value: Float) {
        mutablePulseDepth.value = value.coerceIn(0.2f, 1f)
        refreshOfflineAvailability()
    }

    fun onFileSelected(file: String?) {
        mutableSelectedFile.value = file
    }

    fun applyExample(example: FlowToneExample) {
        mutableCurrentMode.value = example.preset.mode
        mutableDurationMinutes.value = example.durationMinutes
        mutableAmbientMix.value = example.ambientMix
        mutablePulseDepth.value = example.pulseDepth
        refreshOfflineAvailability()
    }

    fun startSession() {
        val offlineId = currentOfflineAsset().id.takeIf {
            !mutableNetworkAvailable.value &&
                offlineCache.availability(it) == OfflineSessionAvailability.DOWNLOADED
        }
        controller.send(
            SessionCommand.Start(
                mode = currentMode.value,
                beatVolume = beatVolume.value,
                durationMinutes = durationMinutes.value,
                ambientMix = ambientMix.value,
                pulseDepth = pulseDepth.value,
                selectedFile = selectedFile.value,
                offlineAssetId = offlineId
            )
        )
    }

    fun stopSession() {
        controller.send(SessionCommand.Stop)
    }

    fun pickFile() {
        viewModelScope.launch {
            mutableFilePickerEvents.emit(Unit)
        }
    }

    fun setNetworkAvailable(available: Boolean) {
        mutableNetworkAvailable.value = available
    }

    fun downloadCurrentSession(byteCount: Int = 700_000): Boolean {
        val asset = currentOfflineAsset(byteCount)
        val stored = offlineCache.store(asset)
        refreshOfflineAvailability(asset.id)
        return stored
    }

    fun deleteCurrentSessionDownload() {
        val assetId = currentOfflineAsset().id
        offlineCache.delete(assetId)
        refreshOfflineAvailability(assetId)
    }

    private fun currentOfflineAsset(byteCount: Int = 0): OfflineSessionAsset {
        return OfflineSessionAsset.from(
            mode = currentMode.value,
            durationMinutes = durationMinutes.value,
            ambientMix = ambientMix.value,
            pulseDepth = pulseDepth.value,
            byteCount = byteCount
        )
    }

    private fun refreshOfflineAvailability(assetId: String = currentOfflineAsset().id) {
        val availability = offlineCache.availability(assetId)
        mutableOfflineAssetId.value = assetId
        mutableOfflineAvailability.value = availability.label
    }
}
