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

    static var javaClass: JavaClass {
        let permissionsClassName = "com/flowkey/Permissions/PermissionsKt"
        guard let jPermissionsClass = try? jni.FindClass(name: permissionsClassName)
        else { fatalError("Permission class not found") }
        return jPermissionsClass
    }

    var onRecordAudioPermissionResult: ((AndroidPermissions.Result) -> Void)?

    func requestAudioPermissionIfRequired(callback : @escaping ((Result) -> Void)) throws {
        onRecordAudioPermissionResult = callback
        let currentPermissionResult = try getRecordAudioPermissionResult()
        if currentPermissionResult == .granted  { return callback(currentPermissionResult) }
        try jni.callStatic("requestRecordAudioPermission", on: AndroidPermissions.javaClass)
    }

    private func getRecordAudioPermissionResult() throws -> Result {
        let audioPermissionResult: Int = try jni.callStatic("checkRecordAudioPermission", on: AndroidPermissions.javaClass)
        guard let result = Result(rawValue: audioPermissionResult) else {
            fatalError("Could not create RECORD_AUDIO permission result")
        }
        return result
    }

    enum Result: Int {
        case granted = 0
        case denied = -1
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
    guard let requestedPermissionNames = try? jni.GetStrings(from: permissionsJavaArr) else {
        assertionFailure("Couldn't get requestedPermissions from Java result")
        return
    }

    let requestedPermissionResults = jni.GetIntArrayRegion(array: grantResultsJavaArr)
    let permissions: [(name: String, result: Int)] = Array(zip(requestedPermissionNames, requestedPermissionResults))

    guard
        let recordAudioPermissionsName: String = try? jni.GetStaticField("RECORD_AUDIO", on: AndroidPermissions.javaClass),
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
