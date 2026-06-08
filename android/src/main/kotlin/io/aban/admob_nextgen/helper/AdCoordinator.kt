package io.aban.admob_nextgen.helper

internal class FullScreenAdCoordinator {
    private var activeAdId: String? = null

    @Synchronized
    fun tryAcquire(adId: String): Boolean {
        if (activeAdId != null) return false
        activeAdId = adId
        return true
    }

    @Synchronized
    fun release(adId: String) {
        if (activeAdId == adId) activeAdId = null
    }

    @Synchronized
    fun isActive(adId: String): Boolean = activeAdId == adId
}
