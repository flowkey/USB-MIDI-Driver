//
//  RecordAudioPermission.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 19.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import JNI

private var onRecordAudioPermissionResult: ((AndroidPermissions.Result) -> Void)?

class AndroidPermissions: JNIObject {
    init() {
        let className = "com/flowkey/Permissions/PermissionsKt"
        do { try super.init(className) }
        catch { fatalError("Could not instantiate AndroidPermissions JNIObject from " + className) }
    }

    var recordAudioPermissionName: String? {
        return try? jni.GetStaticField("RECORD_AUDIO", on: self.javaClass)
    }

    func requestAudioPermissionIfRequired(callback : @escaping ((Result) -> Void)) throws {
        onRecordAudioPermissionResult = callback
        let currentPermissionResult = try getRecordAudioPermissionResult()
        if currentPermissionResult == .granted  { return callback(currentPermissionResult) }
        try requestRecordAudioPermission()
    }

    private func getRecordAudioPermissionResult() throws -> Result {
        let audioPermissionResult: Int = try jni.callStatic("checkRecordAudioPermission", on: self.javaClass)
        guard let result = Result(rawValue: audioPermissionResult) else {
            throw AndroidPermissionsError.noResult
        }
        return result
    }

    private func requestRecordAudioPermission() throws {
        try jni.callStatic("requestRecordAudioPermission", on: self.javaClass)
    }
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
    guard let requestedPermissionNames = try? jni.GetStrings(from: permissionsJavaArr)
    else { fatalError("Couldn't get requestedPermissions from Java result") }

    let requestedPermissionResults = jni.GetIntArrayRegion(array: grantResultsJavaArr)
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
