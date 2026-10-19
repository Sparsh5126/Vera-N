# ONNX Runtime builds its Java objects (NodeInfo, ValueInfo, OnnxTensor...)
# from native code through JNI. R8 cannot see those calls, so without this
# it strips the constructors and release builds abort when the model loads
# (NoSuchMethodError: NodeInfo.<init>, 2026-10-19).
-keep class ai.onnxruntime.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
