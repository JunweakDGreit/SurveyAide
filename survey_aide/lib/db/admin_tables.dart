import 'package:drift/drift.dart';

@DataClassName('AdminRegion')
class Regions extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('AdminProvince')
class Provinces extends Table {
  TextColumn get regionCode => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('AdminMunicipality')
class Municipalities extends Table {
  TextColumn get provinceCode => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get cityClass => text()();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('AdminBarangay')
class Barangays extends Table {
  TextColumn get municipalityCode => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {code};
}
