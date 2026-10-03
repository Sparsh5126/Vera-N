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
import 'state/note_editor_controller.dart';
import 'state/note_providers.dart';
import 'widgets/note_actions.dart';
import 'widgets/note_details.dart';
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

  @override
  void initState() {
    super.initState();
    final repo = ref.read(notesRepositoryProvider);
    _editor = NoteEditorController(repo, ref: widget.noteRef);
    _actions = NoteActions(_editor, ref.read(searchRepositoryProvider));
    // Details below the text hide while typing.
    _focus.addListener(() => setState(() {}));
    _lifecycle = AppLifecycleListener(onInactive: _editor.save);
    final noteRef = widget.noteRef;
    if (noteRef == null) {
      _text = TitledTextController();
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
    setState(() => _text = TitledTextController(text: note?.body ?? ''));
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
    messenger.showSnackBar(
      SnackBar(
        content: const Text(AppCopy.movedToTrash),
        duration: AppMotion.undoWindow,
        action: SnackBarAction(
          label: AppCopy.undo,
          onPressed: () => unawaited(repo.restore(trashed)),
        ),
      ),
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

  /// A tap below the text starts editing at its end.
  void _editAtEnd() {
    final text = _text;
    if (text == null) return;
    text.selection = TextSelection.collapsed(offset: text.text.length);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final text = _text?..titleStyle = context.textStyles.noteTitle;
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int?>(
          valueListenable: _editor.noteRef,
          builder: (context, noteRef, _) => Consumer(
            builder: (context, ref, _) {
              final note = noteRef == null
                  ? null
                  : ref.watch(noteProvider(noteRef)).value;
              return Column(
                children: [
                  _topBar(note),
                  Expanded(
                    child: text == null
                        ? const SizedBox.shrink()
                        : _body(text, note),
                  ),
                ],
              );
            },
          ),
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
      onMove: note == null
          ? null
          : () => unawaited(_actions.moveToFolder(context, note)),
      onDelete: () => unawaited(_delete()),
    );
  }

  Widget _body(TitledTextController text, Note? note) {
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    final typing = _focus.hasFocus && keyboardUp;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _readable(_editorField(text))),
        if (note != null && !typing)
          SliverToBoxAdapter(
            child: _readable(
              NoteDetails(
                tags: note.tags,
                onAddTag: () => unawaited(_actions.addTag(context, note)),
                onTagTap: (tag) =>
                    unawaited(_actions.tagTapped(context, note, tag)),
              ),
            ),
          ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _editAtEnd,
          ),
        ),
      ],
    );
  }

  Widget _readable(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.readableWidth),
        child: Padding(padding: AppSpace.screen, child: child),
      ),
    );
  }

  Widget _editorField(TitledTextController text) {
    return TextField(
      controller: text,
      focusNode: _focus,
      autofocus: widget.noteRef == null,
      onChanged: _editor.onTextChanged,
      style: context.textStyles.body,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }
}
