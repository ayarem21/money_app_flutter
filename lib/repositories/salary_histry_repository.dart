import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;

import '../services/database_helper.dart';

class SalaryHistoryRepository {
  static Future<List<Map<String, dynamic>>> getSalaryHistoryList() async {
    final db = await DatabaseHelper.databaseConnection();
    return db.query('salary_history', orderBy: "getting_salary_date DESC");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.databaseConnection();
    return db.query('salary_history',
        where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateSalaryHistoryItem(
      int id, Map<String, Object?> item) async {
    final db = await DatabaseHelper.databaseConnection();
    final result = await db
        .update('salary_history', item, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int> createSalaryHistoryItem(Map<String, Object?> item) async {
    final db = await DatabaseHelper.databaseConnection();
    final id = await db.insert('salary_history', item,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<void> deleteSalaryHistoryItem(int id) async {
    final db = await DatabaseHelper.databaseConnection();
    try {
      await db.delete("salary_history", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
