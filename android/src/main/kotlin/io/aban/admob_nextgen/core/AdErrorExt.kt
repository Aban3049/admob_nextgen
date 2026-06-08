package io.aban.admob_nextgen.core

import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError

internal fun codecSafeErrorMap(code: Int, message: String): Map<String, Any> =
    mapOf(
        "code" to code,
        "message" to message,
    )

internal fun LoadAdError.toFlutterMap(): Map<String, Any> =
    codecSafeErrorMap(code.value, message)

internal fun FullScreenContentError.toFlutterMap(): Map<String, Any> =
    codecSafeErrorMap(code.value, message)
