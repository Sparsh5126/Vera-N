import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/models/note.dart';
import '../../core/navigation/routes.dart';
import '../../core/platform/launch_channel.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'state/link_typing.dart';
import 'state/markup_editing.dart';
import 'state/note_editor_controller.dart';
import 'state/note_providers.dart';
import 'widgets/format_bar.dart';
import 'widgets/note_actions.dart';
import 'widgets/note_details.dart';
import 'widgets/note_editor_view.dart';
import 'widgets/note_format_actions.dart';
import 'widgets/note_top_bar.dart';
import 'widgets/titled_text_controller.dart';

/// Write and read one note. New notes open with the keyboard up; existing
/// ones open showing the text, and a tap anywhere starts editing.
class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key, this.noteRef});

  /// Null for a new note.
  final int? noteRef;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late final NoteEditorController _editor;
  late final NoteActions _actions;
  late final AppLifecycleListener _lifecycle;
  final _focus = FocusNode();
  TitledTextController? _text;

  /// Text before the latest change, to notice a freshly typed `[[`.
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    final repo = ref.read(notesRepositoryProvider);
    _editor = NoteEditorController(repo, ref: widget.noteRef);
    _actions = NoteActions(
      _editor,
      ref.read(searchRepositoryProvider),
      ref.read(linksRepositoryProvider),
      repo,
    );
    // Details below the text hide while typing.
    _focus.addListener(() => setState(() {}));
    _lifecycle = AppLifecycleListener(onInactive: _editor.save);
    final noteRef = widget.noteRef;
    if (noteRef == null) {
      _text = _newText('');
      // First frame with the focused editor: the cursor is ready to type.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(LaunchChannel.logTypingReady()),
      );
    } else {
      unawaited(repo.getNote(noteRef).then(_loaded));
    }
  }

  void _loaded(Note? note) {
    if (!mounted) return;
    _lastText = note?.body ?? '';
    setState(() => _text = _newText(_lastText));
  }

  TitledTextController _newText(String body) {
    final text = TitledTextController(text: body);
    text.onCheckboxToggled = () => _onTextChanged(text.text);
    return text;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _focus.dispose();
    _text?.dispose();
    unawaited(_editor.dispose());
    super.dispose();
  }

  Future<void> _delete() async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(notesRepositoryProvider);
    final trashed = await _editor.trash();
    if (!mounted) return;
    _leave();
    if (trashed == null) return;
    UndoSnackBar.show(
      messenger,
      message: AppCopy.movedToTrash,
      onUndo: () => unawaited(repo.restore(trashed)),
    );
  }

  /// Back to where the user came from, or Home when the note was opened
  /// straight from a capture shortcut.
  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  void _onTextChanged(String value) {
    final before = _lastText;
    _lastText = value;
    _editor.onTextChanged(value);
    final text = _text;
    if (text != null && LinkTyping.justOpened(before, text.value)) {
      unawaited(_insertLink(text));
    }
  }

  Future<void> _insertLink(TitledTextController text) async {
    final link = await _actions.pickLink(context, _editor.noteRef.value);
    if (link != null && mounted) {
      text.value = LinkTyping.insert(text.value, link);
      _onTextChanged(text.text);
    }
    if (mounted) _focus.requestFocus();
  }

  void _openNote(int noteRef) => context.push(Routes.note(noteRef));

  /// Tapping inside a link's title opens the linked note.
  void _onEditorTap() {
    final text = _text;
    if (text == null) return;
    final link = MarkupEditing.linkAt(text.text, text.selection.baseOffset);
    if (link != null) unawaited(_openLink(link.target!));
  }

  Future<void> _openLink(String target) async {
    final linked = await ref.read(linksRepositoryProvider).findNote(target);
    if (linked == null || !mounted) return;
    _focus.unfocus();
    _openNote(linked);
  }

  /// A tap below the text starts editing at its end.
  void _editAtEnd() {
    final text = _text;
    if (text == null) return;
    text.selection = TextSelection.collapsed(offset: text.text.length);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final text = _text
      ?..titleStyle = context.textStyles.noteTitle
      ..palette = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _watchNote(_topBar),
            Expanded(
              child: text == null ? const SizedBox.shrink() : _body(text),
            ),
            if (text != null) _formatBar(text),
          ],
        ),
      ),
    );
  }

  /// Rebuilds only [builder]'s part when the note changes (pin, tags,
  /// saves), so the editor itself never rebuilds while typing.
  Widget _watchNote(Widget Function(Note? note) builder) {
    return ValueListenableBuilder<int?>(
      valueListenable: _editor.noteRef,
      builder: (context, noteRef, _) => Consumer(
        builder: (context, ref, _) => builder(
          noteRef == null ? null : ref.watch(noteProvider(noteRef)).value,
        ),
      ),
    );
  }

  Widget _topBar(Note? note) {
    return NoteTopBar(
      saves: _editor.saves,
      pinned: note?.pinned ?? false,
      onBack: _leave,
      onPinChanged: note == null
          ? null
          : (value) => unawaited(_editor.setPinned(value)),
      onCopy: note == null
          ? null
          : () => unawaited(_actions.copy(context, _text?.text ?? note.body)),
      onMove: note == null
          ? null
          : () => unawaited(_actions.moveToFolder(context, note)),
      onDelete: () => unawaited(_delete()),
    );
  }

  Widget _body(TitledTextController text) {
    return NoteEditorView(
      text: text,
      focus: _focus,
      autofocus: widget.noteRef == null,
      onChanged: _onTextChanged,
      onTap: _onEditorTap,
      onTapBelow: _editAtEnd,
      details: _watchNote(
        (note) => note == null
            ? const SizedBox.shrink()
            : NoteEditorView.readable(_details(note)),
      ),
    );
  }

  /// Shown above the keyboard only while text is selected.
  Widget _formatBar(TitledTextController text) {
    final format = NoteFormatActions(text, _actions, _onTextChanged);
    return FormatBar.whileSelecting(
      text: text,
      focus: _focus,
      onBold: format.bold,
      onList: format.list,
      onChecklist: format.checklist,
      onLink: () => unawaited(format.link(context, _editor.noteRef.value)),
    );
  }

  Widget _details(Note note) {
    return Consumer(
      builder: (context, ref, _) => NoteDetails(
        folder: note.folder,
        onFolderTap: () => unawaited(_actions.moveToFolder(context, note)),
        tags: note.tags,
        linked: ref.watch(linkedProvider(note.ref)).value ?? const [],
        mentionedIn: ref.watch(mentionedInProvider(note.ref)).value ?? const [],
        onAddTag: () => unawaited(_actions.addTag(context, note)),
        onTagTap: (tag) => unawaited(_actions.tagTapped(context, note, tag)),
        onOpenNote: _openNote,
      ),
    );
  }
}
