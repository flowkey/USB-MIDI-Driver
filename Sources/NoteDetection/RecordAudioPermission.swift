//
//  RecordAudioPermission.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 19.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import JNI


private var onRecordAudioPermissionResult: ((AndroidPermissionsResult) -> Void)!
private var androidPermissionsClass: JavaClass!

func initAndroidPermissions() throws {
    let permissionsClassName = "com/flowkey/Permissions/PermissionsKt"
    guard let jPermissionsClass = try? jni.FindClass(name: permissionsClassName)
    else { throw AndroidPermissionsError.PermissionsClassNotFound }

    guard let globalPermissionClass = jni.NewGlobalRef(jPermissionsClass)
    else { throw AndroidPermissionsError.GlobalRefNotCreated }

    androidPermissionsClass = globalPermissionClass
}

func deinitAndroidPermissions() {
    onRecordAudioPermissionResult = nil

    jni.DeleteGlobalRef(globalRef: androidPermissionsClass)
    androidPermissionsClass = nil
}

func requestAudioPermissionIfRequired(callback : @escaping ((AndroidPermissionsResult) -> Void)) throws {
    onRecordAudioPermissionResult = callback
    let currentPermissionResult = try getRecordAudioPermissionResult()
    if currentPermissionResult == .granted  { return callback(currentPermissionResult) }
    try jni.callStatic("requestRecordAudioPermission", on: androidPermissionsClass)
}

private func getRecordAudioPermissionResult() throws -> AndroidPermissionsResult {
    let audioPermissionResult: Int = try jni.callStatic("checkRecordAudioPermission", on: androidPermissionsClass)
    guard let result = AndroidPermissionsResult(rawValue: audioPermissionResult) else {
        throw AndroidPermissionsError.noPermissionsResult
    }
    return result
}

enum AndroidPermissionsResult: Int {
    case granted = 0
    case denied = -1
}

private enum AndroidPermissionsError: Error {
    case PermissionsClassNotFound
    case GlobalRefNotCreated
    case noPermissionsResult
}

@_silgen_name("Java_com_flowkey_Permissions_PermissionsKt_onRequestPermissionsResult")
public func onRequestPermissionsResult(
    env: UnsafeMutablePointer<JNIEnv>,
    cls: JavaObject,
    requestCode: JavaInt,
    permissionsJavaArr: JavaObjectArray,
    grantResultsJavaArr: JavaIntArray)
{
    guard let requestedPermissionNames = try? jni.GetStrings(from: permissionsJavaArr) else {
        assertionFailure("Couldn't get requestedPermissions from Java result")
        return
    }

    let requestedPermissionResults = jni.GetIntArrayRegion(array: grantResultsJavaArr)
    let permissions: [(name: String, result: Int)] = Array(zip(requestedPermissionNames, requestedPermissionResults))

    guard
        let recordAudioPermissionsName: String = try? jni.GetStaticField("RECORD_AUDIO", on: androidPermissionsClass),
        let recordAudioPermission = permissions.first(where: { $0.name == recordAudioPermissionsName })
    else {
        assertionFailure("Could not get recordAudioPermission entry from permissions array")
        return
    }

    guard let result = AndroidPermissionsResult(rawValue: recordAudioPermission.result) else {
        assertionFailure("Could not create AndroidPermissionsResult from recordAudioPermission.result = \(String(describing: recordAudioPermission.result))")
        return
    }

    if onRecordAudioPermissionResult != nil {
        onRecordAudioPermissionResult(result)
        onRecordAudioPermissionResult = nil
    } else {
        assertionFailure("onRecordAudioPermissionResult does not exist")
    }
}
