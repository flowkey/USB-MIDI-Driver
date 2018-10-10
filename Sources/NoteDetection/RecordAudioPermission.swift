//
//  RecordAudioPermission.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 19.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import JNI

class AndroidPermissions {

    static var sharedInstance: AndroidPermissions?

    var onRecordAudioPermissionResult: ((Result) -> Void)?

    func requestAudioPermissionIfRequired(callback : @escaping ((Result) -> Void)) throws {
        onRecordAudioPermissionResult = callback
        let currentPermissionResult = try getRecordAudioPermissionResult()
        if currentPermissionResult == .granted { return callback(currentPermissionResult) }
        let context = try getMainActivityContext()
        try jni.callStatic("requestRecordAudioPermission", on: getPermissionsJavaClass(), arguments: [context])
    }

    private func getRecordAudioPermissionResult() throws -> Result {
        let context = try getMainActivityContext()
        let audioPermissionResult: JavaInt = try jni.callStatic("checkRecordAudioPermission", on: getPermissionsJavaClass(), arguments: [context])
        guard let result = Result(rawValue: audioPermissionResult) else {
            throw AndroidPermissionsError.getResultFailed
        }
        return result
    }

    enum Result: JavaInt {
        case granted = 0
        case denied = -1
    }
}

enum AndroidPermissionsError: Error {
    case getResultFailed
}

private func getPermissionsJavaClass() throws -> JavaClass {
    return try jni.FindClass(name: "com.flowkey.notedetection.permissions.PermissionsKt")
}

@_silgen_name("Java_com_flowkey_notedetection_permissions_PermissionsKt_onRequestPermissionsResult")
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
    let permissions: [(name: String, result: JavaInt)] = Array(zip(requestedPermissionNames, requestedPermissionResults))

    guard
        let recordAudioPermissionsName: String = try? jni.GetStaticField("RECORD_AUDIO", on: getPermissionsJavaClass()),
        let recordAudioPermission = permissions.first(where: { $0.name == recordAudioPermissionsName })
    else {
        assertionFailure("Could not get recordAudioPermission entry from permissions array")
        return
    }

    guard let result = AndroidPermissions.Result(rawValue: recordAudioPermission.result) else {
        assertionFailure("Could not create Result from recordAudioPermission.result = \(String(describing: recordAudioPermission.result))")
        return
    }

    guard AndroidPermissions.sharedInstance?.onRecordAudioPermissionResult != nil else {
        assertionFailure("sharedInstance or onRecordAudioPermissionResult does not exist")
        return
    }
    AndroidPermissions.sharedInstance?.onRecordAudioPermissionResult?(result)
}
