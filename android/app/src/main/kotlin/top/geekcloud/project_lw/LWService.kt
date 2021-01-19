package top.geekcloud.project_lw

import android.annotation.SuppressLint
import android.app.Presentation
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.hardware.display.DisplayManager
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.util.DisplayMetrics
import android.util.Log
import android.view.MotionEvent
import android.view.SurfaceHolder
import android.view.ViewGroup
import android.webkit.*
import android.webkit.WebView
import androidx.localbroadcastmanager.content.LocalBroadcastManager

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
        return WebWallpaperEngine(this)
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: ")
        LocalBroadcastManager.getInstance(applicationContext).unregisterReceiver(receiver)
        super.onDestroy()
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////

    inner class WebWallpaperEngine(private val context: Context) : Engine() {
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
                    request: WebResourceRequest
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

//            myWebView!!.addJavascriptInterface(JSInterface(), "androidWallpaperInterface")
//            myWebView!!.loadUrl("file:///android_asset/demo1/index.html")

            myWebView!!.loadUrl("https://christmasexperiments.com/")
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