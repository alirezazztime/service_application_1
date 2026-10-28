import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // Initialize SQLite for Windows.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = '$dbPath/store.db';

    _database = await openDatabase(
      path,
      version: 2,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sale_price INTEGER NOT NULL CHECK(sale_price >= 0),
            purchase_price INTEGER DEFAULT NULL
              CHECK(purchase_price IS NULL OR purchase_price >= 0),
            stock_type TEXT NOT NULL DEFAULT 'quantity'
              CHECK(stock_type IN ('quantity', 'unlimited')),
            stock_quantity INTEGER NOT NULL DEFAULT 0
              CHECK(stock_quantity >= 0),
            image_path TEXT,
            is_active INTEGER NOT NULL DEFAULT 1
              CHECK(is_active IN (0, 1)),
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_number TEXT NOT NULL UNIQUE,
            status TEXT NOT NULL DEFAULT 'pending'
              CHECK(status IN ('pending', 'delivered', 'cancelled')),
            total_amount INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            delivered_at TEXT,
            cancelled_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL CHECK(quantity > 0),
            sale_price INTEGER NOT NULL CHECK(sale_price >= 0),
            purchase_price INTEGER DEFAULT NULL
              CHECK(purchase_price IS NULL OR purchase_price >= 0),
            FOREIGN KEY (order_id)
              REFERENCES orders(id) ON DELETE RESTRICT,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            amount INTEGER NOT NULL CHECK(amount > 0),
            payment_method TEXT NOT NULL DEFAULT 'cash',
            paid_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (order_id)
              REFERENCES orders(id) ON DELETE RESTRICT
          )
        ''');

        await db.execute('''
          CREATE TABLE inventory_movements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            order_id INTEGER,
            change_quantity INTEGER NOT NULL,
            reason TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id)
              REFERENCES products(id) ON DELETE RESTRICT,
            FOREIGN KEY (order_id)
              REFERENCES orders(id) ON DELETE RESTRICT
          )
        ''');

        await _createIndexes(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Preserve existing product data while allowing NULL purchase prices.
          await db.execute('''
            CREATE TABLE products_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              sale_price INTEGER NOT NULL CHECK(sale_price >= 0),
              purchase_price INTEGER DEFAULT NULL
                CHECK(purchase_price IS NULL OR purchase_price >= 0),
              stock_type TEXT NOT NULL DEFAULT 'quantity'
                CHECK(stock_type IN ('quantity', 'unlimited')),
              stock_quantity INTEGER NOT NULL DEFAULT 0
                CHECK(stock_quantity >= 0),
              image_path TEXT,
              is_active INTEGER NOT NULL DEFAULT 1
                CHECK(is_active IN (0, 1)),
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            )
          ''');

          await db.execute('''
            INSERT INTO products_new (
              id,
              name,
              sale_price,
              purchase_price,
              stock_type,
              stock_quantity,
              image_path,
              is_active,
              created_at,
              updated_at
            )
            SELECT
              id,
              name,
              sale_price,
              CASE
                WHEN purchase_price = 0 THEN NULL
                ELSE purchase_price
              END,
              CASE
                WHEN stock_type = 'unlimited' THEN 'unlimited'
                ELSE 'quantity'
              END,
              stock_quantity,
              image_path,
              is_active,
              created_at,
              updated_at
            FROM products
          ''');

          await db.execute('DROP TABLE products');
          await db.execute('ALTER TABLE products_new RENAME TO products');

          // Existing order items also need to support unknown purchase costs.
          await db.execute('''
            CREATE TABLE order_items_new (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              order_id INTEGER NOT NULL,
              product_id INTEGER,
              product_name TEXT NOT NULL,
              quantity INTEGER NOT NULL CHECK(quantity > 0),
              sale_price INTEGER NOT NULL CHECK(sale_price >= 0),
              purchase_price INTEGER DEFAULT NULL
                CHECK(purchase_price IS NULL OR purchase_price >= 0),
              FOREIGN KEY (order_id)
                REFERENCES orders(id) ON DELETE RESTRICT,
              FOREIGN KEY (product_id)
                REFERENCES products(id) ON DELETE SET NULL
            )
          ''');

          await db.execute('''
            INSERT INTO order_items_new (
              id,
              order_id,
              product_id,
              product_name,
              quantity,
              sale_price,
              purchase_price
            )
            SELECT
              id,
              order_id,
              product_id,
              product_name,
              quantity,
              sale_price,
              CASE
                WHEN purchase_price = 0 THEN NULL
                ELSE purchase_price
              END
            FROM order_items
          ''');

          await db.execute('DROP TABLE order_items');
          await db.execute('ALTER TABLE order_items_new RENAME TO order_items');

          await _createIndexes(db);
        }
      },

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return _database!;
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_orders_status
      ON orders(status)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_order_items_order_id
      ON order_items(order_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_payments_order_id
      ON payments(order_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_inventory_product_id
      ON inventory_movements(product_id)
    ''');
  }
}
