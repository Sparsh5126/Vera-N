// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathKeyMeta = const VerificationMeta(
    'pathKey',
  );
  @override
  late final GeneratedColumn<String> pathKey = GeneratedColumn<String>(
    'path_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headerRawMeta = const VerificationMeta(
    'headerRaw',
  );
  @override
  late final GeneratedColumn<String> headerRaw = GeneratedColumn<String>(
    'header_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newlineMeta = const VerificationMeta(
    'newline',
  );
  @override
  late final GeneratedColumn<String> newline = GeneratedColumn<String>(
    'newline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('\n'),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<DateTime> modified = GeneratedColumn<DateTime>(
    'modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileModifiedMsMeta = const VerificationMeta(
    'fileModifiedMs',
  );
  @override
  late final GeneratedColumn<int> fileModifiedMs = GeneratedColumn<int>(
    'file_modified_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingWriteMeta = const VerificationMeta(
    'pendingWrite',
  );
  @override
  late final GeneratedColumn<bool> pendingWrite = GeneratedColumn<bool>(
    'pending_write',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_write" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conflictMeta = const VerificationMeta(
    'conflict',
  );
  @override
  late final GeneratedColumn<bool> conflict = GeneratedColumn<bool>(
    'conflict',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("conflict" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trashedAtMeta = const VerificationMeta(
    'trashedAt',
  );
  @override
  late final GeneratedColumn<DateTime> trashedAt = GeneratedColumn<DateTime>(
    'trashed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    path,
    pathKey,
    folder,
    title,
    body,
    headerRaw,
    newline,
    contentHash,
    pinned,
    created,
    modified,
    fileModifiedMs,
    fileSize,
    pendingWrite,
    revision,
    conflict,
    trashedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('path_key')) {
      context.handle(
        _pathKeyMeta,
        pathKey.isAcceptableOrUnknown(data['path_key']!, _pathKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pathKeyMeta);
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    } else if (isInserting) {
      context.missing(_folderMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('header_raw')) {
      context.handle(
        _headerRawMeta,
        headerRaw.isAcceptableOrUnknown(data['header_raw']!, _headerRawMeta),
      );
    }
    if (data.containsKey('newline')) {
      context.handle(
        _newlineMeta,
        newline.isAcceptableOrUnknown(data['newline']!, _newlineMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedMeta);
    }
    if (data.containsKey('file_modified_ms')) {
      context.handle(
        _fileModifiedMsMeta,
        fileModifiedMs.isAcceptableOrUnknown(
          data['file_modified_ms']!,
          _fileModifiedMsMeta,
        ),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('pending_write')) {
      context.handle(
        _pendingWriteMeta,
        pendingWrite.isAcceptableOrUnknown(
          data['pending_write']!,
          _pendingWriteMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('conflict')) {
      context.handle(
        _conflictMeta,
        conflict.isAcceptableOrUnknown(data['conflict']!, _conflictMeta),
      );
    }
    if (data.containsKey('trashed_at')) {
      context.handle(
        _trashedAtMeta,
        trashedAt.isAcceptableOrUnknown(data['trashed_at']!, _trashedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      pathKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path_key'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      headerRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header_raw'],
      ),
      newline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}newline'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified'],
      )!,
      fileModifiedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_modified_ms'],
      ),
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      pendingWrite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_write'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      conflict: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}conflict'],
      )!,
      trashedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trashed_at'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;

  /// Header `id`; null for headerless notes (identity is then the path).
  final String? noteId;

  /// Path inside `Notes/`, `/`-separated, as written on disk.
  final String path;

  /// Lower-cased [path]: paths compare case-insensitively.
  final String pathKey;

  /// Subfolder path, '' for the top level.
  final String folder;
  final String title;
  final String body;

  /// Header lines joined with '\n', or null when the file has no header.
  final String? headerRaw;

  /// Line ending used by the file's header.
  final String newline;
  final String contentHash;
  final bool pinned;
  final DateTime created;
  final DateTime modified;

  /// File time and size when last read or written, in milliseconds since
  /// epoch; null until the file exists. Used to skip unchanged files.
  final int? fileModifiedMs;
  final int? fileSize;

  /// The database has text the file doesn't have yet.
  final bool pendingWrite;

  /// Bumped on every change made in the app, so a background file write
  /// only clears [pendingWrite] if no newer change arrived meanwhile.
  final int revision;

  /// The file changed elsewhere while this note had an unsaved edit.
  final bool conflict;
  final DateTime? trashedAt;
  const NoteRow({
    required this.id,
    this.noteId,
    required this.path,
    required this.pathKey,
    required this.folder,
    required this.title,
    required this.body,
    this.headerRaw,
    required this.newline,
    required this.contentHash,
    required this.pinned,
    required this.created,
    required this.modified,
    this.fileModifiedMs,
    this.fileSize,
    required this.pendingWrite,
    required this.revision,
    required this.conflict,
    this.trashedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || noteId != null) {
      map['note_id'] = Variable<String>(noteId);
    }
    map['path'] = Variable<String>(path);
    map['path_key'] = Variable<String>(pathKey);
    map['folder'] = Variable<String>(folder);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || headerRaw != null) {
      map['header_raw'] = Variable<String>(headerRaw);
    }
    map['newline'] = Variable<String>(newline);
    map['content_hash'] = Variable<String>(contentHash);
    map['pinned'] = Variable<bool>(pinned);
    map['created'] = Variable<DateTime>(created);
    map['modified'] = Variable<DateTime>(modified);
    if (!nullToAbsent || fileModifiedMs != null) {
      map['file_modified_ms'] = Variable<int>(fileModifiedMs);
    }
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    map['pending_write'] = Variable<bool>(pendingWrite);
    map['revision'] = Variable<int>(revision);
    map['conflict'] = Variable<bool>(conflict);
    if (!nullToAbsent || trashedAt != null) {
      map['trashed_at'] = Variable<DateTime>(trashedAt);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      noteId: noteId == null && nullToAbsent
          ? const Value.absent()
          : Value(noteId),
      path: Value(path),
      pathKey: Value(pathKey),
      folder: Value(folder),
      title: Value(title),
      body: Value(body),
      headerRaw: headerRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(headerRaw),
      newline: Value(newline),
      contentHash: Value(contentHash),
      pinned: Value(pinned),
      created: Value(created),
      modified: Value(modified),
      fileModifiedMs: fileModifiedMs == null && nullToAbsent
          ? const Value.absent()
          : Value(fileModifiedMs),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      pendingWrite: Value(pendingWrite),
      revision: Value(revision),
      conflict: Value(conflict),
      trashedAt: trashedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(trashedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      noteId: serializer.fromJson<String?>(json['noteId']),
      path: serializer.fromJson<String>(json['path']),
      pathKey: serializer.fromJson<String>(json['pathKey']),
      folder: serializer.fromJson<String>(json['folder']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      headerRaw: serializer.fromJson<String?>(json['headerRaw']),
      newline: serializer.fromJson<String>(json['newline']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      created: serializer.fromJson<DateTime>(json['created']),
      modified: serializer.fromJson<DateTime>(json['modified']),
      fileModifiedMs: serializer.fromJson<int?>(json['fileModifiedMs']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      pendingWrite: serializer.fromJson<bool>(json['pendingWrite']),
      revision: serializer.fromJson<int>(json['revision']),
      conflict: serializer.fromJson<bool>(json['conflict']),
      trashedAt: serializer.fromJson<DateTime?>(json['trashedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'noteId': serializer.toJson<String?>(noteId),
      'path': serializer.toJson<String>(path),
      'pathKey': serializer.toJson<String>(pathKey),
      'folder': serializer.toJson<String>(folder),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'headerRaw': serializer.toJson<String?>(headerRaw),
      'newline': serializer.toJson<String>(newline),
      'contentHash': serializer.toJson<String>(contentHash),
      'pinned': serializer.toJson<bool>(pinned),
      'created': serializer.toJson<DateTime>(created),
      'modified': serializer.toJson<DateTime>(modified),
      'fileModifiedMs': serializer.toJson<int?>(fileModifiedMs),
      'fileSize': serializer.toJson<int?>(fileSize),
      'pendingWrite': serializer.toJson<bool>(pendingWrite),
      'revision': serializer.toJson<int>(revision),
      'conflict': serializer.toJson<bool>(conflict),
      'trashedAt': serializer.toJson<DateTime?>(trashedAt),
    };
  }

  NoteRow copyWith({
    int? id,
    Value<String?> noteId = const Value.absent(),
    String? path,
    String? pathKey,
    String? folder,
    String? title,
    String? body,
    Value<String?> headerRaw = const Value.absent(),
    String? newline,
    String? contentHash,
    bool? pinned,
    DateTime? created,
    DateTime? modified,
    Value<int?> fileModifiedMs = const Value.absent(),
    Value<int?> fileSize = const Value.absent(),
    bool? pendingWrite,
    int? revision,
    bool? conflict,
    Value<DateTime?> trashedAt = const Value.absent(),
  }) => NoteRow(
    id: id ?? this.id,
    noteId: noteId.present ? noteId.value : this.noteId,
    path: path ?? this.path,
    pathKey: pathKey ?? this.pathKey,
    folder: folder ?? this.folder,
    title: title ?? this.title,
    body: body ?? this.body,
    headerRaw: headerRaw.present ? headerRaw.value : this.headerRaw,
    newline: newline ?? this.newline,
    contentHash: contentHash ?? this.contentHash,
    pinned: pinned ?? this.pinned,
    created: created ?? this.created,
    modified: modified ?? this.modified,
    fileModifiedMs: fileModifiedMs.present
        ? fileModifiedMs.value
        : this.fileModifiedMs,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    pendingWrite: pendingWrite ?? this.pendingWrite,
    revision: revision ?? this.revision,
    conflict: conflict ?? this.conflict,
    trashedAt: trashedAt.present ? trashedAt.value : this.trashedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      path: data.path.present ? data.path.value : this.path,
      pathKey: data.pathKey.present ? data.pathKey.value : this.pathKey,
      folder: data.folder.present ? data.folder.value : this.folder,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      headerRaw: data.headerRaw.present ? data.headerRaw.value : this.headerRaw,
      newline: data.newline.present ? data.newline.value : this.newline,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      created: data.created.present ? data.created.value : this.created,
      modified: data.modified.present ? data.modified.value : this.modified,
      fileModifiedMs: data.fileModifiedMs.present
          ? data.fileModifiedMs.value
          : this.fileModifiedMs,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      pendingWrite: data.pendingWrite.present
          ? data.pendingWrite.value
          : this.pendingWrite,
      revision: data.revision.present ? data.revision.value : this.revision,
      conflict: data.conflict.present ? data.conflict.value : this.conflict,
      trashedAt: data.trashedAt.present ? data.trashedAt.value : this.trashedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('path: $path, ')
          ..write('pathKey: $pathKey, ')
          ..write('folder: $folder, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('headerRaw: $headerRaw, ')
          ..write('newline: $newline, ')
          ..write('contentHash: $contentHash, ')
          ..write('pinned: $pinned, ')
          ..write('created: $created, ')
          ..write('modified: $modified, ')
          ..write('fileModifiedMs: $fileModifiedMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('pendingWrite: $pendingWrite, ')
          ..write('revision: $revision, ')
          ..write('conflict: $conflict, ')
          ..write('trashedAt: $trashedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    path,
    pathKey,
    folder,
    title,
    body,
    headerRaw,
    newline,
    contentHash,
    pinned,
    created,
    modified,
    fileModifiedMs,
    fileSize,
    pendingWrite,
    revision,
    conflict,
    trashedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.path == this.path &&
          other.pathKey == this.pathKey &&
          other.folder == this.folder &&
          other.title == this.title &&
          other.body == this.body &&
          other.headerRaw == this.headerRaw &&
          other.newline == this.newline &&
          other.contentHash == this.contentHash &&
          other.pinned == this.pinned &&
          other.created == this.created &&
          other.modified == this.modified &&
          other.fileModifiedMs == this.fileModifiedMs &&
          other.fileSize == this.fileSize &&
          other.pendingWrite == this.pendingWrite &&
          other.revision == this.revision &&
          other.conflict == this.conflict &&
          other.trashedAt == this.trashedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<String?> noteId;
  final Value<String> path;
  final Value<String> pathKey;
  final Value<String> folder;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> headerRaw;
  final Value<String> newline;
  final Value<String> contentHash;
  final Value<bool> pinned;
  final Value<DateTime> created;
  final Value<DateTime> modified;
  final Value<int?> fileModifiedMs;
  final Value<int?> fileSize;
  final Value<bool> pendingWrite;
  final Value<int> revision;
  final Value<bool> conflict;
  final Value<DateTime?> trashedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.path = const Value.absent(),
    this.pathKey = const Value.absent(),
    this.folder = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.headerRaw = const Value.absent(),
    this.newline = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.pinned = const Value.absent(),
    this.created = const Value.absent(),
    this.modified = const Value.absent(),
    this.fileModifiedMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.pendingWrite = const Value.absent(),
    this.revision = const Value.absent(),
    this.conflict = const Value.absent(),
    this.trashedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    required String path,
    required String pathKey,
    required String folder,
    required String title,
    required String body,
    this.headerRaw = const Value.absent(),
    this.newline = const Value.absent(),
    required String contentHash,
    this.pinned = const Value.absent(),
    required DateTime created,
    required DateTime modified,
    this.fileModifiedMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.pendingWrite = const Value.absent(),
    this.revision = const Value.absent(),
    this.conflict = const Value.absent(),
    this.trashedAt = const Value.absent(),
  }) : path = Value(path),
       pathKey = Value(pathKey),
       folder = Value(folder),
       title = Value(title),
       body = Value(body),
       contentHash = Value(contentHash),
       created = Value(created),
       modified = Value(modified);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<String>? noteId,
    Expression<String>? path,
    Expression<String>? pathKey,
    Expression<String>? folder,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? headerRaw,
    Expression<String>? newline,
    Expression<String>? contentHash,
    Expression<bool>? pinned,
    Expression<DateTime>? created,
    Expression<DateTime>? modified,
    Expression<int>? fileModifiedMs,
    Expression<int>? fileSize,
    Expression<bool>? pendingWrite,
    Expression<int>? revision,
    Expression<bool>? conflict,
    Expression<DateTime>? trashedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (path != null) 'path': path,
      if (pathKey != null) 'path_key': pathKey,
      if (folder != null) 'folder': folder,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (headerRaw != null) 'header_raw': headerRaw,
      if (newline != null) 'newline': newline,
      if (contentHash != null) 'content_hash': contentHash,
      if (pinned != null) 'pinned': pinned,
      if (created != null) 'created': created,
      if (modified != null) 'modified': modified,
      if (fileModifiedMs != null) 'file_modified_ms': fileModifiedMs,
      if (fileSize != null) 'file_size': fileSize,
      if (pendingWrite != null) 'pending_write': pendingWrite,
      if (revision != null) 'revision': revision,
      if (conflict != null) 'conflict': conflict,
      if (trashedAt != null) 'trashed_at': trashedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String?>? noteId,
    Value<String>? path,
    Value<String>? pathKey,
    Value<String>? folder,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? headerRaw,
    Value<String>? newline,
    Value<String>? contentHash,
    Value<bool>? pinned,
    Value<DateTime>? created,
    Value<DateTime>? modified,
    Value<int?>? fileModifiedMs,
    Value<int?>? fileSize,
    Value<bool>? pendingWrite,
    Value<int>? revision,
    Value<bool>? conflict,
    Value<DateTime?>? trashedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      path: path ?? this.path,
      pathKey: pathKey ?? this.pathKey,
      folder: folder ?? this.folder,
      title: title ?? this.title,
      body: body ?? this.body,
      headerRaw: headerRaw ?? this.headerRaw,
      newline: newline ?? this.newline,
      contentHash: contentHash ?? this.contentHash,
      pinned: pinned ?? this.pinned,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      fileModifiedMs: fileModifiedMs ?? this.fileModifiedMs,
      fileSize: fileSize ?? this.fileSize,
      pendingWrite: pendingWrite ?? this.pendingWrite,
      revision: revision ?? this.revision,
      conflict: conflict ?? this.conflict,
      trashedAt: trashedAt ?? this.trashedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (pathKey.present) {
      map['path_key'] = Variable<String>(pathKey.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (headerRaw.present) {
      map['header_raw'] = Variable<String>(headerRaw.value);
    }
    if (newline.present) {
      map['newline'] = Variable<String>(newline.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (modified.present) {
      map['modified'] = Variable<DateTime>(modified.value);
    }
    if (fileModifiedMs.present) {
      map['file_modified_ms'] = Variable<int>(fileModifiedMs.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (pendingWrite.present) {
      map['pending_write'] = Variable<bool>(pendingWrite.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (conflict.present) {
      map['conflict'] = Variable<bool>(conflict.value);
    }
    if (trashedAt.present) {
      map['trashed_at'] = Variable<DateTime>(trashedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('path: $path, ')
          ..write('pathKey: $pathKey, ')
          ..write('folder: $folder, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('headerRaw: $headerRaw, ')
          ..write('newline: $newline, ')
          ..write('contentHash: $contentHash, ')
          ..write('pinned: $pinned, ')
          ..write('created: $created, ')
          ..write('modified: $modified, ')
          ..write('fileModifiedMs: $fileModifiedMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('pendingWrite: $pendingWrite, ')
          ..write('revision: $revision, ')
          ..write('conflict: $conflict, ')
          ..write('trashedAt: $trashedAt')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags
    with TableInfo<$NoteTagsTable, NoteTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<int> note = GeneratedColumn<int>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [note, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {note, tag};
  @override
  NoteTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTagRow(
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTagRow extends DataClass implements Insertable<NoteTagRow> {
  final int note;
  final String tag;
  const NoteTagRow({required this.note, required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note'] = Variable<int>(note);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(note: Value(note), tag: Value(tag));
  }

  factory NoteTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTagRow(
      note: serializer.fromJson<int>(json['note']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'note': serializer.toJson<int>(note),
      'tag': serializer.toJson<String>(tag),
    };
  }

  NoteTagRow copyWith({int? note, String? tag}) =>
      NoteTagRow(note: note ?? this.note, tag: tag ?? this.tag);
  NoteTagRow copyWithCompanion(NoteTagsCompanion data) {
    return NoteTagRow(
      note: data.note.present ? data.note.value : this.note,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagRow(')
          ..write('note: $note, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(note, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTagRow && other.note == this.note && other.tag == this.tag);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTagRow> {
  final Value<int> note;
  final Value<String> tag;
  final Value<int> rowid;
  const NoteTagsCompanion({
    this.note = const Value.absent(),
    this.tag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    required int note,
    required String tag,
    this.rowid = const Value.absent(),
  }) : note = Value(note),
       tag = Value(tag);
  static Insertable<NoteTagRow> custom({
    Expression<int>? note,
    Expression<String>? tag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (note != null) 'note': note,
      if (tag != null) 'tag': tag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTagsCompanion copyWith({
    Value<int>? note,
    Value<String>? tag,
    Value<int>? rowid,
  }) {
    return NoteTagsCompanion(
      note: note ?? this.note,
      tag: tag ?? this.tag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (note.present) {
      map['note'] = Variable<int>(note.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('note: $note, ')
          ..write('tag: $tag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final Index notesModified = Index(
    'notes_modified',
    'CREATE INDEX notes_modified ON notes (trashed_at, modified)',
  );
  late final Index notesNoteId = Index(
    'notes_note_id',
    'CREATE INDEX notes_note_id ON notes (note_id)',
  );
  late final Index notesFolder = Index(
    'notes_folder',
    'CREATE INDEX notes_folder ON notes (folder)',
  );
  late final Index noteTagsTag = Index(
    'note_tags_tag',
    'CREATE INDEX note_tags_tag ON note_tags (tag)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notes,
    noteTags,
    notesModified,
    notesNoteId,
    notesFolder,
    noteTagsTag,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String?> noteId,
  required String path,
  required String pathKey,
  required String folder,
  required String title,
  required String body,
  Value<String?> headerRaw,
  Value<String> newline,
  required String contentHash,
  Value<bool> pinned,
  required DateTime created,
  required DateTime modified,
  Value<int?> fileModifiedMs,
  Value<int?> fileSize,
  Value<bool> pendingWrite,
  Value<int> revision,
  Value<bool> conflict,
  Value<DateTime?> trashedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String?> noteId,
  Value<String> path,
  Value<String> pathKey,
  Value<String> folder,
  Value<String> title,
  Value<String> body,
  Value<String?> headerRaw,
  Value<String> newline,
  Value<String> contentHash,
  Value<bool> pinned,
  Value<DateTime> created,
  Value<DateTime> modified,
  Value<int?> fileModifiedMs,
  Value<int?> fileSize,
  Value<bool> pendingWrite,
  Value<int> revision,
  Value<bool> conflict,
  Value<DateTime?> trashedAt,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTagRow>>
  _noteTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'notes__id__note_tags__note',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.note.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathKey => $composableBuilder(
    column: $table.pathKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headerRaw => $composableBuilder(
    column: $table.headerRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newline => $composableBuilder(
    column: $table.newline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileModifiedMs => $composableBuilder(
    column: $table.fileModifiedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingWrite => $composableBuilder(
    column: $table.pendingWrite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get conflict => $composableBuilder(
    column: $table.conflict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trashedAt => $composableBuilder(
    column: $table.trashedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathKey => $composableBuilder(
    column: $table.pathKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headerRaw => $composableBuilder(
    column: $table.headerRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newline => $composableBuilder(
    column: $table.newline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileModifiedMs => $composableBuilder(
    column: $table.fileModifiedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingWrite => $composableBuilder(
    column: $table.pendingWrite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get conflict => $composableBuilder(
    column: $table.conflict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trashedAt => $composableBuilder(
    column: $table.trashedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get pathKey =>
      $composableBuilder(column: $table.pathKey, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get headerRaw =>
      $composableBuilder(column: $table.headerRaw, builder: (column) => column);

  GeneratedColumn<String> get newline =>
      $composableBuilder(column: $table.newline, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<int> get fileModifiedMs => $composableBuilder(
    column: $table.fileModifiedMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<bool> get pendingWrite => $composableBuilder(
    column: $table.pendingWrite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get conflict =>
      $composableBuilder(column: $table.conflict, builder: (column) => column);

  GeneratedColumn<DateTime> get trashedAt =>
      $composableBuilder(column: $table.trashedAt, builder: (column) => column);

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool noteTagsRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> pathKey = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> headerRaw = const Value.absent(),
                Value<String> newline = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> modified = const Value.absent(),
                Value<int?> fileModifiedMs = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<bool> pendingWrite = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> conflict = const Value.absent(),
                Value<DateTime?> trashedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                noteId: noteId,
                path: path,
                pathKey: pathKey,
                folder: folder,
                title: title,
                body: body,
                headerRaw: headerRaw,
                newline: newline,
                contentHash: contentHash,
                pinned: pinned,
                created: created,
                modified: modified,
                fileModifiedMs: fileModifiedMs,
                fileSize: fileSize,
                pendingWrite: pendingWrite,
                revision: revision,
                conflict: conflict,
                trashedAt: trashedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> noteId = const Value.absent(),
                required String path,
                required String pathKey,
                required String folder,
                required String title,
                required String body,
                Value<String?> headerRaw = const Value.absent(),
                Value<String> newline = const Value.absent(),
                required String contentHash,
                Value<bool> pinned = const Value.absent(),
                required DateTime created,
                required DateTime modified,
                Value<int?> fileModifiedMs = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<bool> pendingWrite = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> conflict = const Value.absent(),
                Value<DateTime?> trashedAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                noteId: noteId,
                path: path,
                pathKey: pathKey,
                folder: folder,
                title: title,
                body: body,
                headerRaw: headerRaw,
                newline: newline,
                contentHash: contentHash,
                pinned: pinned,
                created: created,
                modified: modified,
                fileModifiedMs: fileModifiedMs,
                fileSize: fileSize,
                pendingWrite: pendingWrite,
                revision: revision,
                conflict: conflict,
                trashedAt: trashedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (noteTagsRefs) db.noteTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (noteTagsRefs)
                    await $_getPrefetchedData<NoteRow, $NotesTable, NoteTagRow>(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences
                          ._noteTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NotesTableReferences(db, table, p0).noteTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.note == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool noteTagsRefs})
    >;
typedef $$NoteTagsTableCreateCompanionBuilder = NoteTagsCompanion Function({
  required int note,
  required String tag,
  Value<int> rowid,
});
typedef $$NoteTagsTableUpdateCompanionBuilder = NoteTagsCompanion Function({
  Value<int> note,
  Value<String> tag,
  Value<int> rowid,
});

final class $$NoteTagsTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTagRow> {
  $$NoteTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteTable(_$AppDatabase db) =>
      db.notes.createAlias('note_tags__note__notes__id');

  $$NotesTableProcessedTableManager get note {
    final $_column = $_itemColumn<int>('note')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get note {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.note,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get note {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.note,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  $$NotesTableAnnotationComposer get note {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.note,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTagsTable,
          NoteTagRow,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTagRow, $$NoteTagsTableReferences),
          NoteTagRow,
          PrefetchHooks Function({bool note})
        > {
  $$NoteTagsTableTableManager(_$AppDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> note = const Value.absent(),
            Value<String> tag = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => NoteTagsCompanion(note: note, tag: tag, rowid: rowid),
          createCompanionCallback: ({
            required int note,
            required String tag,
            Value<int> rowid = const Value.absent(),
          }) => NoteTagsCompanion.insert(note: note, tag: tag, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTagsTable, NoteTagRow>(table),
                  $$NoteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({note = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (note) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.note,
                        referencedTable: $$NoteTagsTableReferences._noteTable(
                          db,
                        ),
                        referencedColumn: $$NoteTagsTableReferences
                            ._noteTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTagsTable,
      NoteTagRow,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTagRow, $$NoteTagsTableReferences),
      NoteTagRow,
      PrefetchHooks Function({bool note})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
}
