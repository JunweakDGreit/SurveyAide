import 'package:drift/drift.dart';

@DataClassName('Quote')
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get client => text()();
  TextColumn get location => text().nullable()();
  TextColumn get createdAt => text()();
}

@DataClassName('QuoteItem')
class QuoteItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get quoteId => integer().references(Quotes, #id)();
  TextColumn get uid => text().unique()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  RealColumn get total => real()();
  TextColumn get linesJson => text()();
}

@DataClassName('RateOverride')
class RateOverrides extends Table {
  TextColumn get code => text()();
  TextColumn get key => text()();
  RealColumn get value => real()();

  @override
  Set<Column> get primaryKey => {code, key};
}

@DataClassName('Payment')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get quoteItemUid => text()();
  TextColumn get label => text()();
  RealColumn get pct => real()();
  TextColumn get dueDate => text().nullable()();
  BoolColumn get paid => boolean().withDefault(const Constant(false))();
}

@DataClassName('Appointment')
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get date => text()();
  TextColumn get note => text().nullable()();
}
