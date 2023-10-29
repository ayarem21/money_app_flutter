import 'package:money_app/repositories/salary_histry_repository.dart';

class SalaryHistoryService {
  static Future<int> createSalaryHistoryItem(
      double salary, String gettingSalaryDate) async {
    double staticTax = 1500.0;
    double fivePercentTax = salary * 0.05;

    final item = {
      'salary': salary,
      'getting_salary_date': gettingSalaryDate,
      'static_tax': staticTax,
      'five_percent_tax': fivePercentTax
    };

    return SalaryHistoryRepository.createSalaryHistoryItem(item);
  }

  static Future<List<Map<String, dynamic>>> getSalaryHistoryList() async {
    return SalaryHistoryRepository.getSalaryHistoryList();
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    return SalaryHistoryRepository.getItem(id);
  }

  static Future<int> updateSalaryHistoryItem(
      int id, double salary, String gettingSalaryDate) async {
    double staticTax = 1500.0;
    double fivePercentTax = salary * 0.05;
    final item = {
      'salary': salary,
      'getting_salary_date': gettingSalaryDate,
      'static_tax': staticTax,
      'five_percent_tax': fivePercentTax,
    };

    return SalaryHistoryRepository.updateSalaryHistoryItem(id, item);
  }

  static Future<void> deleteSalaryHistoryItem(int id) async {
    SalaryHistoryRepository.deleteSalaryHistoryItem(id);
  }
}
