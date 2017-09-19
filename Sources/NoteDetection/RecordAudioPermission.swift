//
//  RecordAudioPermission.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 19.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import JNI

private var onRecordAudioPermissionResult: ((AndroidPermissions.Result) -> Void)?

class AndroidPermissions {
    private let permissionsClass: JavaClass

    init() {
        let permissionsClassName = "com/flowkey/Permissions/PermissionsKt"
        guard let jPermissionsClass = try? jni.FindClass(name: permissionsClassName)
        else { fatalError("Could not find class: " + permissionsClassName) }
        permissionsClass = jPermissionsClass
    }

    var recordAudioPermissionName: String? {
        return try? jni.GetStaticField("RECORD_AUDIO", on: permissionsClass)
    }

    func requestAudioPermissionIfRequired(callback : @escaping ((Result) -> Void)) throws {
        onRecordAudioPermissionResult = callback
        let currentPermissionResult = try getRecordAudioPermissionResult()
        if currentPermissionResult == .granted  { return callback(currentPermissionResult) }
        try requestRecordAudioPermission()
    }

    private func getRecordAudioPermissionResult() throws -> Result {
        let audioPermissionResult: Int = try jni.callStatic("checkRecordAudioPermission", on: permissionsClass)
        guard let result = Result(rawValue: audioPermissionResult) else {
            throw AndroidPermissionsError.noResult
        }
        return result
    }

    private func requestRecordAudioPermission() throws {
        try jni.callStatic("requestRecordAudioPermission", on: permissionsClass)
    }

    deinit { onRecordAudioPermissionResult = nil }
}


extension AndroidPermissions {
    enum Result: Int {
        case granted = 0
        case denied = -1
    }
    enum AndroidPermissionsError: Error {
        case noResult
    }
}

@_silgen_name("Java_com_flowkey_Permissions_PermissionsKt_onRequestPermissionsResult")
public func onRequestPermissionsResult(
    env: UnsafeMutablePointer<JNIEnv>,
    cls: JavaObject,
    requestCode: JavaInt,
    permissionsJavaArr: JavaObjectArray,
    grantResultsJavaArr: JavaIntArray)
{
    guard
        let requestedPermissionNames = try? jni.GetStrings(from: permissionsJavaArr),
        let requestedPermissionResults = try? jni.GetIntArrayRegion(array: grantResultsJavaArr)
    else {
        fatalError("Couldn't get requestedPermissions from Java result")
    }

    let permissions: [(name: String, result: Int)] = Array(zip(requestedPermissionNames, requestedPermissionResults))
    let recordAudioPermissionsName = AndroidPermissions().recordAudioPermissionName
    guard let recordAudioPermission = permissions.first(where: { $0.name == recordAudioPermissionsName }) else {
        assertionFailure(
            "Got permissions but they didn't include AndroidPermissions().recordAudioPermissionName (\(String(describing: recordAudioPermissionsName)).) " +
            "Got '\(permissions)' instead"
        )
        return
    }

    guard let result = AndroidPermissions.Result(rawValue: recordAudioPermission.result) else {
        assertionFailure("Could not create AndroidPermissions.Result from recordAudioPermission.result = \(String(describing: recordAudioPermission.result)) ")
        return
    }
    onRecordAudioPermissionResult?(result)
    onRecordAudioPermissionResult = nil

}
