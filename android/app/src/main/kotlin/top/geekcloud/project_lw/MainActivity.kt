package top.geekcloud.project_lw

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import top.geekcloud.project_lw.entity.Wallpaper

class MainActivity : FlutterActivity() {
    private val flutterChannelName = "lingyun_lw_channel_1"

    companion object {
        var methodChannel: MethodChannel? = null

        const val CLEAR_WALLPAPER = "CLEAR_WALLPAPER"
        const val GOTO_WALLPAPER_CHOOSER = "GOTO_WALLPAPER_CHOOSER"
        const val BACK_HOME = "BACK_HOME"
        const val SET_WALLPAPER = "SET_WALLPAPER"
        const val TAG = "MainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(getFlutterEngine()!!.dartExecutor.binaryMessenger, flutterChannelName)
        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                CLEAR_WALLPAPER -> {
                    WallpaperManager.getInstance(this).clear()
                    result.success(null)
                }
                GOTO_WALLPAPER_CHOOSER -> {
                    gotoWallpaperSettings()
                    result.success(null)
                }
                BACK_HOME -> {
                    val intent = Intent(Intent.ACTION_MAIN)
                    intent.addCategory(Intent.CATEGORY_HOME)
                    startActivity(intent)
                }
                SET_WALLPAPER -> {
                    val wallpaperObj = WallpaperUtils.getCurrentWallpaper(this)

                    if (wallpaperObj.wallpaperType == Wallpaper.IMAGE) {
                        val wm = WallpaperManager.getInstance(this)
                        wm.setBitmap(BitmapFactory.decodeFile(wallpaperObj.getRealPath(this)))
                    } else {
                        //                    val preferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//                    val editor = preferences.edit()
//                    Log.d(TAG, "configureFlutterEngine: $wallpaper")
                        gotoWallpaperSettings()
                    }
                }
            }
        }
    }

    private fun gotoWallpaperSettings() {
        val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
        intent.putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT, ComponentName(this, LWService::class.java))
        startActivity(intent)
    }
}
