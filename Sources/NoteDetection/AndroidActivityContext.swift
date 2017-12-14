#if os(Android)

import JNI

// XXX: introduces explicit dependency on SDL

func getMainActivityContext() throws -> JavaObject {
    let context = try jni.callStatic("getContext", on: getActivityClass(), returningObjectType: "android.content.Context")
    return context
}

@_silgen_name("Android_JNI_GetActivityClass")
public func getActivityClass() -> JavaClass

#endif
