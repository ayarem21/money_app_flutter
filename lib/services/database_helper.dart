import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<sql.Database> databaseConnection() async {
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
}
