package top.geekcloud.project_lw

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.Presentation
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.hardware.display.DisplayManager
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.opengl.GLSurfaceView
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.util.DisplayMetrics
import android.util.Log
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.ViewGroup
import android.webkit.*
import android.webkit.WebView
import android.widget.Toast
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.util.Util
import com.google.gson.Gson
import top.geekcloud.project_lw.entity.Wallpaper
import java.io.File
import java.io.IOException

class LWService : WallpaperService() {
    companion object {
        // We can have multiple engines running at once (since you might have one on your home screen
        // and another in the settings panel, for instance), so for debugging it's useful to keep track
        // of which one is which. We give each an id based on this nextEngineId.
        var nextEngineId = 1

        const val TAG = "MyLWPService"
    }

    private val receiver = WallpaperReceiver()

    override fun onCreate() {
        Log.d(TAG, "onCreate: ThreadId: ${Thread.currentThread().id}")
        Log.d(TAG, "className: ${applicationInfo.className}")
        Log.d(TAG, "descriptionRes: ${applicationInfo.descriptionRes}")
        Log.d(TAG, "processName: ${applicationInfo.processName}")

        val intentFilter = IntentFilter()
        intentFilter.addAction(WallpaperReceiver.ACTION_TEST)
        LocalBroadcastManager.getInstance(applicationContext).registerReceiver(
                receiver,
                intentFilter
        )
    }

    override fun onCreateEngine(): Engine {
        Log.d(TAG, "onCreateEngine: ")
        val preferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val wallpaper = preferences.getString("flutter.LAST_WALLPAPER", null)
                ?: return EmptyWallpaperEngine()

        Log.d(TAG, "----------------------onCreateEngine: $wallpaper")

        val wallpaperObj = Gson().fromJson(wallpaper, Wallpaper::class.java)

        return when (wallpaperObj.wallpaperType) {
            Wallpaper.HTML -> WebWallpaperEngine(this, wallpaperObj)
            Wallpaper.VIDEO -> GLWallpaperEngine(this, wallpaperObj)
            Wallpaper.VIEW -> WebWallpaperEngine(this, wallpaperObj)
            Wallpaper.IMAGE -> null!!
            else -> EmptyWallpaperEngine()
        }
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: ")
        LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(receiver)
        super.onDestroy()
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    inner class EmptyWallpaperEngine : Engine() {
        private val myId: Int = nextEngineId

        init {
            nextEngineId++
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    internal inner class GLWallpaperEngine(private val context: Context, private val wallpaper: Wallpaper) : Engine() {
        private var glSurfaceView: GLWallpaperSurfaceView? = null
        private var exoPlayer: SimpleExoPlayer? = null
        private var videoSource: MediaSource? = null
        private var trackSelector: DefaultTrackSelector? = null
        private var renderer: GLWallpaperRenderer? = null
        private var allowSlide = false
        private var videoRotation = 0
        private var videoWidth = 0
        private var videoHeight = 0
        private var progress: Long = 0

        private inner class GLWallpaperSurfaceView(context: Context?) : GLSurfaceView(context) {
            /**
             * This is a hack. Because Android Live Wallpaper only has a Surface.
             * So we create a GLSurfaceView, and when drawing to its Surface,
             * we replace it with WallpaperEngine's Surface.
             */
            override fun getHolder(): SurfaceHolder {
                return surfaceHolder
            }

            fun onDestroy() {
                super.onDetachedFromWindow()
            }

        }

        override fun onCreate(surfaceHolder: SurfaceHolder) {
            super.onCreate(surfaceHolder)
            val pref = getSharedPreferences(
                    MyApplication.OPTIONS_PREF, MODE_PRIVATE
            )
            allowSlide = pref.getBoolean(MyApplication.SLIDE_WALLPAPER_KEY, false)
        }

        override fun onSurfaceCreated(surfaceHolder: SurfaceHolder) {
            super.onSurfaceCreated(surfaceHolder)
            createGLSurfaceView()
            val width = surfaceHolder.surfaceFrame.width()
            val height = surfaceHolder.surfaceFrame.height()
            renderer!!.setScreenSize(width, height)
            startPlayer()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            if (renderer != null) {
                if (visible) {
                    val pref = getSharedPreferences(
                            MyApplication.OPTIONS_PREF, MODE_PRIVATE
                    )
                    allowSlide = pref.getBoolean(MyApplication.SLIDE_WALLPAPER_KEY, false)
                    glSurfaceView!!.onResume()
                    startPlayer()
                } else {
                    stopPlayer()
                    glSurfaceView!!.onPause()
                    // Prevent useless renderer calculating.
                    allowSlide = false
                }
            }
        }

        override fun onOffsetsChanged(
                xOffset: Float, yOffset: Float,
                xOffsetStep: Float, yOffsetStep: Float,
                xPixelOffset: Int, yPixelOffset: Int,
        ) {
            super.onOffsetsChanged(
                    xOffset, yOffset, xOffsetStep,
                    yOffsetStep, xPixelOffset, yPixelOffset
            )
            if (allowSlide && !isPreview) {
                renderer!!.setOffset(0.5f - xOffset, 0.5f - yOffset)
            }
        }

        override fun onSurfaceChanged(
                surfaceHolder: SurfaceHolder, format: Int,
                width: Int, height: Int,
        ) {
            super.onSurfaceChanged(surfaceHolder, format, width, height)
            renderer!!.setScreenSize(width, height)
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            stopPlayer()
            glSurfaceView!!.onDestroy()
        }

        private fun createGLSurfaceView() {
            if (glSurfaceView != null) {
                glSurfaceView!!.onDestroy()
                glSurfaceView = null
            }
            glSurfaceView = GLWallpaperSurfaceView(context)
            val activityManager = getSystemService(
                    ACTIVITY_SERVICE
            ) as ActivityManager
            val configInfo = activityManager.deviceConfigurationInfo
            renderer = when {
                configInfo.reqGlEsVersion >= 0x30000 -> {
                    Log.d(TAG, "Support GLESv3")
                    glSurfaceView!!.setEGLContextClientVersion(3)
                    GLES30WallpaperRenderer(context)
                }
                configInfo.reqGlEsVersion >= 0x20000 -> {
                    Log.d(TAG, "Fallback to GLESv2")
                    glSurfaceView!!.setEGLContextClientVersion(2)
                    GLES20WallpaperRenderer(context)
                }
                else -> {
                    Toast.makeText(context, "Needs to support GLESv2 or higher version!", Toast.LENGTH_LONG).show()
                    throw RuntimeException("Needs GLESv2 or higher")
                }
            }
            glSurfaceView!!.preserveEGLContextOnPause = true
            glSurfaceView!!.setRenderer(renderer)
            // On demand render will lead to black screen.
            glSurfaceView!!.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        }

        @Throws(IOException::class)
        private fun getVideoMetadata(path: String) {
            val mmr = MediaMetadataRetriever()
            mmr.setDataSource(path)
            val rotation = mmr.extractMetadata(
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION
            )
            val width = mmr.extractMetadata(
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH
            )
            val height = mmr.extractMetadata(
                    MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT
            )
            mmr.release()
            videoRotation = rotation!!.toInt()
            videoWidth = width!!.toInt()
            videoHeight = height!!.toInt()
        }

        private fun startPlayer() {
            if (exoPlayer != null) {
                stopPlayer()
            }
            try {
                getVideoMetadata(wallpaper.getRealPath(context))
            } catch (e: IOException) {
                e.printStackTrace()
                // gg
                return
            }
            trackSelector = DefaultTrackSelector(context)

            exoPlayer = ExoPlayerFactory.newSimpleInstance(context, trackSelector!!)
            exoPlayer!!.volume = 0.0f
            // Disable audio decoder.
            val count = exoPlayer!!.rendererCount
            for (i in 0 until count) {
                if (exoPlayer!!.getRendererType(i) == C.TRACK_TYPE_AUDIO) {
                    trackSelector!!.setParameters(
                            trackSelector!!.buildUponParameters().setRendererDisabled(i, true)
                    )
                }
            }
            exoPlayer!!.repeatMode = Player.REPEAT_MODE_ALL
            val dataSourceFactory: DataSource.Factory = DefaultDataSourceFactory(
                    context, Util.getUserAgent(context, "xyz.alynx.livewallpaper")
            )
            
            // ExoPlayer can load file:///android_asset/ uri correctly.
            videoSource = ProgressiveMediaSource.Factory(
                    dataSourceFactory
            ).createMediaSource(MediaItem.fromUri(Uri.fromFile(File(wallpaper.getRealPath(context)))))

            // Let we assume video has correct info in metadata, or user should fix it.
            renderer!!.setVideoSizeAndRotation(videoWidth, videoHeight, videoRotation)
            // This must be set after getting video info.
            renderer!!.setSourcePlayer(exoPlayer!!)
            exoPlayer!!.setMediaSource(videoSource!!)
            exoPlayer!!.prepare()

            // ExoPlayer's video size changed listener is buggy. Don't use it.
            // It give's width and height after rotation, but did not rotate frames.
//            if (oldWallpaperCard != null &&
//                    oldWallpaperCard.equals(wallpaperCard)) {
//                exoPlayer!!.seekTo(progress)
//            }

            exoPlayer!!.playWhenReady = true
        }

        private fun stopPlayer() {
            if (exoPlayer != null) {
                if (exoPlayer!!.playWhenReady) {
                    exoPlayer!!.playWhenReady = false
                    progress = exoPlayer!!.currentPosition
                    exoPlayer!!.stop()
                }
                exoPlayer!!.release()
                exoPlayer = null
            }
            videoSource = null
            trackSelector = null
        }

        init {
            setTouchEventsEnabled(false)
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

//    inner class VideoWallpaperEngine(private val wallpaper: Wallpaper) : Engine() {
//        private var mediaPlayer: MediaPlayer? = null
//
//        override fun onDestroy() {
//            mediaPlayer?.release()
//            mediaPlayer = null
//        }
//
//        override fun onVisibilityChanged(visible: Boolean) {
//            if (visible) {
//                mediaPlayer?.start()
//            } else {
//                mediaPlayer?.pause()
//            }
//        }
//
//        override fun onSurfaceCreated(holder: SurfaceHolder) {
//
//            Log.d(TAG, "onCreate: ${wallpaper.getRealPath(this@LWService)}")
//
//            mediaPlayer = MediaPlayer()
//            with(mediaPlayer!!) {
//                setSurface(holder.surface)
//                isLooping = true
//                setVolume(0f, 0f)
//            }
//
//            try {
//                with(mediaPlayer!!) {
//                    setDataSource(wallpaper.getRealPath(this@LWService))
//                    prepare()
//                    start()
//                }
//            } catch (e: IOException) {
//                e.printStackTrace()
//            }
//        }
//
//        override fun onSurfaceChanged(holder: SurfaceHolder?, format: Int, width: Int, height: Int) {
//            val boxWidth = width.toFloat()
//            val boxHeight = height.toFloat()
//
//            val videoWidth: Int? = mediaPlayer?.videoWidth
//            val videoHeight: Int? = mediaPlayer?.videoHeight
//
////            Log.i(TAG, java.lang.String.format("startVideoPlayback @ %d - video %dx%d - box %dx%d", mPos, videoWidth.toInt(), videoHeight.toInt(), width, height))
//
//            val wr = boxWidth / videoWidth!!
//            val hr = boxHeight / videoHeight!!
//            val ar = videoWidth / videoHeight
//
//            var w = 0;
//            var h = 0;
//
//            if (wr > hr) w = (boxHeight * ar).toInt() else h = (boxWidth / ar).toInt()
//
//            holder!!.setFixedSize(w, h)
//        }
//    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    inner class WebWallpaperEngine(private val context: Context, private val wallpaper: Wallpaper) : Engine() {
        private var myWebView: WebView? = null
        private val myId: Int = nextEngineId
        private val mDisplayManager = getSystemService(DISPLAY_SERVICE) as DisplayManager

        init {
            nextEngineId++
        }

        override fun onCreate(surfaceHolder: SurfaceHolder) {
            setTouchEventsEnabled(true)
            log("MyEngine $myId On Create")

            // Create WebView
            if (myWebView != null) {
                myWebView!!.destroy()
            }

            WebView.setWebContentsDebuggingEnabled(true)

            myWebView = WebView(context)
            myWebView!!.setInitialScale(1)
            myWebView!!.setBackgroundColor(Color.TRANSPARENT)
            myWebView!!.isVerticalScrollBarEnabled = false
            myWebView!!.isHorizontalScrollBarEnabled = false
            myWebView!!.setLayerType(WebView.LAYER_TYPE_HARDWARE, null)
            myWebView!!.webChromeClient = WebChromeClient()
            myWebView!!.webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(
                        view: WebView,
                        request: WebResourceRequest,
                ): Boolean {
                    val url = request.url
                    Log.d(TAG, "shouldOverrideUrlLoading: ${url.scheme}")
                    return try {
                        if (url.scheme == "https" || url.scheme == "https") {
                            view.loadUrl(url.toString())
                        } else {
                            val intent = Intent(Intent.ACTION_VIEW, url)
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        }
                        true
                    } catch (e: Exception) {
                        Log.d(TAG, "shouldOverrideUrlLoading: $e")
                        true
                    }
                }
            }

            with(myWebView!!.settings) {
                javaScriptEnabled = true
                domStorageEnabled = true
                useWideViewPort = true
                setSupportZoom(true)
                layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING;
                loadWithOverviewMode = true
                allowContentAccess = true
                allowFileAccess = true
                @Suppress("DEPRECATION")
                allowFileAccessFromFileURLs = true
                @Suppress("DEPRECATION")
                allowUniversalAccessFromFileURLs = true
                @Suppress("DEPRECATION")
                setAppCacheEnabled(false)
                blockNetworkLoads = false
                builtInZoomControls = false
                displayZoomControls = false
                domStorageEnabled = true
                javaScriptCanOpenWindowsAutomatically = false
                setGeolocationEnabled(true)
                if (Build.VERSION.SDK_INT >= 26) {
                    safeBrowsingEnabled = true
                }
            }

            Log.d(TAG, "onCreate: ${wallpaper.getRealPath(this@LWService)}")

//            myWebView!!.addJavascriptInterface(JSInterface(), "androidWallpaperInterface")
//            myWebView!!.loadUrl("file:///android_asset/demo1/index.html")
            myWebView!!.loadUrl("file://" + wallpaper.getRealPath(this@LWService))
//            myWebView!!.loadUrl("https://www.uberviz.io/viz/splice/")
        }

        override fun onDestroy() {
            log("MyEngine $myId On Destroy")
        }

        override fun onVisibilityChanged(visible: Boolean) {
            log("On Visibility Changed $visible")

//            // To save battery, when we're not visible we want the WebView to stop processing,
//            // so we use the loadUrl mechanism to call some JavaScript to tell it to pause.
//            if (visible) {
//                myWebView?.loadUrl("javascript:resumeWallpaper()")
//            } else {
//                myWebView?.loadUrl("javascript:pauseWallpaper()")
//            }
        }

        @SuppressLint("ClickableViewAccessibility", "SetJavaScriptEnabled")
        override fun onSurfaceCreated(holder: SurfaceHolder) {
            log("On Surface Create")
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            log("On Surface Destroy")
            if (myWebView != null) {
                myWebView!!.destroy()
                myWebView = null
            }
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            log("On Surface Changed $format, $width, $height")

            if (myWebView == null) return

            val flags = DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY
            val density = DisplayMetrics.DENSITY_DEFAULT

            val virtualDisplay = mDisplayManager.createVirtualDisplay(
                    "MyVirtualDisplay",
                    width, height, density, holder.surface, flags
            )

            val myPresentation = Presentation(this@LWService, virtualDisplay.display)

            val params = ViewGroup.LayoutParams(width, height)
            myPresentation.setContentView(myWebView!!, params)
            myPresentation.show()
        }

        override fun onTouchEvent(event: MotionEvent?) {
            myWebView?.onTouchEvent(event)
        }

        private fun showAll() {
            if (myWebView == null) return

            myWebView!!.resumeTimers()
            myWebView!!.onResume()
        }

        private fun pauseAll() {
            if (myWebView == null) return

            myWebView!!.pauseTimers()
            myWebView!!.onPause()
        }

        private fun release() {
            if (myWebView == null) return

            myWebView!!.clearFormData()
            myWebView!!.clearMatches()
            myWebView!!.clearCache(true)
            myWebView!!.destroy()
            myWebView = null
        }

        private fun log(message: String) {
            Log.d("MyLWP $myId", message)
        }

        private fun logError(message: String) {
            Log.e("MyLWP $myId", message)
        }
    }
}