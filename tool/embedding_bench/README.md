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

## Results: 2026-10-04

Phone: Snapdragon 778G (SM7325), 7.4 GB RAM, Android 15; charging, 39 °C. Profile build, 4 CPU threads. Three fresh launches per model, alternating. Raw log: `results-2026-10-04.txt`. EmbeddingGemma was not run (the user chose open models only).

| | multilingual-e5-small int8 | paraphrase-multilingual-MiniLM-L12-v2 int8 |
|---|---|---|
| Files | 113 MB model + 16 MB tokenizer | 113 MB model + 16 MB tokenizer |
| Load time (3 runs) | 2.4 / 2.0 / 1.5 s | 2.1 / 1.7 / 1.5 s |
| Memory, idle → loaded | 165 → 417–474 MB | 165 → 417–475 MB |
| Memory peak during runs | 500–557 MB | 503–559 MB |
| Short note (15–18 tokens), median | 15.6–16.8 ms | 13.5–16.6 ms |
| Medium note (52–55 tokens), median | 26.3–29.0 ms | 23.5–27.1 ms |
| Long note, median | 93–96 ms (211 tokens) | 52–61 ms (cut at **128 tokens**) |
| Tokenizing in Dart | 0.3 / 1.0 / 3–5 ms | 0.3 / 1.0 / 3.6–5.6 ms |
| Quality: nearest neighbour is the partner | 22 / 24 | **24 / 24** |
| Quality: partner similarity, mean (lowest 10%) | 0.89 (0.86) | 0.71 (0.46) |
| Quality: unrelated similarity, mean (top 10%, max) | 0.80 (0.84, 0.87) | 0.09 (0.22, 0.50) |

Quality numbers were identical on all three runs.

What this says, within the limits of a 24-text set:

- **Speed is not the deciding factor.** Both embed a typical note in 15–30 ms. A library of 1,000 notes at about 3 chunks each would take roughly 1–2 minutes of CPU. That is an estimate from these timings, not a battery measurement.
- **Memory is the real cost.** Either model adds about 250 MB while loaded. The plan to load the model, run a batch, and release it (CLAUDE.md §8) is necessary, not optional.
- **The multilingual MiniLM separates related from unrelated far better on this set.** Its unrelated pairs sit near 0.1 and its related pairs near 0.7, with only a small overlap: the closest unrelated pair scored 0.50, while the lowest tenth of related pairs scored 0.46 or less. e5-small scores everything between 0.80 and 0.89, so related and unrelated pairs overlap, and a "strong match" threshold would have almost no room.
- **MiniLM reads only 128 tokens** (about 80–100 words). Long notes must be split into chunks, which product spec §4 already plans.
- **App size:** about 130 MB with either model, whether it is bundled or downloaded once.

## Build notes

`android/gradle.properties` relaxes two Kotlin checks that the plugins trip on Windows: a Java/Kotlin JVM-target mismatch inside `flutter_onnxruntime`, and incremental caches failing across drives. `android/app/proguard-rules.pro` keeps ONNX Runtime's classes.
