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

@DataClassName('DbServiceCategory')
class ServiceCategories extends Table {
  TextColumn get key => text()();
  TextColumn get label => text()();
  TextColumn get color => text()();
  TextColumn get iconName => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('DbService')
class Services extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get cat => text()();
  TextColumn get group => text().nullable()();
  TextColumn get shortDescription => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('DbServiceField')
class ServiceFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceCode => text()();
  TextColumn get key => text()();
  TextColumn get label => text()();
  TextColumn get type => text()();
  RealColumn get step => real().nullable()();
  RealColumn get min => real().nullable()();
  RealColumn get def => real().nullable()();
  TextColumn get optionsJson => text().nullable()();
}

@DataClassName('DbServiceRate')
class ServiceRates extends Table {
  TextColumn get serviceCode => text()();
  TextColumn get regionCode => text()();
  TextColumn get rateKey => text()();
  RealColumn get value => real()();

  @override
  Set<Column> get primaryKey => {serviceCode, regionCode, rateKey};
}

@DataClassName('DbRateLabel')
class RateLabels extends Table {
  TextColumn get serviceCode => text()();
  TextColumn get rateKey => text()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {serviceCode, rateKey};
}
