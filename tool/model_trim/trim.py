"""Trim a multilingual XLM-R-style embedding model to English + Hindi.

Keeps the special tokens, every word piece written only in Latin script,
Devanagari, digits, punctuation, common symbols and emoji, but only the
`--latin` most frequent Latin pieces (plus every 1-2 letter piece, so any
word can still be spelled). Cuts the int8 word-embedding table and the
tokenizer to match, renumbering both together. Rows that are kept keep
their exact values, so a text that tokenizes the same gets the same vector.

Usage:
  python trim.py SRC_DIR OUT_DIR --words 200000   (recommended)
  python trim.py SRC_DIR OUT_DIR --latin 35000    (frequency cut, worse)
SRC_DIR holds model_int8.onnx and tokenizer.json.
"""

import argparse
import json
import os

import numpy as np
import onnx
from onnx import numpy_helper

EMBEDDING = "embeddings.word_embeddings.weight_quantized"
METASPACE = "▁"


def allowed(ch: str) -> bool:
    o = ord(ch)
    return (
        o < 0x250  # Basic Latin, Latin-1, Latin Extended-A/B (digits, punctuation)
        or 0x900 <= o <= 0x97F  # Devanagari
        or 0xA8E0 <= o <= 0xA8FF  # Devanagari Extended
        or 0x1CD0 <= o <= 0x1CFF  # Vedic Extensions
        or 0x2000 <= o <= 0x206F  # General Punctuation (incl. ZWJ / ZWNJ)
        or 0x20A0 <= o <= 0x20CF  # Currency (incl. ₹)
        or 0x2100 <= o <= 0x214F  # Letterlike symbols
        or 0x2190 <= o <= 0x22FF  # Arrows, maths operators
        or 0x2600 <= o <= 0x27BF  # Misc symbols, dingbats
        or 0x1F300 <= o <= 0x1FAFF  # Emoji
        or ch == METASPACE
    )


def is_latin_word(piece: str) -> bool:
    return any(c.isalpha() and ord(c) < 0x250 for c in piece)


def choose(vocab, latin_keep: int):
    """Original ids to keep, in order."""
    latin = [
        (score, i)
        for i, (piece, score) in enumerate(vocab)
        if i >= 4 and all(allowed(c) for c in piece) and is_latin_word(piece)
    ]
    top_latin = {i for _, i in sorted(latin, reverse=True)[:latin_keep]}
    keep = []
    for i, (piece, _) in enumerate(vocab):
        if i < 4:
            keep.append(i)  # <s> <pad> </s> <unk>, ids unchanged
        elif not all(allowed(c) for c in piece):
            continue
        elif not is_latin_word(piece):
            keep.append(i)  # Devanagari, digits, punctuation, symbols, emoji
        elif i in top_latin or len(piece.strip(METASPACE)) <= 2:
            keep.append(i)
    return keep


def choose_by_words(tokenizer_path: str, vocab, word_count: int):
    """Original ids to keep: every piece the full tokenizer uses for the
    `word_count` most common English words (from wordfreq, which also
    holds common romanized Hindi), in lower case, Capitalized and UPPER
    case, plus
    all non-Latin pieces of the allowed scripts and every 1-2 letter
    Latin piece. Text splits into words before pieces, so each listed
    word tokenizes exactly as with the full vocabulary."""
    import wordfreq
    from tokenizers import Tokenizer

    full = Tokenizer.from_file(tokenizer_path)
    words = wordfreq.top_n_list("en", word_count)
    variants = (
        words + [w[:1].upper() + w[1:] for w in words] + [w.upper() for w in words]
    )
    used = set()
    for enc in full.encode_batch(variants, add_special_tokens=False):
        used.update(enc.ids)
    keep = []
    for i, (piece, _) in enumerate(vocab):
        if i < 4:
            keep.append(i)
        elif not all(allowed(c) for c in piece):
            continue
        elif not is_latin_word(piece) or i in used:
            keep.append(i)
        elif len(piece.strip(METASPACE)) <= 2:
            keep.append(i)
    return keep


def trim_tokenizer(tok: dict, keep: list) -> dict:
    remap = {old: new for new, old in enumerate(keep)}
    vocab = tok["model"]["vocab"]
    tok["model"]["vocab"] = [vocab[i] for i in keep]
    tok["model"]["unk_id"] = remap[tok["model"]["unk_id"]]
    added = []
    for a in tok.get("added_tokens", []):
        if a["id"] in remap:
            added.append({**a, "id": remap[a["id"]]})
    tok["added_tokens"] = added
    post = tok.get("post_processor") or {}
    for spec in (post.get("special_tokens") or {}).values():
        spec["ids"] = [remap[i] for i in spec["ids"]]
    return tok


def trim_model(model, keep: list):
    for init in model.graph.initializer:
        if init.name == EMBEDDING:
            table = numpy_helper.to_array(init)
            init.CopyFrom(numpy_helper.from_array(table[np.array(keep)], init.name))
            return table.shape
    raise SystemExit(f"{EMBEDDING} not found")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("out")
    ap.add_argument("--latin", type=int, help="keep the N most frequent Latin pieces")
    ap.add_argument("--words", type=int, help="keep the pieces of the N most common English words")
    args = ap.parse_args()

    tok_path = os.path.join(args.src, "tokenizer.json")
    tok = json.load(open(tok_path, encoding="utf-8"))
    if args.words:
        keep = choose_by_words(tok_path, tok["model"]["vocab"], args.words)
    else:
        keep = choose(tok["model"]["vocab"], args.latin or 35000)

    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, "tokenizer.json"), "w", encoding="utf-8") as f:
        json.dump(trim_tokenizer(tok, keep), f, ensure_ascii=False)

    model = onnx.load(os.path.join(args.src, "model_int8.onnx"))
    before = trim_model(model, keep)
    out_model = os.path.join(args.out, "model_int8.onnx")
    onnx.save(model, out_model)

    stats = {
        "latin_keep": args.latin,
        "words": args.words,
        "vocab_before": before[0],
        "vocab_after": len(keep),
        "model_mb": round(os.path.getsize(out_model) / 1e6, 1),
        "tokenizer_mb": round(
            os.path.getsize(os.path.join(args.out, "tokenizer.json")) / 1e6, 1
        ),
    }
    json.dump(stats, open(os.path.join(args.out, "trim.json"), "w"), indent=2)
    print(json.dumps(stats))


if __name__ == "__main__":
    main()
