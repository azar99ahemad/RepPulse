package com.reppulse.app

/**
 * PoseAnalyzer — MediaPipe Pose Landmarker integration for Android.
 *
 * NOTE: Full implementation requires the MediaPipe Tasks Vision AAR dependency.
 * Add to android/app/build.gradle:
 *   implementation 'com.google.mediapipe:tasks-vision:0.10.9'
 *
 * This file provides the complete scaffold and integration pattern.
 * The actual PoseLandmarker classes are from the MediaPipe library.
 */

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream

class PoseAnalyzer(
    private val context: Context,
    private val eventSink: EventChannel.EventSink?
) : ImageAnalysis.Analyzer {

    private val frameThrottleMs = 50L // ~20 FPS
    private var lastProcessedMs = 0L

    override fun analyze(imageProxy: ImageProxy) {
        val now = System.currentTimeMillis()
        if (now - lastProcessedMs < frameThrottleMs) {
            imageProxy.close()
            return
        }
        lastProcessedMs = now

        try {
            val bitmap = imageProxy.toBitmap()
            val scaled = Bitmap.createScaledBitmap(bitmap, 320, 240, false)

            // TODO: Pass scaled bitmap to MediaPipe PoseLandmarker
            // poseLandmarker.detectAsync(BitmapImageBuilder(scaled).build(), imageProxy.imageInfo.timestamp)
            // Result callback sends landmarks via EventChannel

            // Placeholder: send empty landmarks to Flutter
            val result = mapOf(
                "landmarks" to emptyList<Map<String, Double>>(),
                "timestampMs" to now
            )
            eventSink?.success(result)

            scaled.recycle()
            bitmap.recycle()
        } catch (e: Exception) {
            eventSink?.error("POSE_ERROR", e.message, null)
        } finally {
            imageProxy.close() // CRITICAL: always close
        }
    }

    /**
     * Converts an ImageProxy (YUV_420_888) to a Bitmap.
     */
    private fun ImageProxy.toBitmap(): Bitmap {
        val yBuffer = planes[0].buffer
        val uBuffer = planes[1].buffer
        val vBuffer = planes[2].buffer

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + uSize + vSize)
        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)

        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        val out = ByteArrayOutputStream()
        yuvImage.compressToJpeg(Rect(0, 0, width, height), 85, out)
        val imageBytes = out.toByteArray()
        return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }
}
