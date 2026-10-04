# Model trimming: English + Hindi

Shrinks paraphrase-multilingual-MiniLM-L12-v2 (int8 ONNX) from 118 MB to 45 MB so Vera N stays under the user's 150 MB app-size limit (decided 2026-10-04). About 96 MB of the model is a word-piece table for ~50 languages. This keeps only the pieces English, Hindi (Devanagari) and romanized Hindi need; the rest of the model is unchanged.

## How pieces are chosen (`trim.py --words 300000`)

The model splits text into words before breaking words into pieces, so the pieces a word gets depend only on that word. Kept:

- the special tokens (`<s>`, `<pad>`, `</s>`, `<unk>`), with unchanged ids;
- every piece the full tokenizer uses for the 300,000 most common English words in [wordfreq](https://github.com/rspeer/wordfreq), in lower case, Capitalized and UPPER case. wordfreq's English list comes from Wikipedia, subtitles and social media, so it also holds common romanized Hindi ("karna", "kal", "bhai", "nahi", …);
- every non-Latin piece written in Devanagari, digits, punctuation, ₹ and common symbols, or emoji;
- every 1–2 letter Latin piece, so any word can still be spelled out.

Kept rows of the int8 table keep their exact values. A text that tokenizes the same gets exactly the same vector as with the full model.

A simpler cut, keeping the N most frequent Latin pieces (`--latin`), was tried first and rejected. Frequency across all languages drops pieces English needs: at 50,000 pieces only 22% of English paragraphs tokenized the same, and related-pair similarity fell.

## Results (2026-10-04)

`validate.py`, full vs trimmed:

| Text | Same tokens | Cosine to full, mean (min) | ≥ 0.98 |
|---|---|---|---|
| 400 paragraphs of *Pride and Prejudice* (public domain) | 294 / 400 | 0.994 (0.819) | 92.5% |
| 30 everyday notes, mostly Hinglish (`pairs.py`) | 29 / 30 | 0.998 (0.934) | 96.7% |
| 12 related pairs, en / hi / Hinglish | identical: 24/24 top-1, partner mean 0.705, unrelated 0.090 | | |

Remaining differences come from rare words such as names. On the phone (Snapdragon 778G, `tool/embedding_bench`, 3 runs each), quality was identical. Load time fell from 1.6–2.1 s to 0.54–0.79 s, memory while loaded from 421–477 MB to 299–314 MB, and speed was unchanged (13 / 25–27 / 56–57 ms for short / medium / long notes).

Size in the app: model 44.9 MB (29.2 MB compressed in the APK) plus tokenizer 2.4 MB (0.9 MB). Projected app: about 71 MB to download and about 118 MB on the phone (APK plus the unpacked model).

**Trade-off:** notes in other scripts (Tamil, Bengali, Japanese, …) get weak suggestions; they are still saved and searchable.

## Run

```sh
python -m venv .venv
.venv/Scripts/pip install -r requirements.txt
# FULL_DIR: model_int8.onnx + tokenizer.json from
#   huggingface.co/Xenova/paraphrase-multilingual-MiniLM-L12-v2
python trim.py FULL_DIR out/words300000 --words 300000
# English sample: gutenberg.org/cache/epub/1342/pg1342.txt -> corpus/pride_and_prejudice.txt
python validate.py FULL_DIR out/words300000
```
