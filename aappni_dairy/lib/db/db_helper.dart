import '../models/customer.dart';
import '../models/milk_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ---------------- DAIRY DETAILS ----------------
  Future<Map<String, String>> getDairyDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'dairyName': prefs.getString('dairyName') ?? 'HRB DAIRY KHEDA RAMPURA',
        'ownerName': prefs.getString('ownerName') ?? 'MAHESH KUMAR YADAV',
        'mobileNumber': prefs.getString('mobileNumber') ?? '9876543210',
      };
    } catch (e) {
      print('Error fetching dairy details: $e');
      return {
        'dairyName': 'HRB DAIRY KHEDA RAMPURA',
        'ownerName': 'MAHESH KUMAR YADAV',
        'mobileNumber': '9876543210',
      };
    }
  }

  Future<void> saveDairyDetails({
    required String dairyName,
    required String ownerName,
    required String mobileNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dairyName', dairyName);
      await prefs.setString('ownerName', ownerName);
      await prefs.setString('mobileNumber', mobileNumber);
    } catch (e) {
      print('Error saving dairy details: $e');
    }
  }

  // ---------------- SETTINGS ----------------
  Future<String?> getSetting(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('Error getting setting "$key": $e');
      return null;
    }
  }

  Future<void> saveSetting(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      print('Error saving setting "$key": $e');
    }
  }

  // ---------------- CUSTOMER OPERATIONS ----------------
  Future<Customer> insertCustomer(Customer customer) async {
    // Implement your API call here if needed
    return customer;
  }

  Future<List<Customer>> getAllCustomers() async {
    // Implement your API call here if needed
    return [];
  }

  Future<String?> getCustomerNameById(int id) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return null;
    }
  }

  // ---------------- MILK ENTRY OPERATIONS ----------------
  Future<MilkEntry> insertMilkEntry(MilkEntry entry) async {
    return entry;
  }

  Future<List<MilkEntry>> getAllMilkEntries() async {
    return [];
  }

  Future<MilkEntry> updateMilkEntry(MilkEntry entry) async {
    return entry;
  }

  Future<int> deleteMilkEntry(int id) async {
    return 1;
  }

  Future<List<MilkEntry>> getMilkEntriesByCustomer(int customerId) async {
    return [];
  }

  Future<List<MilkEntry>> getMilkEntriesByCustomerAndRange(
      int customerId, String startDate, String endDate) async {
    return [];
  }

  Future<List<MilkEntry>> getMilkEntriesByDate(String dateStr) async {
    return [];
  }

  Future<List<MilkEntry>> getMilkEntriesInRange(String startDate, String endDate) async {
    return [];
  }

    // ---------------- RATE CONSTANTS ----------------
  Future<Map<String, double>> getRateConstants() async {
    final aStr = await getSetting('rateConstantA');
    final bStr = await getSetting('rateConstantB');
    double a = aStr != null ? double.tryParse(aStr) ?? 8 : 8;
    double b = bStr != null ? double.tryParse(bStr) ?? 2 : 2;
    return {'a': a, 'b': b};
  }
}
