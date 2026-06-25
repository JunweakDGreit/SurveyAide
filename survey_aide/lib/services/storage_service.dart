import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/app_database.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  late AppDatabase _db;
  late SharedPreferences _prefs;

  static Future<void> init() async {
    _instance._db = AppDatabase();
    _instance._prefs = await SharedPreferences.getInstance();
  }

  AppDatabase get db => _db;
  SharedPreferences get prefs => _prefs;

  Future<List<RateOverride>> getRateOverrides() async {
    return await _db.select(_db.rateOverrides).get();
  }

  Future<void> setRateOverride(String code, String key, double value) async {
    await _db.into(_db.rateOverrides).insert(
      RateOverridesCompanion.insert(code: code, key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteRateOverride(String code, String key) async {
    await (_db.delete(_db.rateOverrides)
      ..where((t) => t.code.equals(code) & t.key.equals(key)))
      .go();
  }

  Future<void> deleteAllRateOverrides() async {
    await _db.delete(_db.rateOverrides).go();
  }

  bool getBool(String key, {bool def = false}) => _prefs.getBool(key) ?? def;
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  String getString(String key, {String def = ''}) => _prefs.getString(key) ?? def;
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  Future<List<Quote>> getQuotes() => _db.select(_db.quotes).get();
  Future<void> insertQuote(QuotesCompanion q) => _db.into(_db.quotes).insert(q);
  Future<void> deleteQuote(int id) => (_db.delete(_db.quotes)..where((t) => t.id.equals(id))).go();

  Future<List<QuoteItem>> getQuoteItems(int quoteId) =>
      (_db.select(_db.quoteItems)..where((t) => t.quoteId.equals(quoteId))).get();
  Future<void> insertQuoteItem(QuoteItemsCompanion q) => _db.into(_db.quoteItems).insert(q);

  Future<List<Payment>> getPayments() => _db.select(_db.payments).get();
  Future<void> insertPayment(PaymentsCompanion p) => _db.into(_db.payments).insert(p);
  Future<void> togglePaymentPaid(int id) async {
    final existing = _db.select(_db.payments)..where((t) => t.id.equals(id));
    final payment = await existing.getSingle();
    await (_db.update(_db.payments)..where((t) => t.id.equals(id)))
        .write(PaymentsCompanion(paid: Value(!payment.paid)));
  }

  Future<List<Appointment>> getAppointments() => _db.select(_db.appointments).get();
  Future<void> insertAppointment(AppointmentsCompanion a) => _db.into(_db.appointments).insert(a);
  Future<void> deleteAppointment(int id) => (_db.delete(_db.appointments)..where((t) => t.id.equals(id))).go();
}
