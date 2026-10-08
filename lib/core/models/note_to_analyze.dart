/// A note whose text (or the model) changed since it was last analyzed.
class NoteToAnalyze {
  const NoteToAnalyze(this.ref, this.body, this.contentHash);

  final int ref;
  final String body;
  final String contentHash;
}
