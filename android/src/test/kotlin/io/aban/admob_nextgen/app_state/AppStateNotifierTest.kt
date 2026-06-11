package io.aban.admob_nextgen.app_state

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import io.flutter.plugin.common.BinaryMessenger
import org.mockito.Mockito
import kotlin.test.Test

internal class AppStateNotifierTest {
    @Test
    fun startAndStopAreIdempotent() {
        val messenger = Mockito.mock(BinaryMessenger::class.java)
        val lifecycle = RecordingLifecycle()
        val notifier = AppStateNotifier(messenger, lifecycle)

        notifier.start()
        notifier.start()
        notifier.stop()
        notifier.stop()

        kotlin.test.assertEquals(1, lifecycle.addCount)
        kotlin.test.assertEquals(1, lifecycle.removeCount)
    }

    @Test
    fun disposeStopsActiveObservation() {
        val messenger = Mockito.mock(BinaryMessenger::class.java)
        val lifecycle = RecordingLifecycle()
        val notifier = AppStateNotifier(messenger, lifecycle)

        notifier.start()
        notifier.dispose()

        kotlin.test.assertEquals(1, lifecycle.removeCount)
    }

    private class RecordingLifecycle : Lifecycle() {
        var addCount = 0
        var removeCount = 0

        override fun addObserver(observer: LifecycleObserver) {
            addCount++
        }

        override fun removeObserver(observer: LifecycleObserver) {
            removeCount++
        }

        override val currentState: State = State.CREATED
    }
}
