package com.flowkey.notedetection.permissions

import android.Manifest
import android.app.Activity
import android.content.Context
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat

/**
 * Created by erik on 12.07.17.
 */

val RECORD_AUDIO = Manifest.permission.RECORD_AUDIO


external fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray)

fun checkRecordAudioPermission(context: Context): Int {
    return ContextCompat.checkSelfPermission(context, RECORD_AUDIO)
}

fun requestRecordAudioPermission(context: Context) {
    ActivityCompat.requestPermissions(context as Activity, arrayOf(RECORD_AUDIO), 0)
}

// sends user into androids app settings
//fun showAppSettings() {
//    val settingsIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
//    settingsIntent.data = Uri.fromParts("package", activity.packageName, null)
//    activity.startActivity(settingsIntent)
//}

// gets whether you should show UI with rationale for requesting a permission
//fun shouldShowRequestPermissionRationale(): Boolean {
//    return ActivityCompat.shouldShowRequestPermissionRationale(activity, RECORD_AUDIO)
//}
