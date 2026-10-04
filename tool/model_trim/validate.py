"""Compare a trimmed model with the full one on real text.

For each text: does it tokenize the same, and how close are the two
embeddings (cosine; 1.0 means identical)? Also runs the benchmark's
Hindi / English / Hinglish pair test on both models.

Usage:
  python validate.py FULL_DIR TRIMMED_DIR
"""

import argparse
import re
import sys

import numpy as np
import onnxruntime as ort
from tokenizers import Tokenizer

sys.path.insert(0, ".")
from pairs import PAIRS, NOTES  # noqa: E402


def load(d):
    tok = Tokenizer.from_file(f"{d}/tokenizer.json")
    so = ort.SessionOptions()
    so.intra_op_num_threads = 4
    sess = ort.InferenceSession(f"{d}/model_int8.onnx", so)
    return tok, sess


def embed(tok, sess, text):
    ids = tok.encode(text).ids
    n = len(ids)
    feeds = {
        "input_ids": np.array([ids], dtype=np.int64),
        "attention_mask": np.ones((1, n), dtype=np.int64),
        "token_type_ids": np.zeros((1, n), dtype=np.int64),
    }
    hidden = sess.run(None, feeds)[0][0]
    v = hidden.mean(axis=0)
    return ids, v / np.linalg.norm(v)


def english_sample(path, count=400):
    text = open(path, encoding="utf-8").read().replace("\r\n", "\n")
    start = text.find("*** START OF")
    end = text.find("*** END OF")
    body = text[start:end] if start != -1 else text
    paras = [p.replace("\n", " ").strip() for p in body.split("\n\n")]
    paras = [p for p in paras if 40 < len(p) < 600 and not p.startswith("CHAPTER")]
    step = max(1, len(paras) // count)
    return paras[::step][:count]


def pair_quality(tok, sess):
    texts = [t for p in PAIRS for t in p]
    vecs = [embed(tok, sess, t)[1] for t in texts]
    hits, partner, other = 0, [], []
    for i in range(len(texts)):
        mate = i + 1 if i % 2 == 0 else i - 1
        sims = [(float(vecs[i] @ vecs[j]), j) for j in range(len(texts)) if j != i]
        if max(sims)[1] == mate:
            hits += 1
        for s, j in sims:
            if i < j:
                (partner if j == mate else other).append(s)
    return f"top1 {hits}/{len(texts)}, partner mean {np.mean(partner):.3f}, other mean {np.mean(other):.3f} max {max(other):.3f}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("full")
    ap.add_argument("trimmed")
    args = ap.parse_args()
    full, trimmed = load(args.full), load(args.trimmed)

    groups = {
        "english (Pride and Prejudice)": english_sample("corpus/pride_and_prejudice.txt"),
        "notes (Hindi / English / Hinglish)": NOTES,
    }
    for name, texts in groups.items():
        same, cos = 0, []
        for t in texts:
            ids_a, a = embed(*full, t)
            ids_b, b = embed(*trimmed, t)
            same += len(ids_a) == len(ids_b)
            cos.append(float(a @ b))
        cos = np.array(cos)
        print(
            f"{name}: {len(texts)} texts, same token count {same}/{len(texts)}, "
            f"cosine mean {cos.mean():.4f} min {cos.min():.4f} "
            f"share >= 0.98: {(cos >= 0.98).mean():.1%}"
        )
    print("pairs full:   ", pair_quality(*full))
    print("pairs trimmed:", pair_quality(*trimmed))


if __name__ == "__main__":
    main()
