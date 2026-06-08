package io.aban.admob_nextgen.consent

import android.app.Activity
import android.content.Context
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.FormError
import com.google.android.ump.UserMessagingPlatform
import io.flutter.plugin.common.MethodChannel

class ConsentManager(private val context: Context) {

    private val consentInformation: ConsentInformation =
        UserMessagingPlatform.getConsentInformation(context)

    var activity: Activity? = null

    fun requestConsentInfoUpdate(
        params: Map<String, Any?>?,
        result: MethodChannel.Result,
    ) {
        val act = activity
        if (act == null) {
            result.error(
                "NO_ACTIVITY",
                "Activity is not available to request consent information.",
                null,
            )
            return
        }

        consentInformation.requestConsentInfoUpdate(
            act,
            buildConsentRequestParameters(act, params),
            { result.success(null) },
            { error -> result.success(error.toMap()) },
        )
    }

    fun loadAndShowConsentFormIfRequired(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error(
                "NO_ACTIVITY",
                "Activity is not available to show the consent form.",
                null,
            )
            return
        }
        UserMessagingPlatform.loadAndShowConsentFormIfRequired(act) { error ->
            result.success(error?.toMap())
        }
    }

    fun showPrivacyOptionsForm(result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.error(
                "NO_ACTIVITY",
                "Activity is not available to show privacy options.",
                null,
            )
            return
        }
        UserMessagingPlatform.showPrivacyOptionsForm(act) { error ->
            result.success(error?.toMap())
        }
    }

    fun canRequestAds(): Boolean = consentInformation.canRequestAds()

    fun isConsentFormAvailable(): Boolean = consentInformation.isConsentFormAvailable

    fun getConsentStatus(): String =
        when (consentInformation.consentStatus) {
            1 -> "required"
            2 -> "notRequired"
            3 -> "obtained"
            else -> "unknown"
        }

    fun getPrivacyOptionsRequirementStatus(): String =
        when (consentInformation.privacyOptionsRequirementStatus) {
            ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED -> "required"
            ConsentInformation.PrivacyOptionsRequirementStatus.NOT_REQUIRED -> "notRequired"
            else -> "unknown"
        }

    fun reset() {
        consentInformation.reset()
    }

    @Suppress("UNCHECKED_CAST")
    private fun buildConsentRequestParameters(
        activity: Activity,
        params: Map<String, Any?>?,
    ): ConsentRequestParameters {
        val builder = ConsentRequestParameters.Builder()
        (params?.get("tagForUnderAgeOfConsent") as? Boolean)?.let {
            builder.setTagForUnderAgeOfConsent(it)
        }
        val debugParams = params?.get("consentDebugSettings") as? Map<String, Any?>
        if (debugParams != null) {
            val debugBuilder = ConsentDebugSettings.Builder(activity)
            (debugParams["debugGeography"] as? Number)?.let {
                debugBuilder.setDebugGeography(it.toInt())
            }
            (debugParams["testIdentifiers"] as? List<*>)?.forEach {
                if (it is String) debugBuilder.addTestDeviceHashedId(it)
            }
            builder.setConsentDebugSettings(debugBuilder.build())
        }
        return builder.build()
    }

    private fun FormError.toMap(): Map<String, Any?> =
        mapOf("errorCode" to errorCode, "message" to message)
}