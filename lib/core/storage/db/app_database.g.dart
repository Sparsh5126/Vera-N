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
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    nameKey,
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
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
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
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
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

  /// Lower-cased file name without `.md`: what `[[links]]` point at.
  final String nameKey;

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
    required this.nameKey,
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
    map['name_key'] = Variable<String>(nameKey);
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
      nameKey: Value(nameKey),
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
      nameKey: serializer.fromJson<String>(json['nameKey']),
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
      'nameKey': serializer.toJson<String>(nameKey),
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
    String? nameKey,
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
    nameKey: nameKey ?? this.nameKey,
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
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
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
          ..write('nameKey: $nameKey, ')
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
    nameKey,
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
          other.nameKey == this.nameKey &&
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
  final Value<String> nameKey;
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
    this.nameKey = const Value.absent(),
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
    this.nameKey = const Value.absent(),
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
    Expression<String>? nameKey,
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
      if (nameKey != null) 'name_key': nameKey,
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
    Value<String>? nameKey,
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
      nameKey: nameKey ?? this.nameKey,
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
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
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
          ..write('nameKey: $nameKey, ')
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

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinksTable extends Links with TableInfo<$LinksTable, LinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetKeyMeta = const VerificationMeta(
    'targetKey',
  );
  @override
  late final GeneratedColumn<String> targetKey = GeneratedColumn<String>(
    'target_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [source, targetKey, position, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'links';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('target_key')) {
      context.handle(
        _targetKeyMeta,
        targetKey.isAcceptableOrUnknown(data['target_key']!, _targetKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_targetKeyMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, targetKey};
  @override
  LinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinkRow(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source'],
      )!,
      targetKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_key'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $LinksTable createAlias(String alias) {
    return $LinksTable(attachedDatabase, alias);
  }
}

class LinkRow extends DataClass implements Insertable<LinkRow> {
  final int source;

  /// See `ParsedLink.targetKey`: a file name or a path, lower case.
  final String targetKey;

  /// Order in the note, so Linked chips follow the text.
  final int position;
  final String? label;
  const LinkRow({
    required this.source,
    required this.targetKey,
    required this.position,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<int>(source);
    map['target_key'] = Variable<String>(targetKey);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  LinksCompanion toCompanion(bool nullToAbsent) {
    return LinksCompanion(
      source: Value(source),
      targetKey: Value(targetKey),
      position: Value(position),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory LinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinkRow(
      source: serializer.fromJson<int>(json['source']),
      targetKey: serializer.fromJson<String>(json['targetKey']),
      position: serializer.fromJson<int>(json['position']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<int>(source),
      'targetKey': serializer.toJson<String>(targetKey),
      'position': serializer.toJson<int>(position),
      'label': serializer.toJson<String?>(label),
    };
  }

  LinkRow copyWith({
    int? source,
    String? targetKey,
    int? position,
    Value<String?> label = const Value.absent(),
  }) => LinkRow(
    source: source ?? this.source,
    targetKey: targetKey ?? this.targetKey,
    position: position ?? this.position,
    label: label.present ? label.value : this.label,
  );
  LinkRow copyWithCompanion(LinksCompanion data) {
    return LinkRow(
      source: data.source.present ? data.source.value : this.source,
      targetKey: data.targetKey.present ? data.targetKey.value : this.targetKey,
      position: data.position.present ? data.position.value : this.position,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinkRow(')
          ..write('source: $source, ')
          ..write('targetKey: $targetKey, ')
          ..write('position: $position, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, targetKey, position, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinkRow &&
          other.source == this.source &&
          other.targetKey == this.targetKey &&
          other.position == this.position &&
          other.label == this.label);
}

class LinksCompanion extends UpdateCompanion<LinkRow> {
  final Value<int> source;
  final Value<String> targetKey;
  final Value<int> position;
  final Value<String?> label;
  final Value<int> rowid;
  const LinksCompanion({
    this.source = const Value.absent(),
    this.targetKey = const Value.absent(),
    this.position = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinksCompanion.insert({
    required int source,
    required String targetKey,
    required int position,
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       targetKey = Value(targetKey),
       position = Value(position);
  static Insertable<LinkRow> custom({
    Expression<int>? source,
    Expression<String>? targetKey,
    Expression<int>? position,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (targetKey != null) 'target_key': targetKey,
      if (position != null) 'position': position,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinksCompanion copyWith({
    Value<int>? source,
    Value<String>? targetKey,
    Value<int>? position,
    Value<String?>? label,
    Value<int>? rowid,
  }) {
    return LinksCompanion(
      source: source ?? this.source,
      targetKey: targetKey ?? this.targetKey,
      position: position ?? this.position,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (targetKey.present) {
      map['target_key'] = Variable<String>(targetKey.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinksCompanion(')
          ..write('source: $source, ')
          ..write('targetKey: $targetKey, ')
          ..write('position: $position, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteAnalysisTable extends NoteAnalysis
    with TableInfo<$NoteAnalysisTable, NoteAnalysisRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteAnalysisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<int> note = GeneratedColumn<int>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAt = GeneratedColumn<DateTime>(
    'analyzed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [note, contentHash, model, analyzedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_analysis';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteAnalysisRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {note};
  @override
  NoteAnalysisRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteAnalysisRow(
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at'],
      )!,
    );
  }

  @override
  $NoteAnalysisTable createAlias(String alias) {
    return $NoteAnalysisTable(attachedDatabase, alias);
  }
}

class NoteAnalysisRow extends DataClass implements Insertable<NoteAnalysisRow> {
  final int note;
  final String contentHash;

  /// Embedding model name and version the chunks were made with.
  final String model;
  final DateTime analyzedAt;
  const NoteAnalysisRow({
    required this.note,
    required this.contentHash,
    required this.model,
    required this.analyzedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note'] = Variable<int>(note);
    map['content_hash'] = Variable<String>(contentHash);
    map['model'] = Variable<String>(model);
    map['analyzed_at'] = Variable<DateTime>(analyzedAt);
    return map;
  }

  NoteAnalysisCompanion toCompanion(bool nullToAbsent) {
    return NoteAnalysisCompanion(
      note: Value(note),
      contentHash: Value(contentHash),
      model: Value(model),
      analyzedAt: Value(analyzedAt),
    );
  }

  factory NoteAnalysisRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteAnalysisRow(
      note: serializer.fromJson<int>(json['note']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      model: serializer.fromJson<String>(json['model']),
      analyzedAt: serializer.fromJson<DateTime>(json['analyzedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'note': serializer.toJson<int>(note),
      'contentHash': serializer.toJson<String>(contentHash),
      'model': serializer.toJson<String>(model),
      'analyzedAt': serializer.toJson<DateTime>(analyzedAt),
    };
  }

  NoteAnalysisRow copyWith({
    int? note,
    String? contentHash,
    String? model,
    DateTime? analyzedAt,
  }) => NoteAnalysisRow(
    note: note ?? this.note,
    contentHash: contentHash ?? this.contentHash,
    model: model ?? this.model,
    analyzedAt: analyzedAt ?? this.analyzedAt,
  );
  NoteAnalysisRow copyWithCompanion(NoteAnalysisCompanion data) {
    return NoteAnalysisRow(
      note: data.note.present ? data.note.value : this.note,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      model: data.model.present ? data.model.value : this.model,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteAnalysisRow(')
          ..write('note: $note, ')
          ..write('contentHash: $contentHash, ')
          ..write('model: $model, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(note, contentHash, model, analyzedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteAnalysisRow &&
          other.note == this.note &&
          other.contentHash == this.contentHash &&
          other.model == this.model &&
          other.analyzedAt == this.analyzedAt);
}

class NoteAnalysisCompanion extends UpdateCompanion<NoteAnalysisRow> {
  final Value<int> note;
  final Value<String> contentHash;
  final Value<String> model;
  final Value<DateTime> analyzedAt;
  const NoteAnalysisCompanion({
    this.note = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.model = const Value.absent(),
    this.analyzedAt = const Value.absent(),
  });
  NoteAnalysisCompanion.insert({
    this.note = const Value.absent(),
    required String contentHash,
    required String model,
    required DateTime analyzedAt,
  }) : contentHash = Value(contentHash),
       model = Value(model),
       analyzedAt = Value(analyzedAt);
  static Insertable<NoteAnalysisRow> custom({
    Expression<int>? note,
    Expression<String>? contentHash,
    Expression<String>? model,
    Expression<DateTime>? analyzedAt,
  }) {
    return RawValuesInsertable({
      if (note != null) 'note': note,
      if (contentHash != null) 'content_hash': contentHash,
      if (model != null) 'model': model,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
    });
  }

  NoteAnalysisCompanion copyWith({
    Value<int>? note,
    Value<String>? contentHash,
    Value<String>? model,
    Value<DateTime>? analyzedAt,
  }) {
    return NoteAnalysisCompanion(
      note: note ?? this.note,
      contentHash: contentHash ?? this.contentHash,
      model: model ?? this.model,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (note.present) {
      map['note'] = Variable<int>(note.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<DateTime>(analyzedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteAnalysisCompanion(')
          ..write('note: $note, ')
          ..write('contentHash: $contentHash, ')
          ..write('model: $model, ')
          ..write('analyzedAt: $analyzedAt')
          ..write(')'))
        .toString();
  }
}

class $ChunksTable extends Chunks with TableInfo<$ChunksTable, ChunkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChunksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<int> start = GeneratedColumn<int>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<int> end = GeneratedColumn<int>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    note,
    idx,
    start,
    end,
    hash,
    model,
    vector,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChunkRow> instance, {
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
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {note, idx};
  @override
  ChunkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChunkRow(
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
    );
  }

  @override
  $ChunksTable createAlias(String alias) {
    return $ChunksTable(attachedDatabase, alias);
  }
}

class ChunkRow extends DataClass implements Insertable<ChunkRow> {
  final int note;
  final int idx;

  /// Where the chunk sits in the note's text, for "why related" later.
  final int start;
  final int end;

  /// Hash of the chunk's text: unchanged chunks keep their vector.
  final String hash;
  final String model;
  final Uint8List vector;
  const ChunkRow({
    required this.note,
    required this.idx,
    required this.start,
    required this.end,
    required this.hash,
    required this.model,
    required this.vector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note'] = Variable<int>(note);
    map['idx'] = Variable<int>(idx);
    map['start'] = Variable<int>(start);
    map['end'] = Variable<int>(end);
    map['hash'] = Variable<String>(hash);
    map['model'] = Variable<String>(model);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  ChunksCompanion toCompanion(bool nullToAbsent) {
    return ChunksCompanion(
      note: Value(note),
      idx: Value(idx),
      start: Value(start),
      end: Value(end),
      hash: Value(hash),
      model: Value(model),
      vector: Value(vector),
    );
  }

  factory ChunkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChunkRow(
      note: serializer.fromJson<int>(json['note']),
      idx: serializer.fromJson<int>(json['idx']),
      start: serializer.fromJson<int>(json['start']),
      end: serializer.fromJson<int>(json['end']),
      hash: serializer.fromJson<String>(json['hash']),
      model: serializer.fromJson<String>(json['model']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'note': serializer.toJson<int>(note),
      'idx': serializer.toJson<int>(idx),
      'start': serializer.toJson<int>(start),
      'end': serializer.toJson<int>(end),
      'hash': serializer.toJson<String>(hash),
      'model': serializer.toJson<String>(model),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  ChunkRow copyWith({
    int? note,
    int? idx,
    int? start,
    int? end,
    String? hash,
    String? model,
    Uint8List? vector,
  }) => ChunkRow(
    note: note ?? this.note,
    idx: idx ?? this.idx,
    start: start ?? this.start,
    end: end ?? this.end,
    hash: hash ?? this.hash,
    model: model ?? this.model,
    vector: vector ?? this.vector,
  );
  ChunkRow copyWithCompanion(ChunksCompanion data) {
    return ChunkRow(
      note: data.note.present ? data.note.value : this.note,
      idx: data.idx.present ? data.idx.value : this.idx,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      hash: data.hash.present ? data.hash.value : this.hash,
      model: data.model.present ? data.model.value : this.model,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChunkRow(')
          ..write('note: $note, ')
          ..write('idx: $idx, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('hash: $hash, ')
          ..write('model: $model, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    note,
    idx,
    start,
    end,
    hash,
    model,
    $driftBlobEquality.hash(vector),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChunkRow &&
          other.note == this.note &&
          other.idx == this.idx &&
          other.start == this.start &&
          other.end == this.end &&
          other.hash == this.hash &&
          other.model == this.model &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class ChunksCompanion extends UpdateCompanion<ChunkRow> {
  final Value<int> note;
  final Value<int> idx;
  final Value<int> start;
  final Value<int> end;
  final Value<String> hash;
  final Value<String> model;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const ChunksCompanion({
    this.note = const Value.absent(),
    this.idx = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.hash = const Value.absent(),
    this.model = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChunksCompanion.insert({
    required int note,
    required int idx,
    required int start,
    required int end,
    required String hash,
    required String model,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  }) : note = Value(note),
       idx = Value(idx),
       start = Value(start),
       end = Value(end),
       hash = Value(hash),
       model = Value(model),
       vector = Value(vector);
  static Insertable<ChunkRow> custom({
    Expression<int>? note,
    Expression<int>? idx,
    Expression<int>? start,
    Expression<int>? end,
    Expression<String>? hash,
    Expression<String>? model,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (note != null) 'note': note,
      if (idx != null) 'idx': idx,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (hash != null) 'hash': hash,
      if (model != null) 'model': model,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChunksCompanion copyWith({
    Value<int>? note,
    Value<int>? idx,
    Value<int>? start,
    Value<int>? end,
    Value<String>? hash,
    Value<String>? model,
    Value<Uint8List>? vector,
    Value<int>? rowid,
  }) {
    return ChunksCompanion(
      note: note ?? this.note,
      idx: idx ?? this.idx,
      start: start ?? this.start,
      end: end ?? this.end,
      hash: hash ?? this.hash,
      model: model ?? this.model,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (note.present) {
      map['note'] = Variable<int>(note.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (start.present) {
      map['start'] = Variable<int>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<int>(end.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChunksCompanion(')
          ..write('note: $note, ')
          ..write('idx: $idx, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('hash: $hash, ')
          ..write('model: $model, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuggestionsTable extends Suggestions
    with TableInfo<$SuggestionsTable, SuggestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuggestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteAMeta = const VerificationMeta('noteA');
  @override
  late final GeneratedColumn<int> noteA = GeneratedColumn<int>(
    'note_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteBMeta = const VerificationMeta('noteB');
  @override
  late final GeneratedColumn<int> noteB = GeneratedColumn<int>(
    'note_b',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fromLaptopMeta = const VerificationMeta(
    'fromLaptop',
  );
  @override
  late final GeneratedColumn<bool> fromLaptop = GeneratedColumn<bool>(
    'from_laptop',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("from_laptop" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkAMeta = const VerificationMeta('chunkA');
  @override
  late final GeneratedColumn<int> chunkA = GeneratedColumn<int>(
    'chunk_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chunkBMeta = const VerificationMeta('chunkB');
  @override
  late final GeneratedColumn<int> chunkB = GeneratedColumn<int>(
    'chunk_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    noteA,
    noteB,
    tag,
    detail,
    fromLaptop,
    score,
    chunkA,
    chunkB,
    status,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuggestionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('note_a')) {
      context.handle(
        _noteAMeta,
        noteA.isAcceptableOrUnknown(data['note_a']!, _noteAMeta),
      );
    } else if (isInserting) {
      context.missing(_noteAMeta);
    }
    if (data.containsKey('note_b')) {
      context.handle(
        _noteBMeta,
        noteB.isAcceptableOrUnknown(data['note_b']!, _noteBMeta),
      );
    } else if (isInserting) {
      context.missing(_noteBMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('from_laptop')) {
      context.handle(
        _fromLaptopMeta,
        fromLaptop.isAcceptableOrUnknown(data['from_laptop']!, _fromLaptopMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('chunk_a')) {
      context.handle(
        _chunkAMeta,
        chunkA.isAcceptableOrUnknown(data['chunk_a']!, _chunkAMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkAMeta);
    }
    if (data.containsKey('chunk_b')) {
      context.handle(
        _chunkBMeta,
        chunkB.isAcceptableOrUnknown(data['chunk_b']!, _chunkBMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkBMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, noteA, noteB, tag},
  ];
  @override
  SuggestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuggestionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      noteA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_a'],
      )!,
      noteB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_b'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      )!,
      fromLaptop: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}from_laptop'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      chunkA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_a'],
      )!,
      chunkB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_b'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $SuggestionsTable createAlias(String alias) {
    return $SuggestionsTable(attachedDatabase, alias);
  }
}

class SuggestionRow extends DataClass implements Insertable<SuggestionRow> {
  final int id;

  /// `link`, `tag`, `resurface`, or `duplicate` (from the laptop, schema 7).
  final String kind;
  final int noteA;

  /// For a link, the other note. For a tag, the closest note that already
  /// has the tag: the reason it is suggested.
  final int noteB;

  /// The suggested tag (without `#`); empty for links (schema 6).
  final String tag;

  /// A sentence the laptop wrote: why a link fits, or what two copies
  /// share. Empty when there is none (schema 7).
  final String detail;

  /// Made by the laptop booster, not by this device's matching: it never
  /// moves this device's learned match bars (schema 7).
  final bool fromLaptop;
  final double score;

  /// The best-matching chunk of each note, for "why related".
  final int chunkA;
  final int chunkB;

  /// `fresh` (not yet reviewed) or `notSure` (comes back in a later batch).
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;
  const SuggestionRow({
    required this.id,
    required this.kind,
    required this.noteA,
    required this.noteB,
    required this.tag,
    required this.detail,
    required this.fromLaptop,
    required this.score,
    required this.chunkA,
    required this.chunkB,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['note_a'] = Variable<int>(noteA);
    map['note_b'] = Variable<int>(noteB);
    map['tag'] = Variable<String>(tag);
    map['detail'] = Variable<String>(detail);
    map['from_laptop'] = Variable<bool>(fromLaptop);
    map['score'] = Variable<double>(score);
    map['chunk_a'] = Variable<int>(chunkA);
    map['chunk_b'] = Variable<int>(chunkB);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  SuggestionsCompanion toCompanion(bool nullToAbsent) {
    return SuggestionsCompanion(
      id: Value(id),
      kind: Value(kind),
      noteA: Value(noteA),
      noteB: Value(noteB),
      tag: Value(tag),
      detail: Value(detail),
      fromLaptop: Value(fromLaptop),
      score: Value(score),
      chunkA: Value(chunkA),
      chunkB: Value(chunkB),
      status: Value(status),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory SuggestionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuggestionRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      noteA: serializer.fromJson<int>(json['noteA']),
      noteB: serializer.fromJson<int>(json['noteB']),
      tag: serializer.fromJson<String>(json['tag']),
      detail: serializer.fromJson<String>(json['detail']),
      fromLaptop: serializer.fromJson<bool>(json['fromLaptop']),
      score: serializer.fromJson<double>(json['score']),
      chunkA: serializer.fromJson<int>(json['chunkA']),
      chunkB: serializer.fromJson<int>(json['chunkB']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'noteA': serializer.toJson<int>(noteA),
      'noteB': serializer.toJson<int>(noteB),
      'tag': serializer.toJson<String>(tag),
      'detail': serializer.toJson<String>(detail),
      'fromLaptop': serializer.toJson<bool>(fromLaptop),
      'score': serializer.toJson<double>(score),
      'chunkA': serializer.toJson<int>(chunkA),
      'chunkB': serializer.toJson<int>(chunkB),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  SuggestionRow copyWith({
    int? id,
    String? kind,
    int? noteA,
    int? noteB,
    String? tag,
    String? detail,
    bool? fromLaptop,
    double? score,
    int? chunkA,
    int? chunkB,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => SuggestionRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    noteA: noteA ?? this.noteA,
    noteB: noteB ?? this.noteB,
    tag: tag ?? this.tag,
    detail: detail ?? this.detail,
    fromLaptop: fromLaptop ?? this.fromLaptop,
    score: score ?? this.score,
    chunkA: chunkA ?? this.chunkA,
    chunkB: chunkB ?? this.chunkB,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  SuggestionRow copyWithCompanion(SuggestionsCompanion data) {
    return SuggestionRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      noteA: data.noteA.present ? data.noteA.value : this.noteA,
      noteB: data.noteB.present ? data.noteB.value : this.noteB,
      tag: data.tag.present ? data.tag.value : this.tag,
      detail: data.detail.present ? data.detail.value : this.detail,
      fromLaptop: data.fromLaptop.present
          ? data.fromLaptop.value
          : this.fromLaptop,
      score: data.score.present ? data.score.value : this.score,
      chunkA: data.chunkA.present ? data.chunkA.value : this.chunkA,
      chunkB: data.chunkB.present ? data.chunkB.value : this.chunkB,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuggestionRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('noteA: $noteA, ')
          ..write('noteB: $noteB, ')
          ..write('tag: $tag, ')
          ..write('detail: $detail, ')
          ..write('fromLaptop: $fromLaptop, ')
          ..write('score: $score, ')
          ..write('chunkA: $chunkA, ')
          ..write('chunkB: $chunkB, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    noteA,
    noteB,
    tag,
    detail,
    fromLaptop,
    score,
    chunkA,
    chunkB,
    status,
    createdAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuggestionRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.noteA == this.noteA &&
          other.noteB == this.noteB &&
          other.tag == this.tag &&
          other.detail == this.detail &&
          other.fromLaptop == this.fromLaptop &&
          other.score == this.score &&
          other.chunkA == this.chunkA &&
          other.chunkB == this.chunkB &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class SuggestionsCompanion extends UpdateCompanion<SuggestionRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int> noteA;
  final Value<int> noteB;
  final Value<String> tag;
  final Value<String> detail;
  final Value<bool> fromLaptop;
  final Value<double> score;
  final Value<int> chunkA;
  final Value<int> chunkB;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  const SuggestionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.noteA = const Value.absent(),
    this.noteB = const Value.absent(),
    this.tag = const Value.absent(),
    this.detail = const Value.absent(),
    this.fromLaptop = const Value.absent(),
    this.score = const Value.absent(),
    this.chunkA = const Value.absent(),
    this.chunkB = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  SuggestionsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required int noteA,
    required int noteB,
    this.tag = const Value.absent(),
    this.detail = const Value.absent(),
    this.fromLaptop = const Value.absent(),
    required double score,
    required int chunkA,
    required int chunkB,
    required String status,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : kind = Value(kind),
       noteA = Value(noteA),
       noteB = Value(noteB),
       score = Value(score),
       chunkA = Value(chunkA),
       chunkB = Value(chunkB),
       status = Value(status),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<SuggestionRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? noteA,
    Expression<int>? noteB,
    Expression<String>? tag,
    Expression<String>? detail,
    Expression<bool>? fromLaptop,
    Expression<double>? score,
    Expression<int>? chunkA,
    Expression<int>? chunkB,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (noteA != null) 'note_a': noteA,
      if (noteB != null) 'note_b': noteB,
      if (tag != null) 'tag': tag,
      if (detail != null) 'detail': detail,
      if (fromLaptop != null) 'from_laptop': fromLaptop,
      if (score != null) 'score': score,
      if (chunkA != null) 'chunk_a': chunkA,
      if (chunkB != null) 'chunk_b': chunkB,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  SuggestionsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int>? noteA,
    Value<int>? noteB,
    Value<String>? tag,
    Value<String>? detail,
    Value<bool>? fromLaptop,
    Value<double>? score,
    Value<int>? chunkA,
    Value<int>? chunkB,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
  }) {
    return SuggestionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      noteA: noteA ?? this.noteA,
      noteB: noteB ?? this.noteB,
      tag: tag ?? this.tag,
      detail: detail ?? this.detail,
      fromLaptop: fromLaptop ?? this.fromLaptop,
      score: score ?? this.score,
      chunkA: chunkA ?? this.chunkA,
      chunkB: chunkB ?? this.chunkB,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (noteA.present) {
      map['note_a'] = Variable<int>(noteA.value);
    }
    if (noteB.present) {
      map['note_b'] = Variable<int>(noteB.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (fromLaptop.present) {
      map['from_laptop'] = Variable<bool>(fromLaptop.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (chunkA.present) {
      map['chunk_a'] = Variable<int>(chunkA.value);
    }
    if (chunkB.present) {
      map['chunk_b'] = Variable<int>(chunkB.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('noteA: $noteA, ')
          ..write('noteB: $noteB, ')
          ..write('tag: $tag, ')
          ..write('detail: $detail, ')
          ..write('fromLaptop: $fromLaptop, ')
          ..write('score: $score, ')
          ..write('chunkA: $chunkA, ')
          ..write('chunkB: $chunkB, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

class $RejectionsTable extends Rejections
    with TableInfo<$RejectionsTable, RejectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RejectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pairKeyMeta = const VerificationMeta(
    'pairKey',
  );
  @override
  late final GeneratedColumn<String> pairKey = GeneratedColumn<String>(
    'pair_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteAMeta = const VerificationMeta('noteA');
  @override
  late final GeneratedColumn<String> noteA = GeneratedColumn<String>(
    'note_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashAMeta = const VerificationMeta('hashA');
  @override
  late final GeneratedColumn<String> hashA = GeneratedColumn<String>(
    'hash_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteBMeta = const VerificationMeta('noteB');
  @override
  late final GeneratedColumn<String> noteB = GeneratedColumn<String>(
    'note_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hashBMeta = const VerificationMeta('hashB');
  @override
  late final GeneratedColumn<String> hashB = GeneratedColumn<String>(
    'hash_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureAMeta = const VerificationMeta(
    'signatureA',
  );
  @override
  late final GeneratedColumn<Uint8List> signatureA = GeneratedColumn<Uint8List>(
    'signature_a',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureBMeta = const VerificationMeta(
    'signatureB',
  );
  @override
  late final GeneratedColumn<Uint8List> signatureB = GeneratedColumn<Uint8List>(
    'signature_b',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedAtMeta = const VerificationMeta(
    'rejectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> rejectedAt = GeneratedColumn<DateTime>(
    'rejected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pairKey,
    noteA,
    hashA,
    noteB,
    hashB,
    signatureA,
    signatureB,
    rejectedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rejections';
  @override
  VerificationContext validateIntegrity(
    Insertable<RejectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pair_key')) {
      context.handle(
        _pairKeyMeta,
        pairKey.isAcceptableOrUnknown(data['pair_key']!, _pairKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pairKeyMeta);
    }
    if (data.containsKey('note_a')) {
      context.handle(
        _noteAMeta,
        noteA.isAcceptableOrUnknown(data['note_a']!, _noteAMeta),
      );
    } else if (isInserting) {
      context.missing(_noteAMeta);
    }
    if (data.containsKey('hash_a')) {
      context.handle(
        _hashAMeta,
        hashA.isAcceptableOrUnknown(data['hash_a']!, _hashAMeta),
      );
    } else if (isInserting) {
      context.missing(_hashAMeta);
    }
    if (data.containsKey('note_b')) {
      context.handle(
        _noteBMeta,
        noteB.isAcceptableOrUnknown(data['note_b']!, _noteBMeta),
      );
    } else if (isInserting) {
      context.missing(_noteBMeta);
    }
    if (data.containsKey('hash_b')) {
      context.handle(
        _hashBMeta,
        hashB.isAcceptableOrUnknown(data['hash_b']!, _hashBMeta),
      );
    } else if (isInserting) {
      context.missing(_hashBMeta);
    }
    if (data.containsKey('signature_a')) {
      context.handle(
        _signatureAMeta,
        signatureA.isAcceptableOrUnknown(data['signature_a']!, _signatureAMeta),
      );
    }
    if (data.containsKey('signature_b')) {
      context.handle(
        _signatureBMeta,
        signatureB.isAcceptableOrUnknown(data['signature_b']!, _signatureBMeta),
      );
    }
    if (data.containsKey('rejected_at')) {
      context.handle(
        _rejectedAtMeta,
        rejectedAt.isAcceptableOrUnknown(data['rejected_at']!, _rejectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_rejectedAtMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pairKey};
  @override
  RejectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RejectionRow(
      pairKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pair_key'],
      )!,
      noteA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_a'],
      )!,
      hashA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_a'],
      )!,
      noteB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_b'],
      )!,
      hashB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_b'],
      )!,
      signatureA: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature_a'],
      ),
      signatureB: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature_b'],
      ),
      rejectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rejected_at'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $RejectionsTable createAlias(String alias) {
    return $RejectionsTable(attachedDatabase, alias);
  }
}

class RejectionRow extends DataClass implements Insertable<RejectionRow> {
  /// `idA|idB`, the two note ids in sorted order.
  final String pairKey;
  final String noteA;
  final String hashA;
  final String noteB;
  final String hashB;

  /// Word fingerprints (see `WordSignature`) when rejected, kept only in
  /// this private database: a pair returns only after a big change.
  final Uint8List? signatureA;
  final Uint8List? signatureB;
  final DateTime rejectedAt;
  final String deviceId;
  const RejectionRow({
    required this.pairKey,
    required this.noteA,
    required this.hashA,
    required this.noteB,
    required this.hashB,
    this.signatureA,
    this.signatureB,
    required this.rejectedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pair_key'] = Variable<String>(pairKey);
    map['note_a'] = Variable<String>(noteA);
    map['hash_a'] = Variable<String>(hashA);
    map['note_b'] = Variable<String>(noteB);
    map['hash_b'] = Variable<String>(hashB);
    if (!nullToAbsent || signatureA != null) {
      map['signature_a'] = Variable<Uint8List>(signatureA);
    }
    if (!nullToAbsent || signatureB != null) {
      map['signature_b'] = Variable<Uint8List>(signatureB);
    }
    map['rejected_at'] = Variable<DateTime>(rejectedAt);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  RejectionsCompanion toCompanion(bool nullToAbsent) {
    return RejectionsCompanion(
      pairKey: Value(pairKey),
      noteA: Value(noteA),
      hashA: Value(hashA),
      noteB: Value(noteB),
      hashB: Value(hashB),
      signatureA: signatureA == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureA),
      signatureB: signatureB == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureB),
      rejectedAt: Value(rejectedAt),
      deviceId: Value(deviceId),
    );
  }

  factory RejectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RejectionRow(
      pairKey: serializer.fromJson<String>(json['pairKey']),
      noteA: serializer.fromJson<String>(json['noteA']),
      hashA: serializer.fromJson<String>(json['hashA']),
      noteB: serializer.fromJson<String>(json['noteB']),
      hashB: serializer.fromJson<String>(json['hashB']),
      signatureA: serializer.fromJson<Uint8List?>(json['signatureA']),
      signatureB: serializer.fromJson<Uint8List?>(json['signatureB']),
      rejectedAt: serializer.fromJson<DateTime>(json['rejectedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pairKey': serializer.toJson<String>(pairKey),
      'noteA': serializer.toJson<String>(noteA),
      'hashA': serializer.toJson<String>(hashA),
      'noteB': serializer.toJson<String>(noteB),
      'hashB': serializer.toJson<String>(hashB),
      'signatureA': serializer.toJson<Uint8List?>(signatureA),
      'signatureB': serializer.toJson<Uint8List?>(signatureB),
      'rejectedAt': serializer.toJson<DateTime>(rejectedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  RejectionRow copyWith({
    String? pairKey,
    String? noteA,
    String? hashA,
    String? noteB,
    String? hashB,
    Value<Uint8List?> signatureA = const Value.absent(),
    Value<Uint8List?> signatureB = const Value.absent(),
    DateTime? rejectedAt,
    String? deviceId,
  }) => RejectionRow(
    pairKey: pairKey ?? this.pairKey,
    noteA: noteA ?? this.noteA,
    hashA: hashA ?? this.hashA,
    noteB: noteB ?? this.noteB,
    hashB: hashB ?? this.hashB,
    signatureA: signatureA.present ? signatureA.value : this.signatureA,
    signatureB: signatureB.present ? signatureB.value : this.signatureB,
    rejectedAt: rejectedAt ?? this.rejectedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  RejectionRow copyWithCompanion(RejectionsCompanion data) {
    return RejectionRow(
      pairKey: data.pairKey.present ? data.pairKey.value : this.pairKey,
      noteA: data.noteA.present ? data.noteA.value : this.noteA,
      hashA: data.hashA.present ? data.hashA.value : this.hashA,
      noteB: data.noteB.present ? data.noteB.value : this.noteB,
      hashB: data.hashB.present ? data.hashB.value : this.hashB,
      signatureA: data.signatureA.present
          ? data.signatureA.value
          : this.signatureA,
      signatureB: data.signatureB.present
          ? data.signatureB.value
          : this.signatureB,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RejectionRow(')
          ..write('pairKey: $pairKey, ')
          ..write('noteA: $noteA, ')
          ..write('hashA: $hashA, ')
          ..write('noteB: $noteB, ')
          ..write('hashB: $hashB, ')
          ..write('signatureA: $signatureA, ')
          ..write('signatureB: $signatureB, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pairKey,
    noteA,
    hashA,
    noteB,
    hashB,
    $driftBlobEquality.hash(signatureA),
    $driftBlobEquality.hash(signatureB),
    rejectedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RejectionRow &&
          other.pairKey == this.pairKey &&
          other.noteA == this.noteA &&
          other.hashA == this.hashA &&
          other.noteB == this.noteB &&
          other.hashB == this.hashB &&
          $driftBlobEquality.equals(other.signatureA, this.signatureA) &&
          $driftBlobEquality.equals(other.signatureB, this.signatureB) &&
          other.rejectedAt == this.rejectedAt &&
          other.deviceId == this.deviceId);
}

class RejectionsCompanion extends UpdateCompanion<RejectionRow> {
  final Value<String> pairKey;
  final Value<String> noteA;
  final Value<String> hashA;
  final Value<String> noteB;
  final Value<String> hashB;
  final Value<Uint8List?> signatureA;
  final Value<Uint8List?> signatureB;
  final Value<DateTime> rejectedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const RejectionsCompanion({
    this.pairKey = const Value.absent(),
    this.noteA = const Value.absent(),
    this.hashA = const Value.absent(),
    this.noteB = const Value.absent(),
    this.hashB = const Value.absent(),
    this.signatureA = const Value.absent(),
    this.signatureB = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RejectionsCompanion.insert({
    required String pairKey,
    required String noteA,
    required String hashA,
    required String noteB,
    required String hashB,
    this.signatureA = const Value.absent(),
    this.signatureB = const Value.absent(),
    required DateTime rejectedAt,
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : pairKey = Value(pairKey),
       noteA = Value(noteA),
       hashA = Value(hashA),
       noteB = Value(noteB),
       hashB = Value(hashB),
       rejectedAt = Value(rejectedAt),
       deviceId = Value(deviceId);
  static Insertable<RejectionRow> custom({
    Expression<String>? pairKey,
    Expression<String>? noteA,
    Expression<String>? hashA,
    Expression<String>? noteB,
    Expression<String>? hashB,
    Expression<Uint8List>? signatureA,
    Expression<Uint8List>? signatureB,
    Expression<DateTime>? rejectedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pairKey != null) 'pair_key': pairKey,
      if (noteA != null) 'note_a': noteA,
      if (hashA != null) 'hash_a': hashA,
      if (noteB != null) 'note_b': noteB,
      if (hashB != null) 'hash_b': hashB,
      if (signatureA != null) 'signature_a': signatureA,
      if (signatureB != null) 'signature_b': signatureB,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RejectionsCompanion copyWith({
    Value<String>? pairKey,
    Value<String>? noteA,
    Value<String>? hashA,
    Value<String>? noteB,
    Value<String>? hashB,
    Value<Uint8List?>? signatureA,
    Value<Uint8List?>? signatureB,
    Value<DateTime>? rejectedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return RejectionsCompanion(
      pairKey: pairKey ?? this.pairKey,
      noteA: noteA ?? this.noteA,
      hashA: hashA ?? this.hashA,
      noteB: noteB ?? this.noteB,
      hashB: hashB ?? this.hashB,
      signatureA: signatureA ?? this.signatureA,
      signatureB: signatureB ?? this.signatureB,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pairKey.present) {
      map['pair_key'] = Variable<String>(pairKey.value);
    }
    if (noteA.present) {
      map['note_a'] = Variable<String>(noteA.value);
    }
    if (hashA.present) {
      map['hash_a'] = Variable<String>(hashA.value);
    }
    if (noteB.present) {
      map['note_b'] = Variable<String>(noteB.value);
    }
    if (hashB.present) {
      map['hash_b'] = Variable<String>(hashB.value);
    }
    if (signatureA.present) {
      map['signature_a'] = Variable<Uint8List>(signatureA.value);
    }
    if (signatureB.present) {
      map['signature_b'] = Variable<Uint8List>(signatureB.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<DateTime>(rejectedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RejectionsCompanion(')
          ..write('pairKey: $pairKey, ')
          ..write('noteA: $noteA, ')
          ..write('hashA: $hashA, ')
          ..write('noteB: $noteB, ')
          ..write('hashB: $hashB, ')
          ..write('signatureA: $signatureA, ')
          ..write('signatureB: $signatureB, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportedResultsTable extends ImportedResults
    with TableInfo<$ImportedResultsTable, ImportedResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportedResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jobKeyMeta = const VerificationMeta('jobKey');
  @override
  late final GeneratedColumn<String> jobKey = GeneratedColumn<String>(
    'job_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [jobKey, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imported_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportedResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('job_key')) {
      context.handle(
        _jobKeyMeta,
        jobKey.isAcceptableOrUnknown(data['job_key']!, _jobKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_jobKeyMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jobKey};
  @override
  ImportedResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportedResult(
      jobKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_key'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ImportedResultsTable createAlias(String alias) {
    return $ImportedResultsTable(attachedDatabase, alias);
  }
}

class ImportedResult extends DataClass implements Insertable<ImportedResult> {
  final String jobKey;
  final DateTime importedAt;
  const ImportedResult({required this.jobKey, required this.importedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_key'] = Variable<String>(jobKey);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ImportedResultsCompanion toCompanion(bool nullToAbsent) {
    return ImportedResultsCompanion(
      jobKey: Value(jobKey),
      importedAt: Value(importedAt),
    );
  }

  factory ImportedResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportedResult(
      jobKey: serializer.fromJson<String>(json['jobKey']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jobKey': serializer.toJson<String>(jobKey),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ImportedResult copyWith({String? jobKey, DateTime? importedAt}) =>
      ImportedResult(
        jobKey: jobKey ?? this.jobKey,
        importedAt: importedAt ?? this.importedAt,
      );
  ImportedResult copyWithCompanion(ImportedResultsCompanion data) {
    return ImportedResult(
      jobKey: data.jobKey.present ? data.jobKey.value : this.jobKey,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportedResult(')
          ..write('jobKey: $jobKey, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(jobKey, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportedResult &&
          other.jobKey == this.jobKey &&
          other.importedAt == this.importedAt);
}

class ImportedResultsCompanion extends UpdateCompanion<ImportedResult> {
  final Value<String> jobKey;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const ImportedResultsCompanion({
    this.jobKey = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportedResultsCompanion.insert({
    required String jobKey,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : jobKey = Value(jobKey),
       importedAt = Value(importedAt);
  static Insertable<ImportedResult> custom({
    Expression<String>? jobKey,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jobKey != null) 'job_key': jobKey,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportedResultsCompanion copyWith({
    Value<String>? jobKey,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return ImportedResultsCompanion(
      jobKey: jobKey ?? this.jobKey,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobKey.present) {
      map['job_key'] = Variable<String>(jobKey.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportedResultsCompanion(')
          ..write('jobKey: $jobKey, ')
          ..write('importedAt: $importedAt, ')
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
  late final $SettingsTable settings = $SettingsTable(this);
  late final $LinksTable links = $LinksTable(this);
  late final $NoteAnalysisTable noteAnalysis = $NoteAnalysisTable(this);
  late final $ChunksTable chunks = $ChunksTable(this);
  late final $SuggestionsTable suggestions = $SuggestionsTable(this);
  late final $RejectionsTable rejections = $RejectionsTable(this);
  late final $ImportedResultsTable importedResults = $ImportedResultsTable(
    this,
  );
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
  late final Index notesNameKey = Index(
    'notes_name_key',
    'CREATE INDEX notes_name_key ON notes (name_key)',
  );
  late final Index noteTagsTag = Index(
    'note_tags_tag',
    'CREATE INDEX note_tags_tag ON note_tags (tag)',
  );
  late final Index linksTarget = Index(
    'links_target',
    'CREATE INDEX links_target ON links (target_key)',
  );
  late final Index linksSource = Index(
    'links_source',
    'CREATE INDEX links_source ON links (source)',
  );
  late final Index suggestionsNoteA = Index(
    'suggestions_note_a',
    'CREATE INDEX suggestions_note_a ON suggestions (note_a)',
  );
  late final Index suggestionsNoteB = Index(
    'suggestions_note_b',
    'CREATE INDEX suggestions_note_b ON suggestions (note_b)',
  );
  late final Index suggestionsExpires = Index(
    'suggestions_expires',
    'CREATE INDEX suggestions_expires ON suggestions (expires_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notes,
    noteTags,
    settings,
    links,
    noteAnalysis,
    chunks,
    suggestions,
    rejections,
    importedResults,
    notesModified,
    notesNoteId,
    notesFolder,
    notesNameKey,
    noteTagsTag,
    linksTarget,
    linksSource,
    suggestionsNoteA,
    suggestionsNoteB,
    suggestionsExpires,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_analysis', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chunks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('suggestions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String?> noteId,
  required String path,
  required String pathKey,
  Value<String> nameKey,
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
  Value<String> nameKey,
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

  static MultiTypedResultKey<$LinksTable, List<LinkRow>> _linksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.links,
    aliasName: 'notes__id__links__source',
  );

  $$LinksTableProcessedTableManager get linksRefs {
    final manager = $$LinksTableTableManager(
      $_db,
      $_db.links,
    ).filter((f) => f.source.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_linksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteAnalysisTable, List<NoteAnalysisRow>>
  _noteAnalysisRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteAnalysis,
    aliasName: 'notes__id__note_analysis__note',
  );

  $$NoteAnalysisTableProcessedTableManager get noteAnalysisRefs {
    final manager = $$NoteAnalysisTableTableManager(
      $_db,
      $_db.noteAnalysis,
    ).filter((f) => f.note.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteAnalysisRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChunksTable, List<ChunkRow>> _chunksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chunks,
    aliasName: 'notes__id__chunks__note',
  );

  $$ChunksTableProcessedTableManager get chunksRefs {
    final manager = $$ChunksTableTableManager(
      $_db,
      $_db.chunks,
    ).filter((f) => f.note.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chunksRefsTable($_db));
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

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
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

  Expression<bool> linksRefs(
    Expression<bool> Function($$LinksTableFilterComposer f) f,
  ) {
    final $$LinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.links,
      getReferencedColumn: (t) => t.source,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinksTableFilterComposer(
            $db: $db,
            $table: $db.links,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteAnalysisRefs(
    Expression<bool> Function($$NoteAnalysisTableFilterComposer f) f,
  ) {
    final $$NoteAnalysisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteAnalysis,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteAnalysisTableFilterComposer(
            $db: $db,
            $table: $db.noteAnalysis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chunksRefs(
    Expression<bool> Function($$ChunksTableFilterComposer f) f,
  ) {
    final $$ChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableFilterComposer(
            $db: $db,
            $table: $db.chunks,
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

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
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

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

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

  Expression<T> linksRefs<T extends Object>(
    Expression<T> Function($$LinksTableAnnotationComposer a) f,
  ) {
    final $$LinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.links,
      getReferencedColumn: (t) => t.source,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinksTableAnnotationComposer(
            $db: $db,
            $table: $db.links,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteAnalysisRefs<T extends Object>(
    Expression<T> Function($$NoteAnalysisTableAnnotationComposer a) f,
  ) {
    final $$NoteAnalysisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteAnalysis,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteAnalysisTableAnnotationComposer(
            $db: $db,
            $table: $db.noteAnalysis,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chunksRefs<T extends Object>(
    Expression<T> Function($$ChunksTableAnnotationComposer a) f,
  ) {
    final $$ChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunks,
      getReferencedColumn: (t) => t.note,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.chunks,
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
          PrefetchHooks Function({
            bool noteTagsRefs,
            bool linksRefs,
            bool noteAnalysisRefs,
            bool chunksRefs,
          })
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
                Value<String> nameKey = const Value.absent(),
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
                nameKey: nameKey,
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
                Value<String> nameKey = const Value.absent(),
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
                nameKey: nameKey,
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
          prefetchHooksCallback:
              ({
                noteTagsRefs = false,
                linksRefs = false,
                noteAnalysisRefs = false,
                chunksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteTagsRefs) db.noteTags,
                    if (linksRefs) db.links,
                    if (noteAnalysisRefs) db.noteAnalysis,
                    if (chunksRefs) db.chunks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteTagsRefs)
                        await $_getPrefetchedData<
                          NoteRow,
                          $NotesTable,
                          NoteTagRow
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTagsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.note == item.id),
                          typedResults: items,
                        ),
                      if (linksRefs)
                        await $_getPrefetchedData<
                          NoteRow,
                          $NotesTable,
                          LinkRow
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._linksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(db, table, p0).linksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.source == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (noteAnalysisRefs)
                        await $_getPrefetchedData<
                          NoteRow,
                          $NotesTable,
                          NoteAnalysisRow
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteAnalysisRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteAnalysisRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.note == item.id),
                          typedResults: items,
                        ),
                      if (chunksRefs)
                        await $_getPrefetchedData<
                          NoteRow,
                          $NotesTable,
                          ChunkRow
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._chunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(db, table, p0).chunksRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.note == item.id),
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
      PrefetchHooks Function({
        bool noteTagsRefs,
        bool linksRefs,
        bool noteAnalysisRefs,
        bool chunksRefs,
      })
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
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$LinksTableCreateCompanionBuilder = LinksCompanion Function({
  required int source,
  required String targetKey,
  required int position,
  Value<String?> label,
  Value<int> rowid,
});
typedef $$LinksTableUpdateCompanionBuilder = LinksCompanion Function({
  Value<int> source,
  Value<String> targetKey,
  Value<int> position,
  Value<String?> label,
  Value<int> rowid,
});

final class $$LinksTableReferences
    extends BaseReferences<_$AppDatabase, $LinksTable, LinkRow> {
  $$LinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _sourceTable(_$AppDatabase db) =>
      db.notes.createAlias('links__source__notes__id');

  $$NotesTableProcessedTableManager get source {
    final $_column = $_itemColumn<int>('source')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LinksTableFilterComposer extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get source {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.source,
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

class $$LinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetKey => $composableBuilder(
    column: $table.targetKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get source {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.source,
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

class $$LinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinksTable> {
  $$LinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetKey =>
      $composableBuilder(column: $table.targetKey, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  $$NotesTableAnnotationComposer get source {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.source,
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

class $$LinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinksTable,
          LinkRow,
          $$LinksTableFilterComposer,
          $$LinksTableOrderingComposer,
          $$LinksTableAnnotationComposer,
          $$LinksTableCreateCompanionBuilder,
          $$LinksTableUpdateCompanionBuilder,
          (LinkRow, $$LinksTableReferences),
          LinkRow,
          PrefetchHooks Function({bool source})
        > {
  $$LinksTableTableManager(_$AppDatabase db, $LinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> source = const Value.absent(),
                Value<String> targetKey = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinksCompanion(
                source: source,
                targetKey: targetKey,
                position: position,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int source,
                required String targetKey,
                required int position,
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinksCompanion.insert(
                source: source,
                targetKey: targetKey,
                position: position,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LinksTable, LinkRow>(table),
                  $$LinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({source = false}) {
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
                    if (source) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.source,
                        referencedTable: $$LinksTableReferences._sourceTable(
                          db,
                        ),
                        referencedColumn: $$LinksTableReferences
                            ._sourceTable(db)
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

typedef $$LinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinksTable,
      LinkRow,
      $$LinksTableFilterComposer,
      $$LinksTableOrderingComposer,
      $$LinksTableAnnotationComposer,
      $$LinksTableCreateCompanionBuilder,
      $$LinksTableUpdateCompanionBuilder,
      (LinkRow, $$LinksTableReferences),
      LinkRow,
      PrefetchHooks Function({bool source})
    >;
typedef $$NoteAnalysisTableCreateCompanionBuilder =
    NoteAnalysisCompanion Function({
      Value<int> note,
      required String contentHash,
      required String model,
      required DateTime analyzedAt,
    });
typedef $$NoteAnalysisTableUpdateCompanionBuilder =
    NoteAnalysisCompanion Function({
      Value<int> note,
      Value<String> contentHash,
      Value<String> model,
      Value<DateTime> analyzedAt,
    });

final class $$NoteAnalysisTableReferences
    extends BaseReferences<_$AppDatabase, $NoteAnalysisTable, NoteAnalysisRow> {
  $$NoteAnalysisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteTable(_$AppDatabase db) =>
      db.notes.createAlias('note_analysis__note__notes__id');

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

class $$NoteAnalysisTableFilterComposer
    extends Composer<_$AppDatabase, $NoteAnalysisTable> {
  $$NoteAnalysisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
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

class $$NoteAnalysisTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteAnalysisTable> {
  $$NoteAnalysisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
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

class $$NoteAnalysisTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteAnalysisTable> {
  $$NoteAnalysisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<DateTime> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

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

class $$NoteAnalysisTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteAnalysisTable,
          NoteAnalysisRow,
          $$NoteAnalysisTableFilterComposer,
          $$NoteAnalysisTableOrderingComposer,
          $$NoteAnalysisTableAnnotationComposer,
          $$NoteAnalysisTableCreateCompanionBuilder,
          $$NoteAnalysisTableUpdateCompanionBuilder,
          (NoteAnalysisRow, $$NoteAnalysisTableReferences),
          NoteAnalysisRow,
          PrefetchHooks Function({bool note})
        > {
  $$NoteAnalysisTableTableManager(_$AppDatabase db, $NoteAnalysisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteAnalysisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteAnalysisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteAnalysisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> note = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<DateTime> analyzedAt = const Value.absent(),
              }) => NoteAnalysisCompanion(
                note: note,
                contentHash: contentHash,
                model: model,
                analyzedAt: analyzedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> note = const Value.absent(),
                required String contentHash,
                required String model,
                required DateTime analyzedAt,
              }) => NoteAnalysisCompanion.insert(
                note: note,
                contentHash: contentHash,
                model: model,
                analyzedAt: analyzedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteAnalysisTable, NoteAnalysisRow>(table),
                  $$NoteAnalysisTableReferences(db, table, e),
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
                        referencedTable: $$NoteAnalysisTableReferences
                            ._noteTable(db),
                        referencedColumn: $$NoteAnalysisTableReferences
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

typedef $$NoteAnalysisTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteAnalysisTable,
      NoteAnalysisRow,
      $$NoteAnalysisTableFilterComposer,
      $$NoteAnalysisTableOrderingComposer,
      $$NoteAnalysisTableAnnotationComposer,
      $$NoteAnalysisTableCreateCompanionBuilder,
      $$NoteAnalysisTableUpdateCompanionBuilder,
      (NoteAnalysisRow, $$NoteAnalysisTableReferences),
      NoteAnalysisRow,
      PrefetchHooks Function({bool note})
    >;
typedef $$ChunksTableCreateCompanionBuilder = ChunksCompanion Function({
  required int note,
  required int idx,
  required int start,
  required int end,
  required String hash,
  required String model,
  required Uint8List vector,
  Value<int> rowid,
});
typedef $$ChunksTableUpdateCompanionBuilder = ChunksCompanion Function({
  Value<int> note,
  Value<int> idx,
  Value<int> start,
  Value<int> end,
  Value<String> hash,
  Value<String> model,
  Value<Uint8List> vector,
  Value<int> rowid,
});

final class $$ChunksTableReferences
    extends BaseReferences<_$AppDatabase, $ChunksTable, ChunkRow> {
  $$ChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteTable(_$AppDatabase db) =>
      db.notes.createAlias('chunks__note__notes__id');

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

class $$ChunksTableFilterComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
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

class $$ChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
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

class $$ChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChunksTable> {
  $$ChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<int> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<int> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

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

class $$ChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChunksTable,
          ChunkRow,
          $$ChunksTableFilterComposer,
          $$ChunksTableOrderingComposer,
          $$ChunksTableAnnotationComposer,
          $$ChunksTableCreateCompanionBuilder,
          $$ChunksTableUpdateCompanionBuilder,
          (ChunkRow, $$ChunksTableReferences),
          ChunkRow,
          PrefetchHooks Function({bool note})
        > {
  $$ChunksTableTableManager(_$AppDatabase db, $ChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> note = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<int> start = const Value.absent(),
                Value<int> end = const Value.absent(),
                Value<String> hash = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChunksCompanion(
                note: note,
                idx: idx,
                start: start,
                end: end,
                hash: hash,
                model: model,
                vector: vector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int note,
                required int idx,
                required int start,
                required int end,
                required String hash,
                required String model,
                required Uint8List vector,
                Value<int> rowid = const Value.absent(),
              }) => ChunksCompanion.insert(
                note: note,
                idx: idx,
                start: start,
                end: end,
                hash: hash,
                model: model,
                vector: vector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChunksTable, ChunkRow>(table),
                  $$ChunksTableReferences(db, table, e),
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
                        referencedTable: $$ChunksTableReferences._noteTable(db),
                        referencedColumn: $$ChunksTableReferences
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

typedef $$ChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChunksTable,
      ChunkRow,
      $$ChunksTableFilterComposer,
      $$ChunksTableOrderingComposer,
      $$ChunksTableAnnotationComposer,
      $$ChunksTableCreateCompanionBuilder,
      $$ChunksTableUpdateCompanionBuilder,
      (ChunkRow, $$ChunksTableReferences),
      ChunkRow,
      PrefetchHooks Function({bool note})
    >;
typedef $$SuggestionsTableCreateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      required String kind,
      required int noteA,
      required int noteB,
      Value<String> tag,
      Value<String> detail,
      Value<bool> fromLaptop,
      required double score,
      required int chunkA,
      required int chunkB,
      required String status,
      required DateTime createdAt,
      required DateTime expiresAt,
    });
typedef $$SuggestionsTableUpdateCompanionBuilder =
    SuggestionsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<int> noteA,
      Value<int> noteB,
      Value<String> tag,
      Value<String> detail,
      Value<bool> fromLaptop,
      Value<double> score,
      Value<int> chunkA,
      Value<int> chunkB,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
    });

final class $$SuggestionsTableReferences
    extends BaseReferences<_$AppDatabase, $SuggestionsTable, SuggestionRow> {
  $$SuggestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteATable(_$AppDatabase db) =>
      db.notes.createAlias('suggestions__note_a__notes__id');

  $$NotesTableProcessedTableManager get noteA {
    final $_column = $_itemColumn<int>('note_a')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteATable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NotesTable _noteBTable(_$AppDatabase db) =>
      db.notes.createAlias('suggestions__note_b__notes__id');

  $$NotesTableProcessedTableManager get noteB {
    final $_column = $_itemColumn<int>('note_b')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteBTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fromLaptop => $composableBuilder(
    column: $table.fromLaptop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkA => $composableBuilder(
    column: $table.chunkA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkB => $composableBuilder(
    column: $table.chunkB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteA {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteA,
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

  $$NotesTableFilterComposer get noteB {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteB,
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

class $$SuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fromLaptop => $composableBuilder(
    column: $table.fromLaptop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkA => $composableBuilder(
    column: $table.chunkA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkB => $composableBuilder(
    column: $table.chunkB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteA {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteA,
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

  $$NotesTableOrderingComposer get noteB {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteB,
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

class $$SuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuggestionsTable> {
  $$SuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<bool> get fromLaptop => $composableBuilder(
    column: $table.fromLaptop,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get chunkA =>
      $composableBuilder(column: $table.chunkA, builder: (column) => column);

  GeneratedColumn<int> get chunkB =>
      $composableBuilder(column: $table.chunkB, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteA {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteA,
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

  $$NotesTableAnnotationComposer get noteB {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteB,
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

class $$SuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuggestionsTable,
          SuggestionRow,
          $$SuggestionsTableFilterComposer,
          $$SuggestionsTableOrderingComposer,
          $$SuggestionsTableAnnotationComposer,
          $$SuggestionsTableCreateCompanionBuilder,
          $$SuggestionsTableUpdateCompanionBuilder,
          (SuggestionRow, $$SuggestionsTableReferences),
          SuggestionRow,
          PrefetchHooks Function({bool noteA, bool noteB})
        > {
  $$SuggestionsTableTableManager(_$AppDatabase db, $SuggestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuggestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> noteA = const Value.absent(),
                Value<int> noteB = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<bool> fromLaptop = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> chunkA = const Value.absent(),
                Value<int> chunkB = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => SuggestionsCompanion(
                id: id,
                kind: kind,
                noteA: noteA,
                noteB: noteB,
                tag: tag,
                detail: detail,
                fromLaptop: fromLaptop,
                score: score,
                chunkA: chunkA,
                chunkB: chunkB,
                status: status,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required int noteA,
                required int noteB,
                Value<String> tag = const Value.absent(),
                Value<String> detail = const Value.absent(),
                Value<bool> fromLaptop = const Value.absent(),
                required double score,
                required int chunkA,
                required int chunkB,
                required String status,
                required DateTime createdAt,
                required DateTime expiresAt,
              }) => SuggestionsCompanion.insert(
                id: id,
                kind: kind,
                noteA: noteA,
                noteB: noteB,
                tag: tag,
                detail: detail,
                fromLaptop: fromLaptop,
                score: score,
                chunkA: chunkA,
                chunkB: chunkB,
                status: status,
                createdAt: createdAt,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuggestionsTable, SuggestionRow>(table),
                  $$SuggestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteA = false, noteB = false}) {
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
                    if (noteA) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteA,
                        referencedTable: $$SuggestionsTableReferences
                            ._noteATable(db),
                        referencedColumn: $$SuggestionsTableReferences
                            ._noteATable(db)
                            .id,
                      ) as T;
                    }
                    if (noteB) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteB,
                        referencedTable: $$SuggestionsTableReferences
                            ._noteBTable(db),
                        referencedColumn: $$SuggestionsTableReferences
                            ._noteBTable(db)
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

typedef $$SuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuggestionsTable,
      SuggestionRow,
      $$SuggestionsTableFilterComposer,
      $$SuggestionsTableOrderingComposer,
      $$SuggestionsTableAnnotationComposer,
      $$SuggestionsTableCreateCompanionBuilder,
      $$SuggestionsTableUpdateCompanionBuilder,
      (SuggestionRow, $$SuggestionsTableReferences),
      SuggestionRow,
      PrefetchHooks Function({bool noteA, bool noteB})
    >;
typedef $$RejectionsTableCreateCompanionBuilder = RejectionsCompanion Function({
  required String pairKey,
  required String noteA,
  required String hashA,
  required String noteB,
  required String hashB,
  Value<Uint8List?> signatureA,
  Value<Uint8List?> signatureB,
  required DateTime rejectedAt,
  required String deviceId,
  Value<int> rowid,
});
typedef $$RejectionsTableUpdateCompanionBuilder = RejectionsCompanion Function({
  Value<String> pairKey,
  Value<String> noteA,
  Value<String> hashA,
  Value<String> noteB,
  Value<String> hashB,
  Value<Uint8List?> signatureA,
  Value<Uint8List?> signatureB,
  Value<DateTime> rejectedAt,
  Value<String> deviceId,
  Value<int> rowid,
});

class $$RejectionsTableFilterComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pairKey => $composableBuilder(
    column: $table.pairKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteA => $composableBuilder(
    column: $table.noteA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashA => $composableBuilder(
    column: $table.hashA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteB => $composableBuilder(
    column: $table.noteB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashB => $composableBuilder(
    column: $table.hashB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signatureA => $composableBuilder(
    column: $table.signatureA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signatureB => $composableBuilder(
    column: $table.signatureB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RejectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pairKey => $composableBuilder(
    column: $table.pairKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteA => $composableBuilder(
    column: $table.noteA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashA => $composableBuilder(
    column: $table.hashA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteB => $composableBuilder(
    column: $table.noteB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashB => $composableBuilder(
    column: $table.hashB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signatureA => $composableBuilder(
    column: $table.signatureA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signatureB => $composableBuilder(
    column: $table.signatureB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RejectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RejectionsTable> {
  $$RejectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pairKey =>
      $composableBuilder(column: $table.pairKey, builder: (column) => column);

  GeneratedColumn<String> get noteA =>
      $composableBuilder(column: $table.noteA, builder: (column) => column);

  GeneratedColumn<String> get hashA =>
      $composableBuilder(column: $table.hashA, builder: (column) => column);

  GeneratedColumn<String> get noteB =>
      $composableBuilder(column: $table.noteB, builder: (column) => column);

  GeneratedColumn<String> get hashB =>
      $composableBuilder(column: $table.hashB, builder: (column) => column);

  GeneratedColumn<Uint8List> get signatureA => $composableBuilder(
    column: $table.signatureA,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signatureB => $composableBuilder(
    column: $table.signatureB,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$RejectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RejectionsTable,
          RejectionRow,
          $$RejectionsTableFilterComposer,
          $$RejectionsTableOrderingComposer,
          $$RejectionsTableAnnotationComposer,
          $$RejectionsTableCreateCompanionBuilder,
          $$RejectionsTableUpdateCompanionBuilder,
          (
            RejectionRow,
            BaseReferences<_$AppDatabase, $RejectionsTable, RejectionRow>,
          ),
          RejectionRow,
          PrefetchHooks Function()
        > {
  $$RejectionsTableTableManager(_$AppDatabase db, $RejectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RejectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RejectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RejectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pairKey = const Value.absent(),
                Value<String> noteA = const Value.absent(),
                Value<String> hashA = const Value.absent(),
                Value<String> noteB = const Value.absent(),
                Value<String> hashB = const Value.absent(),
                Value<Uint8List?> signatureA = const Value.absent(),
                Value<Uint8List?> signatureB = const Value.absent(),
                Value<DateTime> rejectedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RejectionsCompanion(
                pairKey: pairKey,
                noteA: noteA,
                hashA: hashA,
                noteB: noteB,
                hashB: hashB,
                signatureA: signatureA,
                signatureB: signatureB,
                rejectedAt: rejectedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pairKey,
                required String noteA,
                required String hashA,
                required String noteB,
                required String hashB,
                Value<Uint8List?> signatureA = const Value.absent(),
                Value<Uint8List?> signatureB = const Value.absent(),
                required DateTime rejectedAt,
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => RejectionsCompanion.insert(
                pairKey: pairKey,
                noteA: noteA,
                hashA: hashA,
                noteB: noteB,
                hashB: hashB,
                signatureA: signatureA,
                signatureB: signatureB,
                rejectedAt: rejectedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RejectionsTable, RejectionRow>(table),
                  BaseReferences<_$AppDatabase, $RejectionsTable, RejectionRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RejectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RejectionsTable,
      RejectionRow,
      $$RejectionsTableFilterComposer,
      $$RejectionsTableOrderingComposer,
      $$RejectionsTableAnnotationComposer,
      $$RejectionsTableCreateCompanionBuilder,
      $$RejectionsTableUpdateCompanionBuilder,
      (
        RejectionRow,
        BaseReferences<_$AppDatabase, $RejectionsTable, RejectionRow>,
      ),
      RejectionRow,
      PrefetchHooks Function()
    >;
typedef $$ImportedResultsTableCreateCompanionBuilder =
    ImportedResultsCompanion Function({
      required String jobKey,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$ImportedResultsTableUpdateCompanionBuilder =
    ImportedResultsCompanion Function({
      Value<String> jobKey,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$ImportedResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportedResultsTable> {
  $$ImportedResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get jobKey => $composableBuilder(
    column: $table.jobKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportedResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportedResultsTable> {
  $$ImportedResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get jobKey => $composableBuilder(
    column: $table.jobKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportedResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportedResultsTable> {
  $$ImportedResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get jobKey =>
      $composableBuilder(column: $table.jobKey, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$ImportedResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportedResultsTable,
          ImportedResult,
          $$ImportedResultsTableFilterComposer,
          $$ImportedResultsTableOrderingComposer,
          $$ImportedResultsTableAnnotationComposer,
          $$ImportedResultsTableCreateCompanionBuilder,
          $$ImportedResultsTableUpdateCompanionBuilder,
          (
            ImportedResult,
            BaseReferences<
              _$AppDatabase,
              $ImportedResultsTable,
              ImportedResult
            >,
          ),
          ImportedResult,
          PrefetchHooks Function()
        > {
  $$ImportedResultsTableTableManager(
    _$AppDatabase db,
    $ImportedResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportedResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportedResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportedResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jobKey = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportedResultsCompanion(
                jobKey: jobKey,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jobKey,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportedResultsCompanion.insert(
                jobKey: jobKey,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportedResultsTable, ImportedResult>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImportedResultsTable,
                    ImportedResult
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportedResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportedResultsTable,
      ImportedResult,
      $$ImportedResultsTableFilterComposer,
      $$ImportedResultsTableOrderingComposer,
      $$ImportedResultsTableAnnotationComposer,
      $$ImportedResultsTableCreateCompanionBuilder,
      $$ImportedResultsTableUpdateCompanionBuilder,
      (
        ImportedResult,
        BaseReferences<_$AppDatabase, $ImportedResultsTable, ImportedResult>,
      ),
      ImportedResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$LinksTableTableManager get links =>
      $$LinksTableTableManager(_db, _db.links);
  $$NoteAnalysisTableTableManager get noteAnalysis =>
      $$NoteAnalysisTableTableManager(_db, _db.noteAnalysis);
  $$ChunksTableTableManager get chunks =>
      $$ChunksTableTableManager(_db, _db.chunks);
  $$SuggestionsTableTableManager get suggestions =>
      $$SuggestionsTableTableManager(_db, _db.suggestions);
  $$RejectionsTableTableManager get rejections =>
      $$RejectionsTableTableManager(_db, _db.rejections);
  $$ImportedResultsTableTableManager get importedResults =>
      $$ImportedResultsTableTableManager(_db, _db.importedResults);
}
