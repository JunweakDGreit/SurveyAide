// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QuotesTable extends Quotes with TableInfo<$QuotesTable, Quote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _clientMeta = const VerificationMeta('client');
  @override
  late final GeneratedColumn<String> client = GeneratedColumn<String>(
      'client', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, client, location, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(Insertable<Quote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client')) {
      context.handle(_clientMeta,
          client.isAcceptableOrUnknown(data['client']!, _clientMeta));
    } else if (isInserting) {
      context.missing(_clientMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      client: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class Quote extends DataClass implements Insertable<Quote> {
  final int id;
  final String client;
  final String? location;
  final String createdAt;
  const Quote(
      {required this.id,
      required this.client,
      this.location,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client'] = Variable<String>(client);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      client: Value(client),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory Quote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quote(
      id: serializer.fromJson<int>(json['id']),
      client: serializer.fromJson<String>(json['client']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'client': serializer.toJson<String>(client),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  Quote copyWith(
          {int? id,
          String? client,
          Value<String?> location = const Value.absent(),
          String? createdAt}) =>
      Quote(
        id: id ?? this.id,
        client: client ?? this.client,
        location: location.present ? location.value : this.location,
        createdAt: createdAt ?? this.createdAt,
      );
  Quote copyWithCompanion(QuotesCompanion data) {
    return Quote(
      id: data.id.present ? data.id.value : this.id,
      client: data.client.present ? data.client.value : this.client,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quote(')
          ..write('id: $id, ')
          ..write('client: $client, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, client, location, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          other.id == this.id &&
          other.client == this.client &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class QuotesCompanion extends UpdateCompanion<Quote> {
  final Value<int> id;
  final Value<String> client;
  final Value<String?> location;
  final Value<String> createdAt;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.client = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required String client,
    this.location = const Value.absent(),
    required String createdAt,
  })  : client = Value(client),
        createdAt = Value(createdAt);
  static Insertable<Quote> custom({
    Expression<int>? id,
    Expression<String>? client,
    Expression<String>? location,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (client != null) 'client': client,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? client,
      Value<String?>? location,
      Value<String>? createdAt}) {
    return QuotesCompanion(
      id: id ?? this.id,
      client: client ?? this.client,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (client.present) {
      map['client'] = Variable<String>(client.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('client: $client, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuoteItemsTable extends QuoteItems
    with TableInfo<$QuoteItemsTable, QuoteItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuoteItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _quoteIdMeta =
      const VerificationMeta('quoteId');
  @override
  late final GeneratedColumn<int> quoteId = GeneratedColumn<int>(
      'quote_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES quotes (id)'));
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _linesJsonMeta =
      const VerificationMeta('linesJson');
  @override
  late final GeneratedColumn<String> linesJson = GeneratedColumn<String>(
      'lines_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, quoteId, uid, code, name, total, linesJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quote_items';
  @override
  VerificationContext validateIntegrity(Insertable<QuoteItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quote_id')) {
      context.handle(_quoteIdMeta,
          quoteId.isAcceptableOrUnknown(data['quote_id']!, _quoteIdMeta));
    } else if (isInserting) {
      context.missing(_quoteIdMeta);
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('lines_json')) {
      context.handle(_linesJsonMeta,
          linesJson.isAcceptableOrUnknown(data['lines_json']!, _linesJsonMeta));
    } else if (isInserting) {
      context.missing(_linesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      quoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quote_id'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      linesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lines_json'])!,
    );
  }

  @override
  $QuoteItemsTable createAlias(String alias) {
    return $QuoteItemsTable(attachedDatabase, alias);
  }
}

class QuoteItem extends DataClass implements Insertable<QuoteItem> {
  final int id;
  final int quoteId;
  final String uid;
  final String code;
  final String name;
  final double total;
  final String linesJson;
  const QuoteItem(
      {required this.id,
      required this.quoteId,
      required this.uid,
      required this.code,
      required this.name,
      required this.total,
      required this.linesJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quote_id'] = Variable<int>(quoteId);
    map['uid'] = Variable<String>(uid);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['total'] = Variable<double>(total);
    map['lines_json'] = Variable<String>(linesJson);
    return map;
  }

  QuoteItemsCompanion toCompanion(bool nullToAbsent) {
    return QuoteItemsCompanion(
      id: Value(id),
      quoteId: Value(quoteId),
      uid: Value(uid),
      code: Value(code),
      name: Value(name),
      total: Value(total),
      linesJson: Value(linesJson),
    );
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteItem(
      id: serializer.fromJson<int>(json['id']),
      quoteId: serializer.fromJson<int>(json['quoteId']),
      uid: serializer.fromJson<String>(json['uid']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      total: serializer.fromJson<double>(json['total']),
      linesJson: serializer.fromJson<String>(json['linesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quoteId': serializer.toJson<int>(quoteId),
      'uid': serializer.toJson<String>(uid),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'total': serializer.toJson<double>(total),
      'linesJson': serializer.toJson<String>(linesJson),
    };
  }

  QuoteItem copyWith(
          {int? id,
          int? quoteId,
          String? uid,
          String? code,
          String? name,
          double? total,
          String? linesJson}) =>
      QuoteItem(
        id: id ?? this.id,
        quoteId: quoteId ?? this.quoteId,
        uid: uid ?? this.uid,
        code: code ?? this.code,
        name: name ?? this.name,
        total: total ?? this.total,
        linesJson: linesJson ?? this.linesJson,
      );
  QuoteItem copyWithCompanion(QuoteItemsCompanion data) {
    return QuoteItem(
      id: data.id.present ? data.id.value : this.id,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      uid: data.uid.present ? data.uid.value : this.uid,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      total: data.total.present ? data.total.value : this.total,
      linesJson: data.linesJson.present ? data.linesJson.value : this.linesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItem(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('uid: $uid, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('total: $total, ')
          ..write('linesJson: $linesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, quoteId, uid, code, name, total, linesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteItem &&
          other.id == this.id &&
          other.quoteId == this.quoteId &&
          other.uid == this.uid &&
          other.code == this.code &&
          other.name == this.name &&
          other.total == this.total &&
          other.linesJson == this.linesJson);
}

class QuoteItemsCompanion extends UpdateCompanion<QuoteItem> {
  final Value<int> id;
  final Value<int> quoteId;
  final Value<String> uid;
  final Value<String> code;
  final Value<String> name;
  final Value<double> total;
  final Value<String> linesJson;
  const QuoteItemsCompanion({
    this.id = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.uid = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.total = const Value.absent(),
    this.linesJson = const Value.absent(),
  });
  QuoteItemsCompanion.insert({
    this.id = const Value.absent(),
    required int quoteId,
    required String uid,
    required String code,
    required String name,
    required double total,
    required String linesJson,
  })  : quoteId = Value(quoteId),
        uid = Value(uid),
        code = Value(code),
        name = Value(name),
        total = Value(total),
        linesJson = Value(linesJson);
  static Insertable<QuoteItem> custom({
    Expression<int>? id,
    Expression<int>? quoteId,
    Expression<String>? uid,
    Expression<String>? code,
    Expression<String>? name,
    Expression<double>? total,
    Expression<String>? linesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quoteId != null) 'quote_id': quoteId,
      if (uid != null) 'uid': uid,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (total != null) 'total': total,
      if (linesJson != null) 'lines_json': linesJson,
    });
  }

  QuoteItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? quoteId,
      Value<String>? uid,
      Value<String>? code,
      Value<String>? name,
      Value<double>? total,
      Value<String>? linesJson}) {
    return QuoteItemsCompanion(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      uid: uid ?? this.uid,
      code: code ?? this.code,
      name: name ?? this.name,
      total: total ?? this.total,
      linesJson: linesJson ?? this.linesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<int>(quoteId.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (linesJson.present) {
      map['lines_json'] = Variable<String>(linesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItemsCompanion(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('uid: $uid, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('total: $total, ')
          ..write('linesJson: $linesJson')
          ..write(')'))
        .toString();
  }
}

class $RateOverridesTable extends RateOverrides
    with TableInfo<$RateOverridesTable, RateOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [code, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_overrides';
  @override
  VerificationContext validateIntegrity(Insertable<RateOverride> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code, key};
  @override
  RateOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateOverride(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $RateOverridesTable createAlias(String alias) {
    return $RateOverridesTable(attachedDatabase, alias);
  }
}

class RateOverride extends DataClass implements Insertable<RateOverride> {
  final String code;
  final String key;
  final double value;
  const RateOverride(
      {required this.code, required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<double>(value);
    return map;
  }

  RateOverridesCompanion toCompanion(bool nullToAbsent) {
    return RateOverridesCompanion(
      code: Value(code),
      key: Value(key),
      value: Value(value),
    );
  }

  factory RateOverride.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateOverride(
      code: serializer.fromJson<String>(json['code']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<double>(value),
    };
  }

  RateOverride copyWith({String? code, String? key, double? value}) =>
      RateOverride(
        code: code ?? this.code,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  RateOverride copyWithCompanion(RateOverridesCompanion data) {
    return RateOverride(
      code: data.code.present ? data.code.value : this.code,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateOverride(')
          ..write('code: $code, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateOverride &&
          other.code == this.code &&
          other.key == this.key &&
          other.value == this.value);
}

class RateOverridesCompanion extends UpdateCompanion<RateOverride> {
  final Value<String> code;
  final Value<String> key;
  final Value<double> value;
  final Value<int> rowid;
  const RateOverridesCompanion({
    this.code = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RateOverridesCompanion.insert({
    required String code,
    required String key,
    required double value,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        key = Value(key),
        value = Value(value);
  static Insertable<RateOverride> custom({
    Expression<String>? code,
    Expression<String>? key,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RateOverridesCompanion copyWith(
      {Value<String>? code,
      Value<String>? key,
      Value<double>? value,
      Value<int>? rowid}) {
    return RateOverridesCompanion(
      code: code ?? this.code,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateOverridesCompanion(')
          ..write('code: $code, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _quoteItemUidMeta =
      const VerificationMeta('quoteItemUid');
  @override
  late final GeneratedColumn<String> quoteItemUid = GeneratedColumn<String>(
      'quote_item_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pctMeta = const VerificationMeta('pct');
  @override
  late final GeneratedColumn<double> pct = GeneratedColumn<double>(
      'pct', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<bool> paid = GeneratedColumn<bool>(
      'paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, quoteItemUid, label, pct, dueDate, paid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quote_item_uid')) {
      context.handle(
          _quoteItemUidMeta,
          quoteItemUid.isAcceptableOrUnknown(
              data['quote_item_uid']!, _quoteItemUidMeta));
    } else if (isInserting) {
      context.missing(_quoteItemUidMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('pct')) {
      context.handle(
          _pctMeta, pct.isAcceptableOrUnknown(data['pct']!, _pctMeta));
    } else if (isInserting) {
      context.missing(_pctMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('paid')) {
      context.handle(
          _paidMeta, paid.isAcceptableOrUnknown(data['paid']!, _paidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      quoteItemUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quote_item_uid'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      pct: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pct'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      paid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}paid'])!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final String quoteItemUid;
  final String label;
  final double pct;
  final String? dueDate;
  final bool paid;
  const Payment(
      {required this.id,
      required this.quoteItemUid,
      required this.label,
      required this.pct,
      this.dueDate,
      required this.paid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quote_item_uid'] = Variable<String>(quoteItemUid);
    map['label'] = Variable<String>(label);
    map['pct'] = Variable<double>(pct);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    map['paid'] = Variable<bool>(paid);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      quoteItemUid: Value(quoteItemUid),
      label: Value(label),
      pct: Value(pct),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      paid: Value(paid),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      quoteItemUid: serializer.fromJson<String>(json['quoteItemUid']),
      label: serializer.fromJson<String>(json['label']),
      pct: serializer.fromJson<double>(json['pct']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      paid: serializer.fromJson<bool>(json['paid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quoteItemUid': serializer.toJson<String>(quoteItemUid),
      'label': serializer.toJson<String>(label),
      'pct': serializer.toJson<double>(pct),
      'dueDate': serializer.toJson<String?>(dueDate),
      'paid': serializer.toJson<bool>(paid),
    };
  }

  Payment copyWith(
          {int? id,
          String? quoteItemUid,
          String? label,
          double? pct,
          Value<String?> dueDate = const Value.absent(),
          bool? paid}) =>
      Payment(
        id: id ?? this.id,
        quoteItemUid: quoteItemUid ?? this.quoteItemUid,
        label: label ?? this.label,
        pct: pct ?? this.pct,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        paid: paid ?? this.paid,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      quoteItemUid: data.quoteItemUid.present
          ? data.quoteItemUid.value
          : this.quoteItemUid,
      label: data.label.present ? data.label.value : this.label,
      pct: data.pct.present ? data.pct.value : this.pct,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paid: data.paid.present ? data.paid.value : this.paid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('quoteItemUid: $quoteItemUid, ')
          ..write('label: $label, ')
          ..write('pct: $pct, ')
          ..write('dueDate: $dueDate, ')
          ..write('paid: $paid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, quoteItemUid, label, pct, dueDate, paid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.quoteItemUid == this.quoteItemUid &&
          other.label == this.label &&
          other.pct == this.pct &&
          other.dueDate == this.dueDate &&
          other.paid == this.paid);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<String> quoteItemUid;
  final Value<String> label;
  final Value<double> pct;
  final Value<String?> dueDate;
  final Value<bool> paid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.quoteItemUid = const Value.absent(),
    this.label = const Value.absent(),
    this.pct = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String quoteItemUid,
    required String label,
    required double pct,
    this.dueDate = const Value.absent(),
    this.paid = const Value.absent(),
  })  : quoteItemUid = Value(quoteItemUid),
        label = Value(label),
        pct = Value(pct);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<String>? quoteItemUid,
    Expression<String>? label,
    Expression<double>? pct,
    Expression<String>? dueDate,
    Expression<bool>? paid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quoteItemUid != null) 'quote_item_uid': quoteItemUid,
      if (label != null) 'label': label,
      if (pct != null) 'pct': pct,
      if (dueDate != null) 'due_date': dueDate,
      if (paid != null) 'paid': paid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? quoteItemUid,
      Value<String>? label,
      Value<double>? pct,
      Value<String?>? dueDate,
      Value<bool>? paid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      quoteItemUid: quoteItemUid ?? this.quoteItemUid,
      label: label ?? this.label,
      pct: pct ?? this.pct,
      dueDate: dueDate ?? this.dueDate,
      paid: paid ?? this.paid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quoteItemUid.present) {
      map['quote_item_uid'] = Variable<String>(quoteItemUid.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (pct.present) {
      map['pct'] = Variable<double>(pct.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (paid.present) {
      map['paid'] = Variable<bool>(paid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('quoteItemUid: $quoteItemUid, ')
          ..write('label: $label, ')
          ..write('pct: $pct, ')
          ..write('dueDate: $dueDate, ')
          ..write('paid: $paid')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, title, date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(Insertable<Appointment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final int id;
  final String title;
  final String date;
  final String? note;
  const Appointment(
      {required this.id, required this.title, required this.date, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Appointment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'note': serializer.toJson<String?>(note),
    };
  }

  Appointment copyWith(
          {int? id,
          String? title,
          String? date,
          Value<String?> note = const Value.absent()}) =>
      Appointment(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        note: note.present ? note.value : this.note,
      );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.note == this.note);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> date;
  final Value<String?> note;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String date,
    this.note = const Value.absent(),
  })  : title = Value(title),
        date = Value(date);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? date,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
    });
  }

  AppointmentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? date,
      Value<String?>? note}) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $ServiceCategoriesTable extends ServiceCategories
    with TableInfo<$ServiceCategoriesTable, DbServiceCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, label, color, iconName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_categories';
  @override
  VerificationContext validateIntegrity(Insertable<DbServiceCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbServiceCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbServiceCategory(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name'])!,
    );
  }

  @override
  $ServiceCategoriesTable createAlias(String alias) {
    return $ServiceCategoriesTable(attachedDatabase, alias);
  }
}

class DbServiceCategory extends DataClass
    implements Insertable<DbServiceCategory> {
  final String key;
  final String label;
  final String color;
  final String iconName;
  const DbServiceCategory(
      {required this.key,
      required this.label,
      required this.color,
      required this.iconName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['label'] = Variable<String>(label);
    map['color'] = Variable<String>(color);
    map['icon_name'] = Variable<String>(iconName);
    return map;
  }

  ServiceCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ServiceCategoriesCompanion(
      key: Value(key),
      label: Value(label),
      color: Value(color),
      iconName: Value(iconName),
    );
  }

  factory DbServiceCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbServiceCategory(
      key: serializer.fromJson<String>(json['key']),
      label: serializer.fromJson<String>(json['label']),
      color: serializer.fromJson<String>(json['color']),
      iconName: serializer.fromJson<String>(json['iconName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'label': serializer.toJson<String>(label),
      'color': serializer.toJson<String>(color),
      'iconName': serializer.toJson<String>(iconName),
    };
  }

  DbServiceCategory copyWith(
          {String? key, String? label, String? color, String? iconName}) =>
      DbServiceCategory(
        key: key ?? this.key,
        label: label ?? this.label,
        color: color ?? this.color,
        iconName: iconName ?? this.iconName,
      );
  DbServiceCategory copyWithCompanion(ServiceCategoriesCompanion data) {
    return DbServiceCategory(
      key: data.key.present ? data.key.value : this.key,
      label: data.label.present ? data.label.value : this.label,
      color: data.color.present ? data.color.value : this.color,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbServiceCategory(')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('iconName: $iconName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, label, color, iconName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbServiceCategory &&
          other.key == this.key &&
          other.label == this.label &&
          other.color == this.color &&
          other.iconName == this.iconName);
}

class ServiceCategoriesCompanion extends UpdateCompanion<DbServiceCategory> {
  final Value<String> key;
  final Value<String> label;
  final Value<String> color;
  final Value<String> iconName;
  final Value<int> rowid;
  const ServiceCategoriesCompanion({
    this.key = const Value.absent(),
    this.label = const Value.absent(),
    this.color = const Value.absent(),
    this.iconName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceCategoriesCompanion.insert({
    required String key,
    required String label,
    required String color,
    required String iconName,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        label = Value(label),
        color = Value(color),
        iconName = Value(iconName);
  static Insertable<DbServiceCategory> custom({
    Expression<String>? key,
    Expression<String>? label,
    Expression<String>? color,
    Expression<String>? iconName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (color != null) 'color': color,
      if (iconName != null) 'icon_name': iconName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceCategoriesCompanion copyWith(
      {Value<String>? key,
      Value<String>? label,
      Value<String>? color,
      Value<String>? iconName,
      Value<int>? rowid}) {
    return ServiceCategoriesCompanion(
      key: key ?? this.key,
      label: label ?? this.label,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceCategoriesCompanion(')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('iconName: $iconName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServicesTable extends Services
    with TableInfo<$ServicesTable, DbService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _catMeta = const VerificationMeta('cat');
  @override
  late final GeneratedColumn<String> cat = GeneratedColumn<String>(
      'cat', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
      'group', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shortDescriptionMeta =
      const VerificationMeta('shortDescription');
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
      'short_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [code, name, cat, group, shortDescription, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'services';
  @override
  VerificationContext validateIntegrity(Insertable<DbService> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cat')) {
      context.handle(
          _catMeta, cat.isAcceptableOrUnknown(data['cat']!, _catMeta));
    } else if (isInserting) {
      context.missing(_catMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
          _groupMeta, group.isAcceptableOrUnknown(data['group']!, _groupMeta));
    }
    if (data.containsKey('short_description')) {
      context.handle(
          _shortDescriptionMeta,
          shortDescription.isAcceptableOrUnknown(
              data['short_description']!, _shortDescriptionMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  DbService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbService(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cat'])!,
      group: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group']),
      shortDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}short_description']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ServicesTable createAlias(String alias) {
    return $ServicesTable(attachedDatabase, alias);
  }
}

class DbService extends DataClass implements Insertable<DbService> {
  final String code;
  final String name;
  final String cat;
  final String? group;
  final String? shortDescription;
  final String? note;
  const DbService(
      {required this.code,
      required this.name,
      required this.cat,
      this.group,
      this.shortDescription,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['cat'] = Variable<String>(cat);
    if (!nullToAbsent || group != null) {
      map['group'] = Variable<String>(group);
    }
    if (!nullToAbsent || shortDescription != null) {
      map['short_description'] = Variable<String>(shortDescription);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ServicesCompanion toCompanion(bool nullToAbsent) {
    return ServicesCompanion(
      code: Value(code),
      name: Value(name),
      cat: Value(cat),
      group:
          group == null && nullToAbsent ? const Value.absent() : Value(group),
      shortDescription: shortDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(shortDescription),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DbService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbService(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      cat: serializer.fromJson<String>(json['cat']),
      group: serializer.fromJson<String?>(json['group']),
      shortDescription: serializer.fromJson<String?>(json['shortDescription']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'cat': serializer.toJson<String>(cat),
      'group': serializer.toJson<String?>(group),
      'shortDescription': serializer.toJson<String?>(shortDescription),
      'note': serializer.toJson<String?>(note),
    };
  }

  DbService copyWith(
          {String? code,
          String? name,
          String? cat,
          Value<String?> group = const Value.absent(),
          Value<String?> shortDescription = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      DbService(
        code: code ?? this.code,
        name: name ?? this.name,
        cat: cat ?? this.cat,
        group: group.present ? group.value : this.group,
        shortDescription: shortDescription.present
            ? shortDescription.value
            : this.shortDescription,
        note: note.present ? note.value : this.note,
      );
  DbService copyWithCompanion(ServicesCompanion data) {
    return DbService(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      cat: data.cat.present ? data.cat.value : this.cat,
      group: data.group.present ? data.group.value : this.group,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbService(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('cat: $cat, ')
          ..write('group: $group, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, cat, group, shortDescription, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbService &&
          other.code == this.code &&
          other.name == this.name &&
          other.cat == this.cat &&
          other.group == this.group &&
          other.shortDescription == this.shortDescription &&
          other.note == this.note);
}

class ServicesCompanion extends UpdateCompanion<DbService> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> cat;
  final Value<String?> group;
  final Value<String?> shortDescription;
  final Value<String?> note;
  final Value<int> rowid;
  const ServicesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.cat = const Value.absent(),
    this.group = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServicesCompanion.insert({
    required String code,
    required String name,
    required String cat,
    this.group = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        cat = Value(cat);
  static Insertable<DbService> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? cat,
    Expression<String>? group,
    Expression<String>? shortDescription,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (cat != null) 'cat': cat,
      if (group != null) 'group': group,
      if (shortDescription != null) 'short_description': shortDescription,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServicesCompanion copyWith(
      {Value<String>? code,
      Value<String>? name,
      Value<String>? cat,
      Value<String?>? group,
      Value<String?>? shortDescription,
      Value<String?>? note,
      Value<int>? rowid}) {
    return ServicesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      cat: cat ?? this.cat,
      group: group ?? this.group,
      shortDescription: shortDescription ?? this.shortDescription,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cat.present) {
      map['cat'] = Variable<String>(cat.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('cat: $cat, ')
          ..write('group: $group, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceFieldsTable extends ServiceFields
    with TableInfo<$ServiceFieldsTable, DbServiceField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serviceCodeMeta =
      const VerificationMeta('serviceCode');
  @override
  late final GeneratedColumn<String> serviceCode = GeneratedColumn<String>(
      'service_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<double> step = GeneratedColumn<double>(
      'step', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _minMeta = const VerificationMeta('min');
  @override
  late final GeneratedColumn<double> min = GeneratedColumn<double>(
      'min', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _defMeta = const VerificationMeta('def');
  @override
  late final GeneratedColumn<double> def = GeneratedColumn<double>(
      'def', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, serviceCode, key, label, type, step, min, def, optionsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_fields';
  @override
  VerificationContext validateIntegrity(Insertable<DbServiceField> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_code')) {
      context.handle(
          _serviceCodeMeta,
          serviceCode.isAcceptableOrUnknown(
              data['service_code']!, _serviceCodeMeta));
    } else if (isInserting) {
      context.missing(_serviceCodeMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('step')) {
      context.handle(
          _stepMeta, step.isAcceptableOrUnknown(data['step']!, _stepMeta));
    }
    if (data.containsKey('min')) {
      context.handle(
          _minMeta, min.isAcceptableOrUnknown(data['min']!, _minMeta));
    }
    if (data.containsKey('def')) {
      context.handle(
          _defMeta, def.isAcceptableOrUnknown(data['def']!, _defMeta));
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbServiceField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbServiceField(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serviceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_code'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      step: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}step']),
      min: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min']),
      def: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}def']),
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json']),
    );
  }

  @override
  $ServiceFieldsTable createAlias(String alias) {
    return $ServiceFieldsTable(attachedDatabase, alias);
  }
}

class DbServiceField extends DataClass implements Insertable<DbServiceField> {
  final int id;
  final String serviceCode;
  final String key;
  final String label;
  final String type;
  final double? step;
  final double? min;
  final double? def;
  final String? optionsJson;
  const DbServiceField(
      {required this.id,
      required this.serviceCode,
      required this.key,
      required this.label,
      required this.type,
      this.step,
      this.min,
      this.def,
      this.optionsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_code'] = Variable<String>(serviceCode);
    map['key'] = Variable<String>(key);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || step != null) {
      map['step'] = Variable<double>(step);
    }
    if (!nullToAbsent || min != null) {
      map['min'] = Variable<double>(min);
    }
    if (!nullToAbsent || def != null) {
      map['def'] = Variable<double>(def);
    }
    if (!nullToAbsent || optionsJson != null) {
      map['options_json'] = Variable<String>(optionsJson);
    }
    return map;
  }

  ServiceFieldsCompanion toCompanion(bool nullToAbsent) {
    return ServiceFieldsCompanion(
      id: Value(id),
      serviceCode: Value(serviceCode),
      key: Value(key),
      label: Value(label),
      type: Value(type),
      step: step == null && nullToAbsent ? const Value.absent() : Value(step),
      min: min == null && nullToAbsent ? const Value.absent() : Value(min),
      def: def == null && nullToAbsent ? const Value.absent() : Value(def),
      optionsJson: optionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(optionsJson),
    );
  }

  factory DbServiceField.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbServiceField(
      id: serializer.fromJson<int>(json['id']),
      serviceCode: serializer.fromJson<String>(json['serviceCode']),
      key: serializer.fromJson<String>(json['key']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
      step: serializer.fromJson<double?>(json['step']),
      min: serializer.fromJson<double?>(json['min']),
      def: serializer.fromJson<double?>(json['def']),
      optionsJson: serializer.fromJson<String?>(json['optionsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceCode': serializer.toJson<String>(serviceCode),
      'key': serializer.toJson<String>(key),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
      'step': serializer.toJson<double?>(step),
      'min': serializer.toJson<double?>(min),
      'def': serializer.toJson<double?>(def),
      'optionsJson': serializer.toJson<String?>(optionsJson),
    };
  }

  DbServiceField copyWith(
          {int? id,
          String? serviceCode,
          String? key,
          String? label,
          String? type,
          Value<double?> step = const Value.absent(),
          Value<double?> min = const Value.absent(),
          Value<double?> def = const Value.absent(),
          Value<String?> optionsJson = const Value.absent()}) =>
      DbServiceField(
        id: id ?? this.id,
        serviceCode: serviceCode ?? this.serviceCode,
        key: key ?? this.key,
        label: label ?? this.label,
        type: type ?? this.type,
        step: step.present ? step.value : this.step,
        min: min.present ? min.value : this.min,
        def: def.present ? def.value : this.def,
        optionsJson: optionsJson.present ? optionsJson.value : this.optionsJson,
      );
  DbServiceField copyWithCompanion(ServiceFieldsCompanion data) {
    return DbServiceField(
      id: data.id.present ? data.id.value : this.id,
      serviceCode:
          data.serviceCode.present ? data.serviceCode.value : this.serviceCode,
      key: data.key.present ? data.key.value : this.key,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      step: data.step.present ? data.step.value : this.step,
      min: data.min.present ? data.min.value : this.min,
      def: data.def.present ? data.def.value : this.def,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbServiceField(')
          ..write('id: $id, ')
          ..write('serviceCode: $serviceCode, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('step: $step, ')
          ..write('min: $min, ')
          ..write('def: $def, ')
          ..write('optionsJson: $optionsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, serviceCode, key, label, type, step, min, def, optionsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbServiceField &&
          other.id == this.id &&
          other.serviceCode == this.serviceCode &&
          other.key == this.key &&
          other.label == this.label &&
          other.type == this.type &&
          other.step == this.step &&
          other.min == this.min &&
          other.def == this.def &&
          other.optionsJson == this.optionsJson);
}

class ServiceFieldsCompanion extends UpdateCompanion<DbServiceField> {
  final Value<int> id;
  final Value<String> serviceCode;
  final Value<String> key;
  final Value<String> label;
  final Value<String> type;
  final Value<double?> step;
  final Value<double?> min;
  final Value<double?> def;
  final Value<String?> optionsJson;
  const ServiceFieldsCompanion({
    this.id = const Value.absent(),
    this.serviceCode = const Value.absent(),
    this.key = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.step = const Value.absent(),
    this.min = const Value.absent(),
    this.def = const Value.absent(),
    this.optionsJson = const Value.absent(),
  });
  ServiceFieldsCompanion.insert({
    this.id = const Value.absent(),
    required String serviceCode,
    required String key,
    required String label,
    required String type,
    this.step = const Value.absent(),
    this.min = const Value.absent(),
    this.def = const Value.absent(),
    this.optionsJson = const Value.absent(),
  })  : serviceCode = Value(serviceCode),
        key = Value(key),
        label = Value(label),
        type = Value(type);
  static Insertable<DbServiceField> custom({
    Expression<int>? id,
    Expression<String>? serviceCode,
    Expression<String>? key,
    Expression<String>? label,
    Expression<String>? type,
    Expression<double>? step,
    Expression<double>? min,
    Expression<double>? def,
    Expression<String>? optionsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceCode != null) 'service_code': serviceCode,
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (step != null) 'step': step,
      if (min != null) 'min': min,
      if (def != null) 'def': def,
      if (optionsJson != null) 'options_json': optionsJson,
    });
  }

  ServiceFieldsCompanion copyWith(
      {Value<int>? id,
      Value<String>? serviceCode,
      Value<String>? key,
      Value<String>? label,
      Value<String>? type,
      Value<double?>? step,
      Value<double?>? min,
      Value<double?>? def,
      Value<String?>? optionsJson}) {
    return ServiceFieldsCompanion(
      id: id ?? this.id,
      serviceCode: serviceCode ?? this.serviceCode,
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      step: step ?? this.step,
      min: min ?? this.min,
      def: def ?? this.def,
      optionsJson: optionsJson ?? this.optionsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceCode.present) {
      map['service_code'] = Variable<String>(serviceCode.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (step.present) {
      map['step'] = Variable<double>(step.value);
    }
    if (min.present) {
      map['min'] = Variable<double>(min.value);
    }
    if (def.present) {
      map['def'] = Variable<double>(def.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceFieldsCompanion(')
          ..write('id: $id, ')
          ..write('serviceCode: $serviceCode, ')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('step: $step, ')
          ..write('min: $min, ')
          ..write('def: $def, ')
          ..write('optionsJson: $optionsJson')
          ..write(')'))
        .toString();
  }
}

class $ServiceRatesTable extends ServiceRates
    with TableInfo<$ServiceRatesTable, DbServiceRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serviceCodeMeta =
      const VerificationMeta('serviceCode');
  @override
  late final GeneratedColumn<String> serviceCode = GeneratedColumn<String>(
      'service_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _regionCodeMeta =
      const VerificationMeta('regionCode');
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
      'region_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateKeyMeta =
      const VerificationMeta('rateKey');
  @override
  late final GeneratedColumn<String> rateKey = GeneratedColumn<String>(
      'rate_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [serviceCode, regionCode, rateKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_rates';
  @override
  VerificationContext validateIntegrity(Insertable<DbServiceRate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('service_code')) {
      context.handle(
          _serviceCodeMeta,
          serviceCode.isAcceptableOrUnknown(
              data['service_code']!, _serviceCodeMeta));
    } else if (isInserting) {
      context.missing(_serviceCodeMeta);
    }
    if (data.containsKey('region_code')) {
      context.handle(
          _regionCodeMeta,
          regionCode.isAcceptableOrUnknown(
              data['region_code']!, _regionCodeMeta));
    } else if (isInserting) {
      context.missing(_regionCodeMeta);
    }
    if (data.containsKey('rate_key')) {
      context.handle(_rateKeyMeta,
          rateKey.isAcceptableOrUnknown(data['rate_key']!, _rateKeyMeta));
    } else if (isInserting) {
      context.missing(_rateKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serviceCode, regionCode, rateKey};
  @override
  DbServiceRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbServiceRate(
      serviceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_code'])!,
      regionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region_code'])!,
      rateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $ServiceRatesTable createAlias(String alias) {
    return $ServiceRatesTable(attachedDatabase, alias);
  }
}

class DbServiceRate extends DataClass implements Insertable<DbServiceRate> {
  final String serviceCode;
  final String regionCode;
  final String rateKey;
  final double value;
  const DbServiceRate(
      {required this.serviceCode,
      required this.regionCode,
      required this.rateKey,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['service_code'] = Variable<String>(serviceCode);
    map['region_code'] = Variable<String>(regionCode);
    map['rate_key'] = Variable<String>(rateKey);
    map['value'] = Variable<double>(value);
    return map;
  }

  ServiceRatesCompanion toCompanion(bool nullToAbsent) {
    return ServiceRatesCompanion(
      serviceCode: Value(serviceCode),
      regionCode: Value(regionCode),
      rateKey: Value(rateKey),
      value: Value(value),
    );
  }

  factory DbServiceRate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbServiceRate(
      serviceCode: serializer.fromJson<String>(json['serviceCode']),
      regionCode: serializer.fromJson<String>(json['regionCode']),
      rateKey: serializer.fromJson<String>(json['rateKey']),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serviceCode': serializer.toJson<String>(serviceCode),
      'regionCode': serializer.toJson<String>(regionCode),
      'rateKey': serializer.toJson<String>(rateKey),
      'value': serializer.toJson<double>(value),
    };
  }

  DbServiceRate copyWith(
          {String? serviceCode,
          String? regionCode,
          String? rateKey,
          double? value}) =>
      DbServiceRate(
        serviceCode: serviceCode ?? this.serviceCode,
        regionCode: regionCode ?? this.regionCode,
        rateKey: rateKey ?? this.rateKey,
        value: value ?? this.value,
      );
  DbServiceRate copyWithCompanion(ServiceRatesCompanion data) {
    return DbServiceRate(
      serviceCode:
          data.serviceCode.present ? data.serviceCode.value : this.serviceCode,
      regionCode:
          data.regionCode.present ? data.regionCode.value : this.regionCode,
      rateKey: data.rateKey.present ? data.rateKey.value : this.rateKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbServiceRate(')
          ..write('serviceCode: $serviceCode, ')
          ..write('regionCode: $regionCode, ')
          ..write('rateKey: $rateKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serviceCode, regionCode, rateKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbServiceRate &&
          other.serviceCode == this.serviceCode &&
          other.regionCode == this.regionCode &&
          other.rateKey == this.rateKey &&
          other.value == this.value);
}

class ServiceRatesCompanion extends UpdateCompanion<DbServiceRate> {
  final Value<String> serviceCode;
  final Value<String> regionCode;
  final Value<String> rateKey;
  final Value<double> value;
  final Value<int> rowid;
  const ServiceRatesCompanion({
    this.serviceCode = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.rateKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceRatesCompanion.insert({
    required String serviceCode,
    required String regionCode,
    required String rateKey,
    required double value,
    this.rowid = const Value.absent(),
  })  : serviceCode = Value(serviceCode),
        regionCode = Value(regionCode),
        rateKey = Value(rateKey),
        value = Value(value);
  static Insertable<DbServiceRate> custom({
    Expression<String>? serviceCode,
    Expression<String>? regionCode,
    Expression<String>? rateKey,
    Expression<double>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serviceCode != null) 'service_code': serviceCode,
      if (regionCode != null) 'region_code': regionCode,
      if (rateKey != null) 'rate_key': rateKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceRatesCompanion copyWith(
      {Value<String>? serviceCode,
      Value<String>? regionCode,
      Value<String>? rateKey,
      Value<double>? value,
      Value<int>? rowid}) {
    return ServiceRatesCompanion(
      serviceCode: serviceCode ?? this.serviceCode,
      regionCode: regionCode ?? this.regionCode,
      rateKey: rateKey ?? this.rateKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serviceCode.present) {
      map['service_code'] = Variable<String>(serviceCode.value);
    }
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (rateKey.present) {
      map['rate_key'] = Variable<String>(rateKey.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRatesCompanion(')
          ..write('serviceCode: $serviceCode, ')
          ..write('regionCode: $regionCode, ')
          ..write('rateKey: $rateKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RateLabelsTable extends RateLabels
    with TableInfo<$RateLabelsTable, DbRateLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _serviceCodeMeta =
      const VerificationMeta('serviceCode');
  @override
  late final GeneratedColumn<String> serviceCode = GeneratedColumn<String>(
      'service_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateKeyMeta =
      const VerificationMeta('rateKey');
  @override
  late final GeneratedColumn<String> rateKey = GeneratedColumn<String>(
      'rate_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [serviceCode, rateKey, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_labels';
  @override
  VerificationContext validateIntegrity(Insertable<DbRateLabel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('service_code')) {
      context.handle(
          _serviceCodeMeta,
          serviceCode.isAcceptableOrUnknown(
              data['service_code']!, _serviceCodeMeta));
    } else if (isInserting) {
      context.missing(_serviceCodeMeta);
    }
    if (data.containsKey('rate_key')) {
      context.handle(_rateKeyMeta,
          rateKey.isAcceptableOrUnknown(data['rate_key']!, _rateKeyMeta));
    } else if (isInserting) {
      context.missing(_rateKeyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {serviceCode, rateKey};
  @override
  DbRateLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRateLabel(
      serviceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_code'])!,
      rateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_key'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
    );
  }

  @override
  $RateLabelsTable createAlias(String alias) {
    return $RateLabelsTable(attachedDatabase, alias);
  }
}

class DbRateLabel extends DataClass implements Insertable<DbRateLabel> {
  final String serviceCode;
  final String rateKey;
  final String label;
  const DbRateLabel(
      {required this.serviceCode, required this.rateKey, required this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['service_code'] = Variable<String>(serviceCode);
    map['rate_key'] = Variable<String>(rateKey);
    map['label'] = Variable<String>(label);
    return map;
  }

  RateLabelsCompanion toCompanion(bool nullToAbsent) {
    return RateLabelsCompanion(
      serviceCode: Value(serviceCode),
      rateKey: Value(rateKey),
      label: Value(label),
    );
  }

  factory DbRateLabel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRateLabel(
      serviceCode: serializer.fromJson<String>(json['serviceCode']),
      rateKey: serializer.fromJson<String>(json['rateKey']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'serviceCode': serializer.toJson<String>(serviceCode),
      'rateKey': serializer.toJson<String>(rateKey),
      'label': serializer.toJson<String>(label),
    };
  }

  DbRateLabel copyWith({String? serviceCode, String? rateKey, String? label}) =>
      DbRateLabel(
        serviceCode: serviceCode ?? this.serviceCode,
        rateKey: rateKey ?? this.rateKey,
        label: label ?? this.label,
      );
  DbRateLabel copyWithCompanion(RateLabelsCompanion data) {
    return DbRateLabel(
      serviceCode:
          data.serviceCode.present ? data.serviceCode.value : this.serviceCode,
      rateKey: data.rateKey.present ? data.rateKey.value : this.rateKey,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRateLabel(')
          ..write('serviceCode: $serviceCode, ')
          ..write('rateKey: $rateKey, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(serviceCode, rateKey, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRateLabel &&
          other.serviceCode == this.serviceCode &&
          other.rateKey == this.rateKey &&
          other.label == this.label);
}

class RateLabelsCompanion extends UpdateCompanion<DbRateLabel> {
  final Value<String> serviceCode;
  final Value<String> rateKey;
  final Value<String> label;
  final Value<int> rowid;
  const RateLabelsCompanion({
    this.serviceCode = const Value.absent(),
    this.rateKey = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RateLabelsCompanion.insert({
    required String serviceCode,
    required String rateKey,
    required String label,
    this.rowid = const Value.absent(),
  })  : serviceCode = Value(serviceCode),
        rateKey = Value(rateKey),
        label = Value(label);
  static Insertable<DbRateLabel> custom({
    Expression<String>? serviceCode,
    Expression<String>? rateKey,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (serviceCode != null) 'service_code': serviceCode,
      if (rateKey != null) 'rate_key': rateKey,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RateLabelsCompanion copyWith(
      {Value<String>? serviceCode,
      Value<String>? rateKey,
      Value<String>? label,
      Value<int>? rowid}) {
    return RateLabelsCompanion(
      serviceCode: serviceCode ?? this.serviceCode,
      rateKey: rateKey ?? this.rateKey,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (serviceCode.present) {
      map['service_code'] = Variable<String>(serviceCode.value);
    }
    if (rateKey.present) {
      map['rate_key'] = Variable<String>(rateKey.value);
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
    return (StringBuffer('RateLabelsCompanion(')
          ..write('serviceCode: $serviceCode, ')
          ..write('rateKey: $rateKey, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $QuoteItemsTable quoteItems = $QuoteItemsTable(this);
  late final $RateOverridesTable rateOverrides = $RateOverridesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  late final $ServiceCategoriesTable serviceCategories =
      $ServiceCategoriesTable(this);
  late final $ServicesTable services = $ServicesTable(this);
  late final $ServiceFieldsTable serviceFields = $ServiceFieldsTable(this);
  late final $ServiceRatesTable serviceRates = $ServiceRatesTable(this);
  late final $RateLabelsTable rateLabels = $RateLabelsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        quotes,
        quoteItems,
        rateOverrides,
        payments,
        appointments,
        serviceCategories,
        services,
        serviceFields,
        serviceRates,
        rateLabels
      ];
}

typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  required String client,
  Value<String?> location,
  required String createdAt,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  Value<String> client,
  Value<String?> location,
  Value<String> createdAt,
});

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, Quote> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuoteItemsTable, List<QuoteItem>>
      _quoteItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.quoteItems,
              aliasName: 'quotes__id__quote_items__quote_id');

  $$QuoteItemsTableProcessedTableManager get quoteItemsRefs {
    final manager = $$QuoteItemsTableTableManager($_db, $_db.quoteItems)
        .filter((f) => f.quoteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quoteItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get client => $composableBuilder(
      column: $table.client, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> quoteItemsRefs(
      Expression<bool> Function($$QuoteItemsTableFilterComposer f) f) {
    final $$QuoteItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quoteItems,
        getReferencedColumn: (t) => t.quoteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuoteItemsTableFilterComposer(
              $db: $db,
              $table: $db.quoteItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get client => $composableBuilder(
      column: $table.client, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get client =>
      $composableBuilder(column: $table.client, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> quoteItemsRefs<T extends Object>(
      Expression<T> Function($$QuoteItemsTableAnnotationComposer a) f) {
    final $$QuoteItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quoteItems,
        getReferencedColumn: (t) => t.quoteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuoteItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.quoteItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuotesTable,
    Quote,
    $$QuotesTableFilterComposer,
    $$QuotesTableOrderingComposer,
    $$QuotesTableAnnotationComposer,
    $$QuotesTableCreateCompanionBuilder,
    $$QuotesTableUpdateCompanionBuilder,
    (Quote, $$QuotesTableReferences),
    Quote,
    PrefetchHooks Function({bool quoteItemsRefs})> {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> client = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
          }) =>
              QuotesCompanion(
            id: id,
            client: client,
            location: location,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String client,
            Value<String?> location = const Value.absent(),
            required String createdAt,
          }) =>
              QuotesCompanion.insert(
            id: id,
            client: client,
            location: location,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$QuotesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({quoteItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (quoteItemsRefs) db.quoteItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quoteItemsRefs)
                    await $_getPrefetchedData<Quote, $QuotesTable, QuoteItem>(
                        currentTable: table,
                        referencedTable:
                            $$QuotesTableReferences._quoteItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuotesTableReferences(db, table, p0)
                                .quoteItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.quoteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$QuotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuotesTable,
    Quote,
    $$QuotesTableFilterComposer,
    $$QuotesTableOrderingComposer,
    $$QuotesTableAnnotationComposer,
    $$QuotesTableCreateCompanionBuilder,
    $$QuotesTableUpdateCompanionBuilder,
    (Quote, $$QuotesTableReferences),
    Quote,
    PrefetchHooks Function({bool quoteItemsRefs})>;
typedef $$QuoteItemsTableCreateCompanionBuilder = QuoteItemsCompanion Function({
  Value<int> id,
  required int quoteId,
  required String uid,
  required String code,
  required String name,
  required double total,
  required String linesJson,
});
typedef $$QuoteItemsTableUpdateCompanionBuilder = QuoteItemsCompanion Function({
  Value<int> id,
  Value<int> quoteId,
  Value<String> uid,
  Value<String> code,
  Value<String> name,
  Value<double> total,
  Value<String> linesJson,
});

final class $$QuoteItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QuoteItemsTable, QuoteItem> {
  $$QuoteItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuotesTable _quoteIdTable(_$AppDatabase db) =>
      db.quotes.createAlias('quote_items__quote_id__quotes__id');

  $$QuotesTableProcessedTableManager get quoteId {
    final $_column = $_itemColumn<int>('quote_id')!;

    final manager = $$QuotesTableTableManager($_db, $_db.quotes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quoteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuoteItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linesJson => $composableBuilder(
      column: $table.linesJson, builder: (column) => ColumnFilters(column));

  $$QuotesTableFilterComposer get quoteId {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quoteId,
        referencedTable: $db.quotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuotesTableFilterComposer(
              $db: $db,
              $table: $db.quotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuoteItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linesJson => $composableBuilder(
      column: $table.linesJson, builder: (column) => ColumnOrderings(column));

  $$QuotesTableOrderingComposer get quoteId {
    final $$QuotesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quoteId,
        referencedTable: $db.quotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuotesTableOrderingComposer(
              $db: $db,
              $table: $db.quotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuoteItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get linesJson =>
      $composableBuilder(column: $table.linesJson, builder: (column) => column);

  $$QuotesTableAnnotationComposer get quoteId {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quoteId,
        referencedTable: $db.quotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuotesTableAnnotationComposer(
              $db: $db,
              $table: $db.quotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuoteItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuoteItemsTable,
    QuoteItem,
    $$QuoteItemsTableFilterComposer,
    $$QuoteItemsTableOrderingComposer,
    $$QuoteItemsTableAnnotationComposer,
    $$QuoteItemsTableCreateCompanionBuilder,
    $$QuoteItemsTableUpdateCompanionBuilder,
    (QuoteItem, $$QuoteItemsTableReferences),
    QuoteItem,
    PrefetchHooks Function({bool quoteId})> {
  $$QuoteItemsTableTableManager(_$AppDatabase db, $QuoteItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuoteItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuoteItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuoteItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> quoteId = const Value.absent(),
            Value<String> uid = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> linesJson = const Value.absent(),
          }) =>
              QuoteItemsCompanion(
            id: id,
            quoteId: quoteId,
            uid: uid,
            code: code,
            name: name,
            total: total,
            linesJson: linesJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int quoteId,
            required String uid,
            required String code,
            required String name,
            required double total,
            required String linesJson,
          }) =>
              QuoteItemsCompanion.insert(
            id: id,
            quoteId: quoteId,
            uid: uid,
            code: code,
            name: name,
            total: total,
            linesJson: linesJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuoteItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({quoteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (quoteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.quoteId,
                    referencedTable:
                        $$QuoteItemsTableReferences._quoteIdTable(db),
                    referencedColumn:
                        $$QuoteItemsTableReferences._quoteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$QuoteItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuoteItemsTable,
    QuoteItem,
    $$QuoteItemsTableFilterComposer,
    $$QuoteItemsTableOrderingComposer,
    $$QuoteItemsTableAnnotationComposer,
    $$QuoteItemsTableCreateCompanionBuilder,
    $$QuoteItemsTableUpdateCompanionBuilder,
    (QuoteItem, $$QuoteItemsTableReferences),
    QuoteItem,
    PrefetchHooks Function({bool quoteId})>;
typedef $$RateOverridesTableCreateCompanionBuilder = RateOverridesCompanion
    Function({
  required String code,
  required String key,
  required double value,
  Value<int> rowid,
});
typedef $$RateOverridesTableUpdateCompanionBuilder = RateOverridesCompanion
    Function({
  Value<String> code,
  Value<String> key,
  Value<double> value,
  Value<int> rowid,
});

class $$RateOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $RateOverridesTable> {
  $$RateOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$RateOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $RateOverridesTable> {
  $$RateOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$RateOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateOverridesTable> {
  $$RateOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$RateOverridesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RateOverridesTable,
    RateOverride,
    $$RateOverridesTableFilterComposer,
    $$RateOverridesTableOrderingComposer,
    $$RateOverridesTableAnnotationComposer,
    $$RateOverridesTableCreateCompanionBuilder,
    $$RateOverridesTableUpdateCompanionBuilder,
    (
      RateOverride,
      BaseReferences<_$AppDatabase, $RateOverridesTable, RateOverride>
    ),
    RateOverride,
    PrefetchHooks Function()> {
  $$RateOverridesTableTableManager(_$AppDatabase db, $RateOverridesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RateOverridesCompanion(
            code: code,
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String key,
            required double value,
            Value<int> rowid = const Value.absent(),
          }) =>
              RateOverridesCompanion.insert(
            code: code,
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RateOverridesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RateOverridesTable,
    RateOverride,
    $$RateOverridesTableFilterComposer,
    $$RateOverridesTableOrderingComposer,
    $$RateOverridesTableAnnotationComposer,
    $$RateOverridesTableCreateCompanionBuilder,
    $$RateOverridesTableUpdateCompanionBuilder,
    (
      RateOverride,
      BaseReferences<_$AppDatabase, $RateOverridesTable, RateOverride>
    ),
    RateOverride,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required String quoteItemUid,
  required String label,
  required double pct,
  Value<String?> dueDate,
  Value<bool> paid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<String> quoteItemUid,
  Value<String> label,
  Value<double> pct,
  Value<String?> dueDate,
  Value<bool> paid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quoteItemUid => $composableBuilder(
      column: $table.quoteItemUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pct => $composableBuilder(
      column: $table.pct, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get paid => $composableBuilder(
      column: $table.paid, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quoteItemUid => $composableBuilder(
      column: $table.quoteItemUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pct => $composableBuilder(
      column: $table.pct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get paid => $composableBuilder(
      column: $table.paid, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quoteItemUid => $composableBuilder(
      column: $table.quoteItemUid, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get pct =>
      $composableBuilder(column: $table.pct, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> quoteItemUid = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<double> pct = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<bool> paid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            quoteItemUid: quoteItemUid,
            label: label,
            pct: pct,
            dueDate: dueDate,
            paid: paid,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String quoteItemUid,
            required String label,
            required double pct,
            Value<String?> dueDate = const Value.absent(),
            Value<bool> paid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            quoteItemUid: quoteItemUid,
            label: label,
            pct: pct,
            dueDate: dueDate,
            paid: paid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
    Payment,
    PrefetchHooks Function()>;
typedef $$AppointmentsTableCreateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<int> id,
  required String title,
  required String date,
  Value<String?> note,
});
typedef $$AppointmentsTableUpdateCompanionBuilder = AppointmentsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> date,
  Value<String?> note,
});

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$AppointmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (
      Appointment,
      BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>
    ),
    Appointment,
    PrefetchHooks Function()> {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              AppointmentsCompanion(
            id: id,
            title: title,
            date: date,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String date,
            Value<String?> note = const Value.absent(),
          }) =>
              AppointmentsCompanion.insert(
            id: id,
            title: title,
            date: date,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppointmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppointmentsTable,
    Appointment,
    $$AppointmentsTableFilterComposer,
    $$AppointmentsTableOrderingComposer,
    $$AppointmentsTableAnnotationComposer,
    $$AppointmentsTableCreateCompanionBuilder,
    $$AppointmentsTableUpdateCompanionBuilder,
    (
      Appointment,
      BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>
    ),
    Appointment,
    PrefetchHooks Function()>;
typedef $$ServiceCategoriesTableCreateCompanionBuilder
    = ServiceCategoriesCompanion Function({
  required String key,
  required String label,
  required String color,
  required String iconName,
  Value<int> rowid,
});
typedef $$ServiceCategoriesTableUpdateCompanionBuilder
    = ServiceCategoriesCompanion Function({
  Value<String> key,
  Value<String> label,
  Value<String> color,
  Value<String> iconName,
  Value<int> rowid,
});

class $$ServiceCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceCategoriesTable> {
  $$ServiceCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));
}

class $$ServiceCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceCategoriesTable> {
  $$ServiceCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));
}

class $$ServiceCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceCategoriesTable> {
  $$ServiceCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);
}

class $$ServiceCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceCategoriesTable,
    DbServiceCategory,
    $$ServiceCategoriesTableFilterComposer,
    $$ServiceCategoriesTableOrderingComposer,
    $$ServiceCategoriesTableAnnotationComposer,
    $$ServiceCategoriesTableCreateCompanionBuilder,
    $$ServiceCategoriesTableUpdateCompanionBuilder,
    (
      DbServiceCategory,
      BaseReferences<_$AppDatabase, $ServiceCategoriesTable, DbServiceCategory>
    ),
    DbServiceCategory,
    PrefetchHooks Function()> {
  $$ServiceCategoriesTableTableManager(
      _$AppDatabase db, $ServiceCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> iconName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceCategoriesCompanion(
            key: key,
            label: label,
            color: color,
            iconName: iconName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String label,
            required String color,
            required String iconName,
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceCategoriesCompanion.insert(
            key: key,
            label: label,
            color: color,
            iconName: iconName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceCategoriesTable,
    DbServiceCategory,
    $$ServiceCategoriesTableFilterComposer,
    $$ServiceCategoriesTableOrderingComposer,
    $$ServiceCategoriesTableAnnotationComposer,
    $$ServiceCategoriesTableCreateCompanionBuilder,
    $$ServiceCategoriesTableUpdateCompanionBuilder,
    (
      DbServiceCategory,
      BaseReferences<_$AppDatabase, $ServiceCategoriesTable, DbServiceCategory>
    ),
    DbServiceCategory,
    PrefetchHooks Function()>;
typedef $$ServicesTableCreateCompanionBuilder = ServicesCompanion Function({
  required String code,
  required String name,
  required String cat,
  Value<String?> group,
  Value<String?> shortDescription,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$ServicesTableUpdateCompanionBuilder = ServicesCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> cat,
  Value<String?> group,
  Value<String?> shortDescription,
  Value<String?> note,
  Value<int> rowid,
});

class $$ServicesTableFilterComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cat => $composableBuilder(
      column: $table.cat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$ServicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cat => $composableBuilder(
      column: $table.cat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$ServicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicesTable> {
  $$ServicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cat =>
      $composableBuilder(column: $table.cat, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ServicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServicesTable,
    DbService,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (DbService, BaseReferences<_$AppDatabase, $ServicesTable, DbService>),
    DbService,
    PrefetchHooks Function()> {
  $$ServicesTableTableManager(_$AppDatabase db, $ServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> cat = const Value.absent(),
            Value<String?> group = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion(
            code: code,
            name: name,
            cat: cat,
            group: group,
            shortDescription: shortDescription,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String name,
            required String cat,
            Value<String?> group = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServicesCompanion.insert(
            code: code,
            name: name,
            cat: cat,
            group: group,
            shortDescription: shortDescription,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServicesTable,
    DbService,
    $$ServicesTableFilterComposer,
    $$ServicesTableOrderingComposer,
    $$ServicesTableAnnotationComposer,
    $$ServicesTableCreateCompanionBuilder,
    $$ServicesTableUpdateCompanionBuilder,
    (DbService, BaseReferences<_$AppDatabase, $ServicesTable, DbService>),
    DbService,
    PrefetchHooks Function()>;
typedef $$ServiceFieldsTableCreateCompanionBuilder = ServiceFieldsCompanion
    Function({
  Value<int> id,
  required String serviceCode,
  required String key,
  required String label,
  required String type,
  Value<double?> step,
  Value<double?> min,
  Value<double?> def,
  Value<String?> optionsJson,
});
typedef $$ServiceFieldsTableUpdateCompanionBuilder = ServiceFieldsCompanion
    Function({
  Value<int> id,
  Value<String> serviceCode,
  Value<String> key,
  Value<String> label,
  Value<String> type,
  Value<double?> step,
  Value<double?> min,
  Value<double?> def,
  Value<String?> optionsJson,
});

class $$ServiceFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceFieldsTable> {
  $$ServiceFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get step => $composableBuilder(
      column: $table.step, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get min => $composableBuilder(
      column: $table.min, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get def => $composableBuilder(
      column: $table.def, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));
}

class $$ServiceFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceFieldsTable> {
  $$ServiceFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get step => $composableBuilder(
      column: $table.step, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get min => $composableBuilder(
      column: $table.min, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get def => $composableBuilder(
      column: $table.def, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));
}

class $$ServiceFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceFieldsTable> {
  $$ServiceFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<double> get min =>
      $composableBuilder(column: $table.min, builder: (column) => column);

  GeneratedColumn<double> get def =>
      $composableBuilder(column: $table.def, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);
}

class $$ServiceFieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceFieldsTable,
    DbServiceField,
    $$ServiceFieldsTableFilterComposer,
    $$ServiceFieldsTableOrderingComposer,
    $$ServiceFieldsTableAnnotationComposer,
    $$ServiceFieldsTableCreateCompanionBuilder,
    $$ServiceFieldsTableUpdateCompanionBuilder,
    (
      DbServiceField,
      BaseReferences<_$AppDatabase, $ServiceFieldsTable, DbServiceField>
    ),
    DbServiceField,
    PrefetchHooks Function()> {
  $$ServiceFieldsTableTableManager(_$AppDatabase db, $ServiceFieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> serviceCode = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double?> step = const Value.absent(),
            Value<double?> min = const Value.absent(),
            Value<double?> def = const Value.absent(),
            Value<String?> optionsJson = const Value.absent(),
          }) =>
              ServiceFieldsCompanion(
            id: id,
            serviceCode: serviceCode,
            key: key,
            label: label,
            type: type,
            step: step,
            min: min,
            def: def,
            optionsJson: optionsJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String serviceCode,
            required String key,
            required String label,
            required String type,
            Value<double?> step = const Value.absent(),
            Value<double?> min = const Value.absent(),
            Value<double?> def = const Value.absent(),
            Value<String?> optionsJson = const Value.absent(),
          }) =>
              ServiceFieldsCompanion.insert(
            id: id,
            serviceCode: serviceCode,
            key: key,
            label: label,
            type: type,
            step: step,
            min: min,
            def: def,
            optionsJson: optionsJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceFieldsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceFieldsTable,
    DbServiceField,
    $$ServiceFieldsTableFilterComposer,
    $$ServiceFieldsTableOrderingComposer,
    $$ServiceFieldsTableAnnotationComposer,
    $$ServiceFieldsTableCreateCompanionBuilder,
    $$ServiceFieldsTableUpdateCompanionBuilder,
    (
      DbServiceField,
      BaseReferences<_$AppDatabase, $ServiceFieldsTable, DbServiceField>
    ),
    DbServiceField,
    PrefetchHooks Function()>;
typedef $$ServiceRatesTableCreateCompanionBuilder = ServiceRatesCompanion
    Function({
  required String serviceCode,
  required String regionCode,
  required String rateKey,
  required double value,
  Value<int> rowid,
});
typedef $$ServiceRatesTableUpdateCompanionBuilder = ServiceRatesCompanion
    Function({
  Value<String> serviceCode,
  Value<String> regionCode,
  Value<String> rateKey,
  Value<double> value,
  Value<int> rowid,
});

class $$ServiceRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceRatesTable> {
  $$ServiceRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateKey => $composableBuilder(
      column: $table.rateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$ServiceRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceRatesTable> {
  $$ServiceRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateKey => $composableBuilder(
      column: $table.rateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$ServiceRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceRatesTable> {
  $$ServiceRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => column);

  GeneratedColumn<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => column);

  GeneratedColumn<String> get rateKey =>
      $composableBuilder(column: $table.rateKey, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ServiceRatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceRatesTable,
    DbServiceRate,
    $$ServiceRatesTableFilterComposer,
    $$ServiceRatesTableOrderingComposer,
    $$ServiceRatesTableAnnotationComposer,
    $$ServiceRatesTableCreateCompanionBuilder,
    $$ServiceRatesTableUpdateCompanionBuilder,
    (
      DbServiceRate,
      BaseReferences<_$AppDatabase, $ServiceRatesTable, DbServiceRate>
    ),
    DbServiceRate,
    PrefetchHooks Function()> {
  $$ServiceRatesTableTableManager(_$AppDatabase db, $ServiceRatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> serviceCode = const Value.absent(),
            Value<String> regionCode = const Value.absent(),
            Value<String> rateKey = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceRatesCompanion(
            serviceCode: serviceCode,
            regionCode: regionCode,
            rateKey: rateKey,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String serviceCode,
            required String regionCode,
            required String rateKey,
            required double value,
            Value<int> rowid = const Value.absent(),
          }) =>
              ServiceRatesCompanion.insert(
            serviceCode: serviceCode,
            regionCode: regionCode,
            rateKey: rateKey,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceRatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceRatesTable,
    DbServiceRate,
    $$ServiceRatesTableFilterComposer,
    $$ServiceRatesTableOrderingComposer,
    $$ServiceRatesTableAnnotationComposer,
    $$ServiceRatesTableCreateCompanionBuilder,
    $$ServiceRatesTableUpdateCompanionBuilder,
    (
      DbServiceRate,
      BaseReferences<_$AppDatabase, $ServiceRatesTable, DbServiceRate>
    ),
    DbServiceRate,
    PrefetchHooks Function()>;
typedef $$RateLabelsTableCreateCompanionBuilder = RateLabelsCompanion Function({
  required String serviceCode,
  required String rateKey,
  required String label,
  Value<int> rowid,
});
typedef $$RateLabelsTableUpdateCompanionBuilder = RateLabelsCompanion Function({
  Value<String> serviceCode,
  Value<String> rateKey,
  Value<String> label,
  Value<int> rowid,
});

class $$RateLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $RateLabelsTable> {
  $$RateLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateKey => $composableBuilder(
      column: $table.rateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));
}

class $$RateLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $RateLabelsTable> {
  $$RateLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateKey => $composableBuilder(
      column: $table.rateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));
}

class $$RateLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateLabelsTable> {
  $$RateLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get serviceCode => $composableBuilder(
      column: $table.serviceCode, builder: (column) => column);

  GeneratedColumn<String> get rateKey =>
      $composableBuilder(column: $table.rateKey, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$RateLabelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RateLabelsTable,
    DbRateLabel,
    $$RateLabelsTableFilterComposer,
    $$RateLabelsTableOrderingComposer,
    $$RateLabelsTableAnnotationComposer,
    $$RateLabelsTableCreateCompanionBuilder,
    $$RateLabelsTableUpdateCompanionBuilder,
    (DbRateLabel, BaseReferences<_$AppDatabase, $RateLabelsTable, DbRateLabel>),
    DbRateLabel,
    PrefetchHooks Function()> {
  $$RateLabelsTableTableManager(_$AppDatabase db, $RateLabelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> serviceCode = const Value.absent(),
            Value<String> rateKey = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RateLabelsCompanion(
            serviceCode: serviceCode,
            rateKey: rateKey,
            label: label,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String serviceCode,
            required String rateKey,
            required String label,
            Value<int> rowid = const Value.absent(),
          }) =>
              RateLabelsCompanion.insert(
            serviceCode: serviceCode,
            rateKey: rateKey,
            label: label,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RateLabelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RateLabelsTable,
    DbRateLabel,
    $$RateLabelsTableFilterComposer,
    $$RateLabelsTableOrderingComposer,
    $$RateLabelsTableAnnotationComposer,
    $$RateLabelsTableCreateCompanionBuilder,
    $$RateLabelsTableUpdateCompanionBuilder,
    (DbRateLabel, BaseReferences<_$AppDatabase, $RateLabelsTable, DbRateLabel>),
    DbRateLabel,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$QuoteItemsTableTableManager get quoteItems =>
      $$QuoteItemsTableTableManager(_db, _db.quoteItems);
  $$RateOverridesTableTableManager get rateOverrides =>
      $$RateOverridesTableTableManager(_db, _db.rateOverrides);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
  $$ServiceCategoriesTableTableManager get serviceCategories =>
      $$ServiceCategoriesTableTableManager(_db, _db.serviceCategories);
  $$ServicesTableTableManager get services =>
      $$ServicesTableTableManager(_db, _db.services);
  $$ServiceFieldsTableTableManager get serviceFields =>
      $$ServiceFieldsTableTableManager(_db, _db.serviceFields);
  $$ServiceRatesTableTableManager get serviceRates =>
      $$ServiceRatesTableTableManager(_db, _db.serviceRates);
  $$RateLabelsTableTableManager get rateLabels =>
      $$RateLabelsTableTableManager(_db, _db.rateLabels);
}
