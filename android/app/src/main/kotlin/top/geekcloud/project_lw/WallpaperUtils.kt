package top.geekcloud.project_lw

import android.content.Context
import com.google.gson.Gson
import top.geekcloud.project_lw.entity.Wallpaper

class WallpaperUtils {
    companion object {
        fun getCurrentWallpaper(context: Context): Wallpaper {
            val preferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val wallpaper = preferences.getString("flutter.LAST_WALLPAPER", null)
            return Gson().fromJson(wallpaper, Wallpaper::class.java)
        }
    }
}