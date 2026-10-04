# Embedding model benchmark

A separate test app (`com.example.vera_n.embedding_bench`) that measures on-device embedding models on a real phone, to choose one for Vera N (product spec §20, risk 1: "test in week one"). It is not part of the Vera N app, adds no dependencies to it, and never touches real notes.

## What it measures

For one model per launch (so memory numbers don't mix):

- **Load time** of tokenizer + model, and memory (RSS) before, after loading, and at peak.
- **Time per note** at three lengths (about 15, 60 and 230 tokens; Hindi and English mixed): the median and p90 of 15 runs after 3 warm-up runs, end to end (tokenize, run the model, pool, normalize). Tokenizing alone is reported separately, since it runs in Dart.
- **Quality**, indicative only: 12 hand-written pairs of related notes in English, Hindi and Hinglish (`lib/quality_set.dart`). The result counts how often each text's nearest neighbour is its partner (`top1`), and how far partner similarities sit from all other similarities. That gap is the room a "strong match" threshold has to work with.

Everything runs on 4 CPU threads, with no GPU or NPU delegates, so the numbers are a baseline every phone can reach.

## Candidates

| Key | Model | File | License |
|---|---|---|---|
| `e5-small` | multilingual-e5-small, int8 ONNX (Xenova export) | `model_int8.onnx` + `tokenizer.json` | MIT |
| `ml-minilm-l12` | paraphrase-multilingual-MiniLM-L12-v2, int8 ONNX (Xenova export) | `model_int8.onnx` + `tokenizer.json` | Apache-2.0 |
| `embeddinggemma` | EmbeddingGemma-300M, seq 256, mixed precision, LiteRT | `embeddinggemma-300M_seq256_mixed-precision.tflite` + `sentencepiece.model` | Gemma terms (gated: accept on Hugging Face and download yourself) |

all-MiniLM-L6-v2 was left out: it is English-only, and its WordPiece tokenizer isn't supported by the Dart tokenizer used here.

Models go in `models/<key>/` (ignored by git).

## Run

```sh
flutter build apk --profile
adb install -r build/app/outputs/flutter-apk/app-profile.apk
# Copy the models into the app's own storage:
adb shell mkdir -p /sdcard/Android/data/com.example.vera_n.embedding_bench/files/models
adb push models/e5-small /sdcard/Android/data/com.example.vera_n.embedding_bench/files/models/
# For each model: choose it, start the app, read the result line.
echo e5-small | adb shell "cat > /sdcard/Android/data/com.example.vera_n.embedding_bench/files/run.txt"
adb logcat -c && adb shell am start -n com.example.vera_n.embedding_bench/.MainActivity
adb logcat -s flutter:I | grep BENCH
```

Afterwards: `adb uninstall com.example.vera_n.embedding_bench`, which also removes the copied models.

## Build notes

`android/gradle.properties` relaxes two Kotlin checks that the plugins trip on Windows: a Java/Kotlin JVM-target mismatch inside `flutter_onnxruntime`, and incremental caches failing across drives. `android/app/proguard-rules.pro` keeps ONNX Runtime's classes.
