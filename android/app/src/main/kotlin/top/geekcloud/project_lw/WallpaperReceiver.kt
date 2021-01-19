package top.geekcloud.project_lw

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class WallpaperReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "WallpaperReceiver"

        const val ACTION_TEST = "com.lingyun.ACTION_TEST"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: ${intent.action}")

        if (context !is LWService) return

        val wallpaperService = context as LWService

        when(intent.action) {
            ACTION_TEST -> {
                // ...
            }
        }
    }
}