import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:service_application_1/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize SQLite for tests.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Database opens and creates all required tables', () async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    final tableNames = result.map((row) => row['name'] as String).toSet();

    expect(
      tableNames,
      containsAll([
        'products',
        'orders',
        'order_items',
        'payments',
        'inventory_movements',
      ]),
    );
  });
}
