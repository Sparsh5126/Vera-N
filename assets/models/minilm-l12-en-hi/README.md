# minilm-l12-en-hi

The on-device embedding model Vera N bundles (decided 2026-10-04, docs/ARCHITECTURE.md §8).

| File | SHA-256 |
|---|---|
| `model_int8.onnx` (44.9 MB) | `ff7bf46c551dbb3e7785ab96aacf343e948bd451ac0a48cabd959ac9da58b74b` |
| `tokenizer.json` (2.4 MB) | `7f777cc4f8b250c34a72c5944a946be9431445fc1f91a7c294955a0a4e500617` |

Stored with Git LFS.

## Source

- **Model:** [sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2](https://huggingface.co/sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2), Apache License 2.0 (`LICENSE` in this folder).
- **int8 ONNX export:** [Xenova/paraphrase-multilingual-MiniLM-L12-v2](https://huggingface.co/Xenova/paraphrase-multilingual-MiniLM-L12-v2), `onnx/model_int8.onnx` and `tokenizer.json`.

## Changes made (notice under Apache-2.0 §4b)

The word-piece table and tokenizer were trimmed to English + Hindi by `tool/model_trim/trim.py --words 300000`. Pieces outside English, Devanagari, romanized Hindi, symbols and emoji were removed, and the remaining ids renumbered. No weights were retrained or altered; kept rows are byte-identical to the original. Method and validation: `tool/model_trim/README.md`.

## Use

Input: `input_ids`, `attention_mask`, `token_type_ids` (int64, `[1, n]`, n ≤ 128). Output: `last_hidden_state` `[1, n, 384]`. Mean-pool over tokens, then L2-normalize. A "strong" match is cosine ≥ 0.60 at launch (decided 2026-10-04).
