import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/suggestions/suggestion_providers.dart';
import '../../core/copy/app_copy.dart';
import '../../core/models/archive_folder.dart';
import '../../core/models/locked_folder.dart';
import '../../core/models/note.dart';
import '../../core/platform/device_lock.dart';
import '../../core/security/locked_session.dart';
import '../../core/navigation/routes.dart';
import '../../core/platform/launch_channel.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../core/utils/date_label.dart';
import '../../shared/widgets/suggestion_flow.dart';
import '../../shared/widgets/undo_snack_bar.dart';
import 'state/attachment_insert.dart';
import 'state/link_typing.dart';
import 'state/markup_editing.dart';
import 'state/note_editor_controller.dart';
import 'state/note_providers.dart';
import 'widgets/conflict_flow.dart';
import 'widgets/conflict_notice.dart';
import 'widgets/locked_note_gate.dart';
import 'widgets/note_attachments.dart';
import 'widgets/format_bar.dart';
import 'widgets/note_actions.dart';
import 'widgets/note_details_section.dart';
import 'widgets/note_editor_view.dart';
import 'widgets/note_format_actions.dart';
import 'widgets/note_top_bar.dart';
import 'widgets/titled_text_controller.dart';

/// Write and read one note. New notes open with the keyboard up; existing
/// ones open showing the text, and a tap anywhere starts editing.
class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key, this.noteRef, this.onClose});

  /// Null for a new note.
  final int? noteRef;

  /// On a wide window the note sits beside the list: back, delete and
  /// archive close it there instead of leaving a screen.
  final VoidCallback? onClose;

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  late final NoteEditorController _editor;
  late final NoteActions _actions;
  late final AppLifecycleListener _lifecycle;
  late final _conflicts = ConflictFlow(
    resolver: ref.read(storageProvider).conflicts,
    beforeChange: _editor.save,
    afterChange: _reloadText,
  );
  late final _suggestions = SuggestionFlow(
    load: ref.read(suggestionViewsProvider).load,
    accept: ref.read(suggestionActionsProvider).accept,
    reject: ref.read(suggestionActionsProvider).reject,
    notSure: ref.read(suggestionActionsProvider).notSure,
    dateLabel: (d) => DateLabel.of(d, DateTime.now()),
    beforeChange: _editor.save,
    afterChange: _reloadText,
    onOpenNote: _openNote,
  );
  late final _attachments = NoteAttachments(
    ref: ref,
    text: () => _text,
    mounted: () => mounted,
    onEdited: _onTextChanged,
  );
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
    // A locked note asks for the phone's lock right away.
    if (note != null && LockedFolder.contains(note.folder)) {
      unawaited(ref.read(lockedSessionProvider.notifier).open());
    }
  }

  TitledTextController _newText(String body) {
    final text = TitledTextController(text: body);
    text.onCheckboxToggled = () => _onTextChanged(text.text);
    text.embedBuilder = (name) => _attachments.embed(context, name);
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
    final onClose = widget.onClose;
    if (onClose != null) return onClose();
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

  /// After a change made outside the editor (an accepted link added to
  /// this note), shows the saved text.
  Future<void> _reloadText() async {
    final noteRef = _editor.noteRef.value;
    final text = _text;
    if (noteRef == null || text == null) return;
    final note = await ref.read(notesRepositoryProvider).getNote(noteRef);
    if (note == null || !mounted || note.body == text.text) return;
    _lastText = note.body;
    text.value = TextEditingValue(
      text: note.body,
      selection: TextSelection.collapsed(offset: note.body.length),
    );
  }

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
    final before = text.text;
    // Under a final photo or drawing, a line to write on (see roomAfter).
    text.value = AttachmentInsert.roomAfter(
      TextEditingValue(
        text: before,
        selection: TextSelection.collapsed(offset: before.length),
      ),
    );
    if (text.text != before) _onTextChanged(text.text);
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
            _watchNote(_conflict),
            Expanded(
              child: LockedNoteGate(
                noteRef: widget.noteRef,
                child: Column(
                  children: [
                    Expanded(
                      child: text == null
                          ? const SizedBox.shrink()
                          : _body(text),
                    ),
                    if (text != null) _formatBar(text),
                  ],
                ),
              ),
            ),
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
      onDelete: () => unawaited(_delete()),
      onAttach: _chooseAttachment,
      archived: note != null && ArchiveFolder.contains(note.folder),
      locked: note != null && LockedFolder.contains(note.folder),
      onLock: note == null ? null : () => unawaited(_toggleLock(note)),
      onArchive: note == null
          ? null
          : () =>
                unawaited(_actions.toggleArchive(context, note, leave: _leave)),
    );
  }

  /// Both versions are kept until the user picks (product spec §14).
  Widget _conflict(Note? note) {
    if (note == null || !note.conflict) return const SizedBox.shrink();
    final ref = note.ref;
    return ConflictNotice(
      onCompare: () => unawaited(_conflicts.compare(context, ref)),
      onKeepThis: () => unawaited(_conflicts.keepThis(context, ref)),
      onKeepOther: () => unawaited(_conflicts.keepOther(context, ref)),
      onKeepBoth: () => unawaited(_conflicts.keepBoth(context, ref)),
    );
  }

  Widget _body(TitledTextController text) {
    final format = NoteFormatActions(text, _actions, _onTextChanged);
    // A keyboard (laptop, docs/LAPTOP_PLAN.md L1): Ctrl+B bold, Ctrl+K
    // link to a note, beside the same buttons above the keyboard.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            format.bold,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            unawaited(format.link(context, _editor.noteRef.value)),
      },
      child: _editorView(text),
    );
  }

  Widget _editorView(TitledTextController text) {
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
            : NoteEditorView.readable(
                NoteDetailsSection(
                  note: note,
                  actions: _actions,
                  suggestions: _suggestions,
                  onOpenNote: _openNote,
                ),
              ),
      ),
    );
  }

  /// Shown above the keyboard while editing: attach, and the formatting
  /// buttons while text is selected.
  Widget _formatBar(TitledTextController text) {
    final format = NoteFormatActions(text, _actions, _onTextChanged);
    return FormatBar.whileEditing(
      text: text,
      focus: _focus,
      onBold: format.bold,
      onList: format.list,
      onChecklist: format.checklist,
      onLink: () => unawaited(format.link(context, _editor.noteRef.value)),
      onAttach: _chooseAttachment,
    );
  }

  Future<void> _toggleLock(Note note) => _actions.toggleLock(
    context,
    note,
    hasScreenLock: ref.read(deviceLockProvider).hasScreenLock,
    forgetLocked: ref.read(storageProvider).analysis.forgetLocked,
    leave: _leave,
  );

  void _chooseAttachment() => _attachments.choose(context);
}
