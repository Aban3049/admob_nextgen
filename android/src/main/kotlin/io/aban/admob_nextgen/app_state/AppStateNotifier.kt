package io.aban.admob_nextgen.app_state

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class AppStateNotifier(
    binaryMessenger: BinaryMessenger,
    private val lifecycle: Lifecycle = ProcessLifecycleOwner.get().lifecycle,
) : LifecycleEventObserver, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val METHOD_CHANNEL_NAME = "admob_nextgen/app_state_method"
        private const val EVENT_CHANNEL_NAME = "admob_nextgen/app_state_event"
    }

    private val methodChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL_NAME)
    private val eventChannel = EventChannel(binaryMessenger, EVENT_CHANNEL_NAME)
    private var eventSink: EventChannel.EventSink? = null
    private var isStarted = false

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun start() {
        if (isStarted) return
        isStarted = true
        lifecycle.addObserver(this)
    }

    fun stop() {
        if (!isStarted) return
        isStarted = false
        lifecycle.removeObserver(this)
    }

    fun dispose() {
        stop()
        eventSink = null
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                start()
                result.success(null)
            }
            "stop" -> {
                stop()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_START -> eventSink?.success("foreground")
            Lifecycle.Event.ON_STOP -> eventSink?.success("background")
            else -> Unit
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
