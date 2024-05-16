package com.example.recipie_app

import android.os.Bundle
import androidx.annotation.NonNull
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.MobileAds
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAd.OnNativeAdLoadedListener
import com.google.android.gms.ads.nativead.NativeAdOptions
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.recipie_app/ad"
    private var nativeAd: NativeAd? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MobileAds.initialize(this) {}
        loadNativeAd()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAdDetails") {
                val adDetails = getAdDetails()
                if (adDetails != null) {
                    result.success(adDetails)
                } else {
                    result.error("UNAVAILABLE", "Ad details not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun loadNativeAd() {
        val adLoader = com.google.android.gms.ads.AdLoader.Builder(this, "ca-app-pub-3940256099942544/2247696110")
            .forNativeAd(OnNativeAdLoadedListener { ad: NativeAd ->
                nativeAd = ad
            })
            .withAdListener(object : com.google.android.gms.ads.AdListener() {
                override fun onAdFailedToLoad(adError: LoadAdError) {
                    // Handle the error
                }
            })
            .withNativeAdOptions(NativeAdOptions.Builder().build())
            .build()
        adLoader.loadAd(AdRequest.Builder().build())
    }

    private fun getAdDetails(): Map<String, Any>? {
        nativeAd?.let { ad ->
            return mapOf(
                "title" to (ad.headline ?: ""),
                "description" to (ad.body ?: ""),
                "imageUrl" to (ad.images.firstOrNull()?.uri?.toString() ?: ""),
                "iconUrl" to (ad.icon?.uri?.toString() ?: ""),
                "callToAction" to (ad.callToAction ?: "")
            )
        }
        return null
    }
}
