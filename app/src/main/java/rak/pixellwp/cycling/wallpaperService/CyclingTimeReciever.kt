package rak.pixellwp.cycling.wallpaperService

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import rak.pixellwp.cycling.LAST_HOUR_CHECKED
import rak.pixellwp.cycling.models.TimelineImage
import java.util.*

fun CyclingWallpaperService.CyclingWallpaperEngine.timeReceiver(): BroadcastReceiver {
    return object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (currentImageType == ImageType.COLLECTION) {
                val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                if (lastHourChecked != hour) {
                    Log.d(cyclingWallpaperLogTag, "Hour passed ($lastHourChecked > $hour). Assessing possible image change")
                    lastHourChecked = hour
                    prefs.edit().putInt(LAST_HOUR_CHECKED, lastHourChecked).apply()
                    if (imageCollection != "") {
                        changeCollection()
                    }
                }
            } else if (currentImageType == ImageType.TIMELINE) {
                checkAndRandomizeTimeline()
            }
        }
    }
}

internal fun CyclingWallpaperService.CyclingWallpaperEngine.updateTimelineOverride(prefOverrideTimeline: Boolean, newOverrideTime: Long) {
    if (drawRunner.image is TimelineImage) {
        val image: TimelineImage = drawRunner.image as TimelineImage
        if (prefOverrideTimeline != overrideTimeline || newOverrideTime != image.getOverrideTime()) {
            if (prefOverrideTimeline) {
                image.setTimeOverride(newOverrideTime)
            } else {
                image.stopTimeOverride()
            }
            overrideTimeline = prefOverrideTimeline
        }
    }
}

internal fun CyclingWallpaperService.CyclingWallpaperEngine.getTime(): Long {
    return if (overrideTimeline) {
        overrideTime
    } else {
        Calendar.getInstance().get(Calendar.MILLISECOND).toLong()
    }
}

internal fun CyclingWallpaperService.CyclingWallpaperEngine.checkAndRandomizeTimeline() {
    if (randomizeInterval == "never") return
    
    val currentTime = System.currentTimeMillis()
    val intervalMillis = getRandomizeIntervalMillis(randomizeInterval)
    
    if (currentTime - lastRandomizeTime >= intervalMillis) {
        randomizeTimelineImage()
        lastRandomizeTime = currentTime
        prefs.edit().putLong(LAST_RANDOMIZE_TIME, lastRandomizeTime).apply()
    }
}

internal fun CyclingWallpaperService.CyclingWallpaperEngine.randomizeTimelineImage() {
    try {
        val availableImages = imageLoader.getAvailableTimelineImages()
        if (availableImages.isNotEmpty()) {
            // Filter out current image to ensure we get a different one
            val otherImages = availableImages.filter { it != timelineImage }
            if (otherImages.isNotEmpty()) {
                val randomImage = otherImages.random()
                Log.d(cyclingWallpaperLogTag, "Randomizing timeline image from $timelineImage to $randomImage")
                timelineImage = randomImage
                prefs.edit().putString(TIMELINE_IMAGE, timelineImage).apply()
                changeTimeline()
            }
        }
    } catch (e: Exception) {
        Log.e(cyclingWallpaperLogTag, "Error randomizing timeline image", e)
    }
}

private fun getRandomizeIntervalMillis(interval: String): Long {
    return when (interval) {
        "10s" -> 10 * 1000L
        "1h" -> 60 * 60 * 1000L
        "1d" -> 24 * 60 * 60 * 1000L
        else -> Long.MAX_VALUE // "never"
    }
}