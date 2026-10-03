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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $LinksTable links = $LinksTable(this);
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notes,
    noteTags,
    settings,
    links,
    notesModified,
    notesNoteId,
    notesFolder,
    notesNameKey,
    noteTagsTag,
    linksTarget,
    linksSource,
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
          PrefetchHooks Function({bool noteTagsRefs, bool linksRefs})
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
          prefetchHooksCallback: ({noteTagsRefs = false, linksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (noteTagsRefs) db.noteTags,
                if (linksRefs) db.links,
              ],
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
                  if (linksRefs)
                    await $_getPrefetchedData<NoteRow, $NotesTable, LinkRow>(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences._linksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$NotesTableReferences(db, table, p0).linksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.source == item.id),
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
      PrefetchHooks Function({bool noteTagsRefs, bool linksRefs})
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
}
