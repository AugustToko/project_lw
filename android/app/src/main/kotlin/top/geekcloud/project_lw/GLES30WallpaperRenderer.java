/*
 * Copyright 2019 Alynx Zhou
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package top.geekcloud.project_lw;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.opengl.GLES11Ext;
import android.opengl.GLES30;
import android.opengl.Matrix;
import android.view.Surface;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.SimpleExoPlayer;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.Locale;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

class GLES30WallpaperRenderer extends GLWallpaperRenderer {
    @SuppressWarnings("unused")
    private static final String TAG = "GLES30WallpaperRenderer";
    private static final int BYTES_PER_FLOAT = 4;
    private static final int BYTES_PER_INT = 4;
    private final FloatBuffer vertices;
    private final FloatBuffer texCoords;
    private final IntBuffer indices;
    private final int[] buffers;
    private final int[] vertexArrays;
    private final int[] textures;
    private final float[] mvp;
    private int program = 0;
    private int mvpLocation = 0;
    private SurfaceTexture surfaceTexture = null;
    private int screenWidth = 0;
    private int screenHeight = 0;
    private int videoWidth = 0;
    private int videoHeight = 0;
    private int videoRotation = 0;
    private float xOffset = 0;
    private float yOffset = 0;
    private float maxXOffset = 0;
    private float maxYOffset = 0;
    // Fix bug like https://stackoverflow.com/questions/14185661/surfacetexture-onframeavailablelistener-stops-being-called
    private long updatedFrame = 0;
    private long renderedFrame = 0;

    GLES30WallpaperRenderer(@NonNull final Context context) {
        super(context);

        // Those replaced glGenBuffers() and glBufferData().
        final float[] vertexArray = {
            // x, y
            // bottom left
            -1.0f, -1.0f,
            // top left
            -1.0f, 1.0f,
            // bottom right
            1.0f, -1.0f,
            // top right
            1.0f, 1.0f
        };
        vertices = ByteBuffer.allocateDirect(
            vertexArray.length * BYTES_PER_FLOAT
        ).order(ByteOrder.nativeOrder()).asFloatBuffer();
        vertices.put(vertexArray).position(0);

        final float[] texCoordArray = {
            // u, v
            // bottom left
            0.0f, 1.0f,
            // top left
            0.0f, 0.0f,
            // bottom right
            1.0f, 1.0f,
            // top right
            1.0f, 0.0f
        };
        texCoords = ByteBuffer.allocateDirect(
            texCoordArray.length * BYTES_PER_FLOAT
        ).order(ByteOrder.nativeOrder()).asFloatBuffer();
        texCoords.put(texCoordArray).position(0);

        final int[] indexArray = {
            0, 1, 2,
            3, 2, 1
        };
        indices = ByteBuffer.allocateDirect(
            indexArray.length * BYTES_PER_INT
        ).order(ByteOrder.nativeOrder()).asIntBuffer();
        indices.put(indexArray).position(0);

        vertexArrays = new int[1];
        buffers = new int[3];
        textures = new int[1];
        mvp = new float[] {
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
        };
    }

    @Override
    public void onSurfaceCreated(GL10 gl10, EGLConfig eglConfig) {
        // No depth test for 2D video.
        GLES30.glDisable(GLES30.GL_DEPTH_TEST);
        GLES30.glDepthMask(false);
        GLES30.glDisable(GLES30.GL_CULL_FACE);
        GLES30.glDisable(GLES30.GL_BLEND);

        GLES30.glGenTextures(textures.length, textures, 0);
        GLES30.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textures[0]);
        GLES30.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES30.GL_TEXTURE_MIN_FILTER,
            GLES30.GL_LINEAR
        );
        GLES30.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES30.GL_TEXTURE_MAG_FILTER,
            GLES30.GL_LINEAR
        );
        GLES30.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES30.GL_TEXTURE_WRAP_S,
            GLES30.GL_CLAMP_TO_EDGE
        );
        GLES30.glTexParameteri(
            GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
            GLES30.GL_TEXTURE_WRAP_T,
            GLES30.GL_CLAMP_TO_EDGE
        );

        program = Utils.linkProgramGLES30(
            Utils.compileShaderResourceGLES30(
                context, GLES30.GL_VERTEX_SHADER, R.raw.vertex_30
            ),
            Utils.compileShaderResourceGLES30(
                context, GLES30.GL_FRAGMENT_SHADER, R.raw.fragment_30
            )
        );
        mvpLocation = GLES30.glGetUniformLocation(program, "mvp");

        GLES30.glGenBuffers(buffers.length, buffers, 0);

        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, buffers[0]);
        GLES30.glBufferData(
            GLES30.GL_ARRAY_BUFFER, vertices.capacity() * BYTES_PER_FLOAT,
            vertices, GLES30.GL_STATIC_DRAW
        );
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, 0);

        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, buffers[1]);
        GLES30.glBufferData(
            GLES30.GL_ARRAY_BUFFER, texCoords.capacity() * BYTES_PER_FLOAT,
            texCoords, GLES30.GL_STATIC_DRAW
        );
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, 0);

        GLES30.glBindBuffer(GLES30.GL_ELEMENT_ARRAY_BUFFER, buffers[2]);
        GLES30.glBufferData(
            GLES30.GL_ELEMENT_ARRAY_BUFFER, indices.capacity() * BYTES_PER_INT,
            indices, GLES30.GL_STATIC_DRAW
        );
        GLES30.glBindBuffer(GLES30.GL_ELEMENT_ARRAY_BUFFER, 0);

        // Locations are set in shader sources.
        GLES30.glGenVertexArrays(vertexArrays.length, vertexArrays, 0);

        GLES30.glBindVertexArray(vertexArrays[0]);
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, buffers[0]);
        GLES30.glEnableVertexAttribArray(0);
        GLES30.glVertexAttribPointer(
            0, 2, GLES30.GL_FLOAT, false, 2 * BYTES_PER_FLOAT, 0
        );
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, buffers[1]);
        GLES30.glEnableVertexAttribArray(1);
        GLES30.glVertexAttribPointer(
            1, 2, GLES30.GL_FLOAT, false, 2 * BYTES_PER_FLOAT, 0
        );
        GLES30.glBindBuffer(GLES30.GL_ELEMENT_ARRAY_BUFFER, buffers[2]);
        GLES30.glBindVertexArray(0);

        GLES30.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    }

    @Override
    public void onSurfaceChanged(GL10 gl10, int width, int height) {
        GLES30.glViewport(0, 0, width, height);
    }

    @Override
    public void onDrawFrame(GL10 gl10) {
        if (surfaceTexture == null) {
            return;
        }

        if (renderedFrame < updatedFrame) {
            surfaceTexture.updateTexImage();
            ++renderedFrame;
            // Utils.debug(
            //     TAG, "renderedFrame: " + renderedFrame + " updatedFrame: " + updatedFrame
            // );
        }

        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT);
        GLES30.glUseProgram(program);
        GLES30.glUniformMatrix4fv(mvpLocation, 1, false, mvp, 0);
        GLES30.glBindVertexArray(vertexArrays[0]);
        GLES30.glDrawElements(GLES30.GL_TRIANGLES, 6, GLES30.GL_UNSIGNED_INT, 0);
        GLES30.glBindVertexArray(0);
        GLES30.glUseProgram(0);
    }



    @Override
    void setSourcePlayer(@NonNull final SimpleExoPlayer exoPlayer) {
        // Re-create SurfaceTexture when getting a new player.
        // Because maybe a new video is loaded.
        createSurfaceTexture();
        exoPlayer.setVideoSurface(new Surface(surfaceTexture));
    }

    @Override
    void setScreenSize(int width, int height) {
        if (screenWidth != width || screenHeight != height) {
            screenWidth = width;
            screenHeight = height;
            Utils.debug(TAG, String.format(
                Locale.US, "Set screen size to %dx%d", screenWidth, screenHeight
            ));
            maxXOffset = (1.0f - (
                (float)screenWidth / screenHeight) / ((float)videoWidth / videoHeight)
            ) / 2;
            maxYOffset = (1.0f - (
                (float)screenHeight / screenWidth) / ((float)videoHeight / videoWidth)
            ) / 2;
            updateMatrix();
        }
    }

    @Override
    void setVideoSizeAndRotation(int width, int height, int rotation) {
        // MediaMetadataRetriever always give us raw width and height and won't rotate them.
        // So we rotate them by ourselves.
        if (rotation % 180 != 0) {
            final int swap = width;
            //noinspection SuspiciousNameCombination
            width = height;
            height = swap;
        }
        if (videoWidth != width || videoHeight != height || videoRotation != rotation) {
            videoWidth = width;
            videoHeight = height;
            videoRotation = rotation;
            Utils.debug(TAG, String.format(
                Locale.US, "Set video size to %dx%d", videoWidth, videoHeight
            ));
            Utils.debug(TAG, String.format(
                Locale.US, "Set video rotation to %d", videoRotation
            ));
            maxXOffset = (1.0f - (
                (float)screenWidth / screenHeight) / ((float)videoWidth / videoHeight)
            ) / 2;
            maxYOffset = (1.0f - (
                (float)screenHeight / screenWidth) / ((float)videoHeight / videoWidth)
            ) / 2;
            updateMatrix();
        }
    }

    @Override
    void setOffset(float xOffset, float yOffset) {
        if (xOffset > maxXOffset) {
            xOffset = maxXOffset;
        }
        if (xOffset < -maxXOffset) {
            xOffset = -maxXOffset;
        }
        if (yOffset > maxYOffset) {
            yOffset = maxYOffset;
        }
        if (yOffset < -maxXOffset) {
            yOffset = -maxYOffset;
        }
        if (this.xOffset != xOffset || this.yOffset != yOffset) {
            this.xOffset = xOffset;
            this.yOffset = yOffset;
            Utils.debug(TAG, String.format(
                Locale.US, "Set offset to %fx%f", this.xOffset, this.yOffset
            ));
            updateMatrix();
        }
    }

    private void createSurfaceTexture() {
        if (surfaceTexture != null) {
            surfaceTexture.release();
            surfaceTexture = null;
        }
        updatedFrame = 0;
        renderedFrame = 0;
        surfaceTexture = new SurfaceTexture(textures[0]);
        surfaceTexture.setDefaultBufferSize(videoWidth, videoHeight);
        surfaceTexture.setOnFrameAvailableListener(new SurfaceTexture.OnFrameAvailableListener() {
            @Override
            public void onFrameAvailable(SurfaceTexture surfaceTexture) {
                ++updatedFrame;
            }
        });
    }

    private void updateMatrix() {
        // Players are buggy and unclear, so we do crop by ourselves.
        // Start with an identify matrix.
        for (int i = 0; i < 16; ++i) {
            mvp[i] = 0.0f;
        }
        mvp[0] = mvp[5] = mvp[10] = mvp[15] = 1.0f;
        // OpenGL model matrix: scaling, rotating, translating.
        final float videoRatio = (float)videoWidth / videoHeight;
        final float screenRatio = (float)screenWidth / screenHeight;
        if (videoRatio >= screenRatio) {
            Utils.debug(TAG, "X-cropping");
            // Treat video and screen width as 1, and compare width to scale.
            Matrix.scaleM(
                mvp, 0,
                ((float)videoWidth / videoHeight) / ((float)screenWidth / screenHeight),
                1, 1
            );
            // Some video recorder save video frames in direction differs from recoring,
            // and add a rotation metadata. Need to detect and rotate them.
            if (videoRotation % 360 != 0) {
                Matrix.rotateM(mvp, 0, -videoRotation, 0,0, 1);
            }
            Matrix.translateM(mvp, 0, xOffset, 0, 0);
        } else {
            Utils.debug(TAG, "Y-cropping");
            // Treat video and screen height as 1, and compare height to scale.
            Matrix.scaleM(
                mvp, 0, 1,
                ((float)videoHeight / videoWidth) / ((float)screenHeight / screenWidth), 1
            );
            // Some video recorder save video frames in direction differs from recoring,
            // and add a rotation metadata. Need to detect and rotate them.
            if (videoRotation % 360 != 0) {
                Matrix.rotateM(mvp, 0, -videoRotation, 0,0, 1);
            }
            Matrix.translateM(mvp, 0, 0, yOffset, 0);
        }
        // This is a 2D center crop, so we only need model matrix, no view and projection.
    }
}
