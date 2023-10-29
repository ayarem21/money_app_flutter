import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'money_app22.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE salary_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        salary REAL,
        getting_salary_date TIMESTAMP,
        static_tax REAL,
        five_percent_tax REAL
      )
      """);
  }

  static Future<int> createItem(double? salary, String? gettingSalaryDate, double? staticTax, double? fivePercentTax) async {
    final db = await DatabaseHelper.db();

    final data = {'salary': salary, 'getting_salary_date': gettingSalaryDate, 'static_tax': staticTax, 'five_percent_tax': fivePercentTax};

    final id = await db.insert('salary_history', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;

  }

  // Read all salary_history
  static Future<List<Map<String, dynamic>>> getSalaryHistory() async {
    final db = await DatabaseHelper.db();
    return db.query('salary_history', orderBy: "getting_salary_date DESC");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('salary_history', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, double? salary, String? gettingSalaryDate, double? staticTax, double? fivePercentTax) async {
    final db = await DatabaseHelper.db();

    final data = {
      'salary': salary,
      'getting_salary_date': gettingSalaryDate
    };

    final result =
        await db.update('salary_history', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("salary_history", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}