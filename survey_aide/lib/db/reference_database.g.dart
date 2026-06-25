// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_database.dart';

// ignore_for_file: type=lint
class $RegionsTable extends Regions with TableInfo<$RegionsTable, AdminRegion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [code, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'regions';
  @override
  VerificationContext validateIntegrity(Insertable<AdminRegion> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AdminRegion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminRegion(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $RegionsTable createAlias(String alias) {
    return $RegionsTable(attachedDatabase, alias);
  }
}

class AdminRegion extends DataClass implements Insertable<AdminRegion> {
  final String code;
  final String name;
  final String description;
  const AdminRegion(
      {required this.code, required this.name, required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    return map;
  }

  RegionsCompanion toCompanion(bool nullToAbsent) {
    return RegionsCompanion(
      code: Value(code),
      name: Value(name),
      description: Value(description),
    );
  }

  factory AdminRegion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminRegion(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
    };
  }

  AdminRegion copyWith({String? code, String? name, String? description}) =>
      AdminRegion(
        code: code ?? this.code,
        name: name ?? this.name,
        description: description ?? this.description,
      );
  AdminRegion copyWithCompanion(RegionsCompanion data) {
    return AdminRegion(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminRegion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminRegion &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description);
}

class RegionsCompanion extends UpdateCompanion<AdminRegion> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> description;
  final Value<int> rowid;
  const RegionsCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegionsCompanion.insert({
    required String code,
    required String name,
    required String description,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        description = Value(description);
  static Insertable<AdminRegion> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegionsCompanion copyWith(
      {Value<String>? code,
      Value<String>? name,
      Value<String>? description,
      Value<int>? rowid}) {
    return RegionsCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionsCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProvincesTable extends Provinces
    with TableInfo<$ProvincesTable, AdminProvince> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvincesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _regionCodeMeta =
      const VerificationMeta('regionCode');
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
      'region_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns => [regionCode, code, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provinces';
  @override
  VerificationContext validateIntegrity(Insertable<AdminProvince> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('region_code')) {
      context.handle(
          _regionCodeMeta,
          regionCode.isAcceptableOrUnknown(
              data['region_code']!, _regionCodeMeta));
    } else if (isInserting) {
      context.missing(_regionCodeMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AdminProvince map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminProvince(
      regionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region_code'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ProvincesTable createAlias(String alias) {
    return $ProvincesTable(attachedDatabase, alias);
  }
}

class AdminProvince extends DataClass implements Insertable<AdminProvince> {
  final String regionCode;
  final String code;
  final String name;
  const AdminProvince(
      {required this.regionCode, required this.code, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['region_code'] = Variable<String>(regionCode);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    return map;
  }

  ProvincesCompanion toCompanion(bool nullToAbsent) {
    return ProvincesCompanion(
      regionCode: Value(regionCode),
      code: Value(code),
      name: Value(name),
    );
  }

  factory AdminProvince.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminProvince(
      regionCode: serializer.fromJson<String>(json['regionCode']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'regionCode': serializer.toJson<String>(regionCode),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
    };
  }

  AdminProvince copyWith({String? regionCode, String? code, String? name}) =>
      AdminProvince(
        regionCode: regionCode ?? this.regionCode,
        code: code ?? this.code,
        name: name ?? this.name,
      );
  AdminProvince copyWithCompanion(ProvincesCompanion data) {
    return AdminProvince(
      regionCode:
          data.regionCode.present ? data.regionCode.value : this.regionCode,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminProvince(')
          ..write('regionCode: $regionCode, ')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(regionCode, code, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminProvince &&
          other.regionCode == this.regionCode &&
          other.code == this.code &&
          other.name == this.name);
}

class ProvincesCompanion extends UpdateCompanion<AdminProvince> {
  final Value<String> regionCode;
  final Value<String> code;
  final Value<String> name;
  final Value<int> rowid;
  const ProvincesCompanion({
    this.regionCode = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvincesCompanion.insert({
    required String regionCode,
    required String code,
    required String name,
    this.rowid = const Value.absent(),
  })  : regionCode = Value(regionCode),
        code = Value(code),
        name = Value(name);
  static Insertable<AdminProvince> custom({
    Expression<String>? regionCode,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (regionCode != null) 'region_code': regionCode,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvincesCompanion copyWith(
      {Value<String>? regionCode,
      Value<String>? code,
      Value<String>? name,
      Value<int>? rowid}) {
    return ProvincesCompanion(
      regionCode: regionCode ?? this.regionCode,
      code: code ?? this.code,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvincesCompanion(')
          ..write('regionCode: $regionCode, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MunicipalitiesTable extends Municipalities
    with TableInfo<$MunicipalitiesTable, AdminMunicipality> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MunicipalitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _provinceCodeMeta =
      const VerificationMeta('provinceCode');
  @override
  late final GeneratedColumn<String> provinceCode = GeneratedColumn<String>(
      'province_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _cityClassMeta =
      const VerificationMeta('cityClass');
  @override
  late final GeneratedColumn<String> cityClass = GeneratedColumn<String>(
      'city_class', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [provinceCode, code, name, cityClass];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'municipalities';
  @override
  VerificationContext validateIntegrity(Insertable<AdminMunicipality> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('province_code')) {
      context.handle(
          _provinceCodeMeta,
          provinceCode.isAcceptableOrUnknown(
              data['province_code']!, _provinceCodeMeta));
    } else if (isInserting) {
      context.missing(_provinceCodeMeta);
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
    if (data.containsKey('city_class')) {
      context.handle(_cityClassMeta,
          cityClass.isAcceptableOrUnknown(data['city_class']!, _cityClassMeta));
    } else if (isInserting) {
      context.missing(_cityClassMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AdminMunicipality map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminMunicipality(
      provinceCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province_code'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cityClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_class'])!,
    );
  }

  @override
  $MunicipalitiesTable createAlias(String alias) {
    return $MunicipalitiesTable(attachedDatabase, alias);
  }
}

class AdminMunicipality extends DataClass
    implements Insertable<AdminMunicipality> {
  final String provinceCode;
  final String code;
  final String name;
  final String cityClass;
  const AdminMunicipality(
      {required this.provinceCode,
      required this.code,
      required this.name,
      required this.cityClass});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['province_code'] = Variable<String>(provinceCode);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['city_class'] = Variable<String>(cityClass);
    return map;
  }

  MunicipalitiesCompanion toCompanion(bool nullToAbsent) {
    return MunicipalitiesCompanion(
      provinceCode: Value(provinceCode),
      code: Value(code),
      name: Value(name),
      cityClass: Value(cityClass),
    );
  }

  factory AdminMunicipality.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminMunicipality(
      provinceCode: serializer.fromJson<String>(json['provinceCode']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      cityClass: serializer.fromJson<String>(json['cityClass']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provinceCode': serializer.toJson<String>(provinceCode),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'cityClass': serializer.toJson<String>(cityClass),
    };
  }

  AdminMunicipality copyWith(
          {String? provinceCode,
          String? code,
          String? name,
          String? cityClass}) =>
      AdminMunicipality(
        provinceCode: provinceCode ?? this.provinceCode,
        code: code ?? this.code,
        name: name ?? this.name,
        cityClass: cityClass ?? this.cityClass,
      );
  AdminMunicipality copyWithCompanion(MunicipalitiesCompanion data) {
    return AdminMunicipality(
      provinceCode: data.provinceCode.present
          ? data.provinceCode.value
          : this.provinceCode,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      cityClass: data.cityClass.present ? data.cityClass.value : this.cityClass,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminMunicipality(')
          ..write('provinceCode: $provinceCode, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('cityClass: $cityClass')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(provinceCode, code, name, cityClass);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminMunicipality &&
          other.provinceCode == this.provinceCode &&
          other.code == this.code &&
          other.name == this.name &&
          other.cityClass == this.cityClass);
}

class MunicipalitiesCompanion extends UpdateCompanion<AdminMunicipality> {
  final Value<String> provinceCode;
  final Value<String> code;
  final Value<String> name;
  final Value<String> cityClass;
  final Value<int> rowid;
  const MunicipalitiesCompanion({
    this.provinceCode = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.cityClass = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MunicipalitiesCompanion.insert({
    required String provinceCode,
    required String code,
    required String name,
    required String cityClass,
    this.rowid = const Value.absent(),
  })  : provinceCode = Value(provinceCode),
        code = Value(code),
        name = Value(name),
        cityClass = Value(cityClass);
  static Insertable<AdminMunicipality> custom({
    Expression<String>? provinceCode,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? cityClass,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provinceCode != null) 'province_code': provinceCode,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (cityClass != null) 'city_class': cityClass,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MunicipalitiesCompanion copyWith(
      {Value<String>? provinceCode,
      Value<String>? code,
      Value<String>? name,
      Value<String>? cityClass,
      Value<int>? rowid}) {
    return MunicipalitiesCompanion(
      provinceCode: provinceCode ?? this.provinceCode,
      code: code ?? this.code,
      name: name ?? this.name,
      cityClass: cityClass ?? this.cityClass,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provinceCode.present) {
      map['province_code'] = Variable<String>(provinceCode.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cityClass.present) {
      map['city_class'] = Variable<String>(cityClass.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MunicipalitiesCompanion(')
          ..write('provinceCode: $provinceCode, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('cityClass: $cityClass, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BarangaysTable extends Barangays
    with TableInfo<$BarangaysTable, AdminBarangay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarangaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _municipalityCodeMeta =
      const VerificationMeta('municipalityCode');
  @override
  late final GeneratedColumn<String> municipalityCode = GeneratedColumn<String>(
      'municipality_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns => [municipalityCode, code, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barangays';
  @override
  VerificationContext validateIntegrity(Insertable<AdminBarangay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('municipality_code')) {
      context.handle(
          _municipalityCodeMeta,
          municipalityCode.isAcceptableOrUnknown(
              data['municipality_code']!, _municipalityCodeMeta));
    } else if (isInserting) {
      context.missing(_municipalityCodeMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  AdminBarangay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminBarangay(
      municipalityCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}municipality_code'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $BarangaysTable createAlias(String alias) {
    return $BarangaysTable(attachedDatabase, alias);
  }
}

class AdminBarangay extends DataClass implements Insertable<AdminBarangay> {
  final String municipalityCode;
  final String code;
  final String name;
  const AdminBarangay(
      {required this.municipalityCode, required this.code, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['municipality_code'] = Variable<String>(municipalityCode);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    return map;
  }

  BarangaysCompanion toCompanion(bool nullToAbsent) {
    return BarangaysCompanion(
      municipalityCode: Value(municipalityCode),
      code: Value(code),
      name: Value(name),
    );
  }

  factory AdminBarangay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminBarangay(
      municipalityCode: serializer.fromJson<String>(json['municipalityCode']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'municipalityCode': serializer.toJson<String>(municipalityCode),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
    };
  }

  AdminBarangay copyWith(
          {String? municipalityCode, String? code, String? name}) =>
      AdminBarangay(
        municipalityCode: municipalityCode ?? this.municipalityCode,
        code: code ?? this.code,
        name: name ?? this.name,
      );
  AdminBarangay copyWithCompanion(BarangaysCompanion data) {
    return AdminBarangay(
      municipalityCode: data.municipalityCode.present
          ? data.municipalityCode.value
          : this.municipalityCode,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminBarangay(')
          ..write('municipalityCode: $municipalityCode, ')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(municipalityCode, code, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminBarangay &&
          other.municipalityCode == this.municipalityCode &&
          other.code == this.code &&
          other.name == this.name);
}

class BarangaysCompanion extends UpdateCompanion<AdminBarangay> {
  final Value<String> municipalityCode;
  final Value<String> code;
  final Value<String> name;
  final Value<int> rowid;
  const BarangaysCompanion({
    this.municipalityCode = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarangaysCompanion.insert({
    required String municipalityCode,
    required String code,
    required String name,
    this.rowid = const Value.absent(),
  })  : municipalityCode = Value(municipalityCode),
        code = Value(code),
        name = Value(name);
  static Insertable<AdminBarangay> custom({
    Expression<String>? municipalityCode,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (municipalityCode != null) 'municipality_code': municipalityCode,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarangaysCompanion copyWith(
      {Value<String>? municipalityCode,
      Value<String>? code,
      Value<String>? name,
      Value<int>? rowid}) {
    return BarangaysCompanion(
      municipalityCode: municipalityCode ?? this.municipalityCode,
      code: code ?? this.code,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (municipalityCode.present) {
      map['municipality_code'] = Variable<String>(municipalityCode.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarangaysCompanion(')
          ..write('municipalityCode: $municipalityCode, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ReferenceDatabase extends GeneratedDatabase {
  _$ReferenceDatabase(QueryExecutor e) : super(e);
  $ReferenceDatabaseManager get managers => $ReferenceDatabaseManager(this);
  late final $RegionsTable regions = $RegionsTable(this);
  late final $ProvincesTable provinces = $ProvincesTable(this);
  late final $MunicipalitiesTable municipalities = $MunicipalitiesTable(this);
  late final $BarangaysTable barangays = $BarangaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [regions, provinces, municipalities, barangays];
}

typedef $$RegionsTableCreateCompanionBuilder = RegionsCompanion Function({
  required String code,
  required String name,
  required String description,
  Value<int> rowid,
});
typedef $$RegionsTableUpdateCompanionBuilder = RegionsCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> description,
  Value<int> rowid,
});

class $$RegionsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $RegionsTable> {
  $$RegionsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$RegionsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $RegionsTable> {
  $$RegionsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$RegionsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $RegionsTable> {
  $$RegionsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$RegionsTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $RegionsTable,
    AdminRegion,
    $$RegionsTableFilterComposer,
    $$RegionsTableOrderingComposer,
    $$RegionsTableAnnotationComposer,
    $$RegionsTableCreateCompanionBuilder,
    $$RegionsTableUpdateCompanionBuilder,
    (
      AdminRegion,
      BaseReferences<_$ReferenceDatabase, $RegionsTable, AdminRegion>
    ),
    AdminRegion,
    PrefetchHooks Function()> {
  $$RegionsTableTableManager(_$ReferenceDatabase db, $RegionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegionsCompanion(
            code: code,
            name: name,
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String name,
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              RegionsCompanion.insert(
            code: code,
            name: name,
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RegionsTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $RegionsTable,
    AdminRegion,
    $$RegionsTableFilterComposer,
    $$RegionsTableOrderingComposer,
    $$RegionsTableAnnotationComposer,
    $$RegionsTableCreateCompanionBuilder,
    $$RegionsTableUpdateCompanionBuilder,
    (
      AdminRegion,
      BaseReferences<_$ReferenceDatabase, $RegionsTable, AdminRegion>
    ),
    AdminRegion,
    PrefetchHooks Function()>;
typedef $$ProvincesTableCreateCompanionBuilder = ProvincesCompanion Function({
  required String regionCode,
  required String code,
  required String name,
  Value<int> rowid,
});
typedef $$ProvincesTableUpdateCompanionBuilder = ProvincesCompanion Function({
  Value<String> regionCode,
  Value<String> code,
  Value<String> name,
  Value<int> rowid,
});

class $$ProvincesTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ProvincesTable> {
  $$ProvincesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$ProvincesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ProvincesTable> {
  $$ProvincesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$ProvincesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ProvincesTable> {
  $$ProvincesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ProvincesTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $ProvincesTable,
    AdminProvince,
    $$ProvincesTableFilterComposer,
    $$ProvincesTableOrderingComposer,
    $$ProvincesTableAnnotationComposer,
    $$ProvincesTableCreateCompanionBuilder,
    $$ProvincesTableUpdateCompanionBuilder,
    (
      AdminProvince,
      BaseReferences<_$ReferenceDatabase, $ProvincesTable, AdminProvince>
    ),
    AdminProvince,
    PrefetchHooks Function()> {
  $$ProvincesTableTableManager(_$ReferenceDatabase db, $ProvincesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvincesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvincesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvincesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> regionCode = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvincesCompanion(
            regionCode: regionCode,
            code: code,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String regionCode,
            required String code,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProvincesCompanion.insert(
            regionCode: regionCode,
            code: code,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProvincesTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $ProvincesTable,
    AdminProvince,
    $$ProvincesTableFilterComposer,
    $$ProvincesTableOrderingComposer,
    $$ProvincesTableAnnotationComposer,
    $$ProvincesTableCreateCompanionBuilder,
    $$ProvincesTableUpdateCompanionBuilder,
    (
      AdminProvince,
      BaseReferences<_$ReferenceDatabase, $ProvincesTable, AdminProvince>
    ),
    AdminProvince,
    PrefetchHooks Function()>;
typedef $$MunicipalitiesTableCreateCompanionBuilder = MunicipalitiesCompanion
    Function({
  required String provinceCode,
  required String code,
  required String name,
  required String cityClass,
  Value<int> rowid,
});
typedef $$MunicipalitiesTableUpdateCompanionBuilder = MunicipalitiesCompanion
    Function({
  Value<String> provinceCode,
  Value<String> code,
  Value<String> name,
  Value<String> cityClass,
  Value<int> rowid,
});

class $$MunicipalitiesTableFilterComposer
    extends Composer<_$ReferenceDatabase, $MunicipalitiesTable> {
  $$MunicipalitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provinceCode => $composableBuilder(
      column: $table.provinceCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cityClass => $composableBuilder(
      column: $table.cityClass, builder: (column) => ColumnFilters(column));
}

class $$MunicipalitiesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $MunicipalitiesTable> {
  $$MunicipalitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provinceCode => $composableBuilder(
      column: $table.provinceCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cityClass => $composableBuilder(
      column: $table.cityClass, builder: (column) => ColumnOrderings(column));
}

class $$MunicipalitiesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $MunicipalitiesTable> {
  $$MunicipalitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provinceCode => $composableBuilder(
      column: $table.provinceCode, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cityClass =>
      $composableBuilder(column: $table.cityClass, builder: (column) => column);
}

class $$MunicipalitiesTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $MunicipalitiesTable,
    AdminMunicipality,
    $$MunicipalitiesTableFilterComposer,
    $$MunicipalitiesTableOrderingComposer,
    $$MunicipalitiesTableAnnotationComposer,
    $$MunicipalitiesTableCreateCompanionBuilder,
    $$MunicipalitiesTableUpdateCompanionBuilder,
    (
      AdminMunicipality,
      BaseReferences<_$ReferenceDatabase, $MunicipalitiesTable,
          AdminMunicipality>
    ),
    AdminMunicipality,
    PrefetchHooks Function()> {
  $$MunicipalitiesTableTableManager(
      _$ReferenceDatabase db, $MunicipalitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MunicipalitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MunicipalitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MunicipalitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> provinceCode = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> cityClass = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MunicipalitiesCompanion(
            provinceCode: provinceCode,
            code: code,
            name: name,
            cityClass: cityClass,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String provinceCode,
            required String code,
            required String name,
            required String cityClass,
            Value<int> rowid = const Value.absent(),
          }) =>
              MunicipalitiesCompanion.insert(
            provinceCode: provinceCode,
            code: code,
            name: name,
            cityClass: cityClass,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MunicipalitiesTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $MunicipalitiesTable,
    AdminMunicipality,
    $$MunicipalitiesTableFilterComposer,
    $$MunicipalitiesTableOrderingComposer,
    $$MunicipalitiesTableAnnotationComposer,
    $$MunicipalitiesTableCreateCompanionBuilder,
    $$MunicipalitiesTableUpdateCompanionBuilder,
    (
      AdminMunicipality,
      BaseReferences<_$ReferenceDatabase, $MunicipalitiesTable,
          AdminMunicipality>
    ),
    AdminMunicipality,
    PrefetchHooks Function()>;
typedef $$BarangaysTableCreateCompanionBuilder = BarangaysCompanion Function({
  required String municipalityCode,
  required String code,
  required String name,
  Value<int> rowid,
});
typedef $$BarangaysTableUpdateCompanionBuilder = BarangaysCompanion Function({
  Value<String> municipalityCode,
  Value<String> code,
  Value<String> name,
  Value<int> rowid,
});

class $$BarangaysTableFilterComposer
    extends Composer<_$ReferenceDatabase, $BarangaysTable> {
  $$BarangaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get municipalityCode => $composableBuilder(
      column: $table.municipalityCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$BarangaysTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $BarangaysTable> {
  $$BarangaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get municipalityCode => $composableBuilder(
      column: $table.municipalityCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$BarangaysTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $BarangaysTable> {
  $$BarangaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get municipalityCode => $composableBuilder(
      column: $table.municipalityCode, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$BarangaysTableTableManager extends RootTableManager<
    _$ReferenceDatabase,
    $BarangaysTable,
    AdminBarangay,
    $$BarangaysTableFilterComposer,
    $$BarangaysTableOrderingComposer,
    $$BarangaysTableAnnotationComposer,
    $$BarangaysTableCreateCompanionBuilder,
    $$BarangaysTableUpdateCompanionBuilder,
    (
      AdminBarangay,
      BaseReferences<_$ReferenceDatabase, $BarangaysTable, AdminBarangay>
    ),
    AdminBarangay,
    PrefetchHooks Function()> {
  $$BarangaysTableTableManager(_$ReferenceDatabase db, $BarangaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarangaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarangaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarangaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> municipalityCode = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BarangaysCompanion(
            municipalityCode: municipalityCode,
            code: code,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String municipalityCode,
            required String code,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              BarangaysCompanion.insert(
            municipalityCode: municipalityCode,
            code: code,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BarangaysTableProcessedTableManager = ProcessedTableManager<
    _$ReferenceDatabase,
    $BarangaysTable,
    AdminBarangay,
    $$BarangaysTableFilterComposer,
    $$BarangaysTableOrderingComposer,
    $$BarangaysTableAnnotationComposer,
    $$BarangaysTableCreateCompanionBuilder,
    $$BarangaysTableUpdateCompanionBuilder,
    (
      AdminBarangay,
      BaseReferences<_$ReferenceDatabase, $BarangaysTable, AdminBarangay>
    ),
    AdminBarangay,
    PrefetchHooks Function()>;

class $ReferenceDatabaseManager {
  final _$ReferenceDatabase _db;
  $ReferenceDatabaseManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db, _db.regions);
  $$ProvincesTableTableManager get provinces =>
      $$ProvincesTableTableManager(_db, _db.provinces);
  $$MunicipalitiesTableTableManager get municipalities =>
      $$MunicipalitiesTableTableManager(_db, _db.municipalities);
  $$BarangaysTableTableManager get barangays =>
      $$BarangaysTableTableManager(_db, _db.barangays);
}
