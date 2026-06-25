import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'admin_tables.dart';

part 'reference_database.g.dart';

@DriftDatabase(tables: [Regions, Provinces, Municipalities, Barangays])
class ReferenceDatabase extends _$ReferenceDatabase {
  ReferenceDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {},
    onUpgrade: (m, from, to) async {},
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'reference.db'));

    if (!dbFile.existsSync()) {
      final data = await rootBundle.load('assets/database/reference.db');
      await dbFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    return NativeDatabase(dbFile);
  });
}
