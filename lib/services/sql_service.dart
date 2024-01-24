import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlService {
  //// Get All Items from the Database
  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await SqlService.db();
    return db.query('items', orderBy: 'id');
  }

  //// Get A Item from the Database
  static Future<List<Map<String, dynamic>>> getItem({required int id}) async {
    final db = await SqlService.db();
    return db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  //// Create a new table in the database
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )""");
  }

  /// Create a new instance of the database
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "sample.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

  //// Inset item to the table in the database
  static Future<int> createItem({required String title, required String description}) async {
    final db = await SqlService.db();
    final Map<String, dynamic> data = {"title": title, "description": description};
    final int id = await db.insert(
      'items',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    return id;
  }

  //// update item to the table in the database
  static Future<int> updateItem({required int id, required String title, required String description}) async {
    final db = await SqlService.db();
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'description': description,
      'created_at': DateTime.now().toString(),
    };

    final result = await db.update(
      'items',
      data,
      where: "id = ?",
      whereArgs: [id],
    );
    return result;
  }

  //// Delte item from the table in the database
  static Future<void> deleteItem({required int id}) async {
    final db = await SqlService.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("something went wrong when deleting item : $e");
    }
  }
}
