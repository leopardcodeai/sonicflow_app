package com.sonicflow.app.ui

import com.sonicflow.beatengine.FlowMode
import java.security.MessageDigest
import java.util.Locale

enum class OfflineSessionAvailability(val label: String) {
    NOT_DOWNLOADED("Not downloaded"),
    DOWNLOADED("Downloaded for offline"),
    STORAGE_FULL("Storage full")
}

data class OfflineSessionAsset(
    val id: String,
    val mode: FlowMode,
    val durationMinutes: Int,
    val ambientMix: Float,
    val pulseDepth: Float,
    val byteCount: Int
) {
    companion object {
        fun from(
            mode: FlowMode,
            durationMinutes: Int,
            ambientMix: Float,
            pulseDepth: Float,
            byteCount: Int
        ): OfflineSessionAsset {
            val canonical = listOf(
                mode.name,
                durationMinutes.coerceIn(5, 60).toString(),
                "%.3f".format(Locale.US, ambientMix.coerceIn(0.2f, 1f)),
                "%.3f".format(Locale.US, pulseDepth.coerceIn(0.2f, 1f))
            ).joinToString("|")
            val digest = MessageDigest.getInstance("SHA-256")
                .digest(canonical.toByteArray(Charsets.UTF_8))
                .take(6)
                .joinToString("") { "%02x".format(Locale.US, it) }

            return OfflineSessionAsset(
                id = digest,
                mode = mode,
                durationMinutes = durationMinutes.coerceIn(5, 60),
                ambientMix = ambientMix.coerceIn(0.2f, 1f),
                pulseDepth = pulseDepth.coerceIn(0.2f, 1f),
                byteCount = byteCount.coerceAtLeast(0)
            )
        }
    }
}

class OfflineSessionCache(
    private val storageLimitBytes: Int = 1_000_000
) {
    private val assets = linkedMapOf<String, OfflineSessionAsset>()
    private val blockedAssetIds = mutableSetOf<String>()

    val usedBytes: Int
        get() = assets.values.sumOf { it.byteCount }

    fun store(asset: OfflineSessionAsset): Boolean {
        val currentBytes = assets[asset.id]?.byteCount ?: 0
        val projectedBytes = usedBytes - currentBytes + asset.byteCount
        if (projectedBytes > storageLimitBytes) {
            blockedAssetIds += asset.id
            return false
        }

        blockedAssetIds -= asset.id
        assets[asset.id] = asset
        return true
    }

    fun delete(assetId: String) {
        assets.remove(assetId)
        blockedAssetIds -= assetId
    }

    fun availability(assetId: String): OfflineSessionAvailability {
        return when {
            assets.containsKey(assetId) -> OfflineSessionAvailability.DOWNLOADED
            blockedAssetIds.contains(assetId) -> OfflineSessionAvailability.STORAGE_FULL
            else -> OfflineSessionAvailability.NOT_DOWNLOADED
        }
    }
}
