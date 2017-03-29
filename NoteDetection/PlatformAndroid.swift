//
//  PlatformAndroid.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.12.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

import Glibc
import JNI

// Cross-platform framework-internal functions
// -------------------------------------------

typealias MethodParameters = [jvalue]

/// Run the given block on Java's Virtual Machine UI thread
/// - Note: We _always_ ensure that our _env reference is attached to the jvm,
///         meaning we can just run the block - if it doesn't reference _env,
///         then it doesn't need to be attached to the JVM anyway!

func performOnMainThread(block: () -> Void) {
    block()
}


// Extensions that allow sending of notifications

protocol NotificationParameterConvertible {
    func toJValue() -> jvalue
}

extension Float : NotificationParameterConvertible {
    func toJValue() -> jvalue {
        return jvalue(f: jfloat(self))
    }
}

extension Int : NotificationParameterConvertible {
    func toJValue() -> jvalue {
        return jvalue(i: jint(self))
    }
}

extension Double : NotificationParameterConvertible {
    func toJValue() -> jvalue {
        return jvalue(d: jdouble(self))
    }
}

// Android-specific functions to make the other stuff work
// -------------------------------------------------------
//
//    Everything below should be internal to this file, all framework-facing functions
//    should be defined above and, where relevant, also have a compatible API to the
//    functions in PlatformApple.swift
//


class PitchDetectionListener: OnsetDetectionDelegate, NoteDetectionDelegate, VolumeDelegate {

    let onsetDetectedCallback: JavaCallback
    let volumeChangedCallback: JavaCallback
    let notesDetectedCallback: JavaCallback
    let globalPluginInstance: jobject

    init(plugin: jobject) {
        globalPluginInstance = plugin
        onsetDetectedCallback = JavaCallback(plugin, methodName: "onsetDetected", methodSignature: "(D)V")
        volumeChangedCallback = JavaCallback(plugin, methodName: "volumeChanged", methodSignature: "(F)V")
        notesDetectedCallback = JavaCallback(plugin, methodName: "notesDetected", methodSignature: "([FF[ID)V")
    }

    deinit {
        jni.DeleteGlobalRef(globalPluginInstance)
    }

    func onsetDetected (timestamp: Timestamp) {
        onsetDetectedCallback.call(timestamp.toJValue())
    }

    func notePlayedCorrectly(noteEvent: NoteEvent, timestamp: Timestamp) {


        guard
            let chromaJArray = jarrayFromArray(noteEvent.expectedChroma.toRaw),
            let notesJArray = jarrayFromArray(noteEvent.notes)
        else {
                // XXX: print something!
                return
        }

        let chromaArr = jvalue(l: chromaJArray)
        let tolerance = noteEvent.tolerance.toJValue()
        let noteArr = jvalue(l: notesJArray)
        let time = timestamp.toJValue()

        //execute callback
        notesDetectedCallback.call(chromaArr, tolerance, noteArr, time)

        // clean up arrays
        jni.DeleteLocalRef(chromaArr.l)
        jni.DeleteLocalRef(noteArr.l)
    }

    func volumeChanged(volume: Float) {
        volumeChangedCallback.call(volume.toJValue())
    }
}

var audioProcessor: AudioProcessor?


// These have to be public so that they are accessible from Java:
@_silgen_name("NativePitchDetection_setupAudioProcessor")
public func setupAudioProcessor(globalPluginInstance: jobject, samplerate: Int32) {
    // Our C++ code sends a GlobalRef to the PitchDetectionPlugin
    // class instance to simplify getting the methods we need


    audioProcessor = AudioProcessor(sampleRate: Int(samplerate))

    let listener = PitchDetectionListener(plugin: globalPluginInstance)
    audioProcessor?.noteDetection.delegate = listener
    audioProcessor?.onsetDetection.delegate = listener
    audioProcessor?.volumeDelegate = listener

}


@_silgen_name("NativePitchDetection_audioCallback")
public func audioCallback(buffer: UnsafeMutablePointer<Float>, bufferLength: Int32) {
    let bufferPointer = UnsafeBufferPointer(start: buffer, count: Int(bufferLength))
    let floatArray = [Float](bufferPointer)
    audioProcessor?.processAudio(floatArray)
}

@_silgen_name("Java_com_flowkey_plugins_pitchdetectionplugin_PitchDetectionPlugin_sendEventToNoteDetection")
public func setNoteEvent(env: UnsafeMutablePointer<JNIEnv>, jobj: jobject, expectedChroma: jfloatArray, tolerance: jfloat, notes: jintArray) {
    let chromaFloatArray = jni.GetFloatArrayRegion(expectedChroma)
    let chromaVector = ChromaVector(chromaFloatArray)!
    let notes = jni.GetIntArrayRegion(notes)
    let newNoteEvent = NoteEvent(expectedChroma: chromaVector, tolerance: tolerance, notes: notes)

    audioProcessor?.noteDetection.expectedEvent = newNoteEvent
}


// XXX: The jArrays we create here must be cleaned up manually.
// We should be able to do this better than how we have it now.
private func jarrayFromArray(sourceArray: [Int]) -> jarray? {
    guard let jArray = jni.NewIntArray(sourceArray.count) else { return nil }
    jni.SetIntArrayRegion(jArray, from: sourceArray)
    return jArray
}

private func jarrayFromArray(sourceArray: [Float]) -> jarray? {
    guard let jArray = jni.NewFloatArray(sourceArray.count) else { return nil }
    jni.SetFloatArrayRegion(jArray, from: sourceArray)
    return jArray
}
