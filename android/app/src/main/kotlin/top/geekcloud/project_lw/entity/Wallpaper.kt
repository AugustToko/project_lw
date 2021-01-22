package top.geekcloud.project_lw.entity

import android.content.Context
import java.io.File

data class Wallpaper(
        val author: String,
        val description: String,
        val id: String,
        val name: String,
        val path: String,
//        val thumbnails: List<String>,
        val versionCode: Int,
        val versionName: String,
        val wallpaperType: Int
) {
    companion object {
        const val HTML = 0
        const val VIDEO = 1
        const val VIEW = 2
        const val IMAGE = 3
    }
    
    fun getRealPath(context: Context) : String {
        if (path.startsWith("http")) return path
        
        return context.filesDir.path.toString() + File.separatorChar + id + File.separator + path
    }
}
