#if os(Android)

import JNI

// XXX: introduces implicit dependency on SDL

@_silgen_name("SDL_AndroidGetActivity")
public func getSDLView() -> JavaObject

func getMainActivityContext() throws -> JavaContext {
    let context = try jni.call("getContext", on: getSDLView(), returningObjectType: "android.content.Context")
    return JavaContext(context)
}

#endif
