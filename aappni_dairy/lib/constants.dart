import 'package:pdf/pdf.dart';
import 'package:aapni_dairy/db/db_helper.dart';

class Constants {
  // ---------------- DAIRY DETAILS ----------------
  static String dairyName = 'HRB DAIRY KHEDA RAMPURA';
  static String ownerName = 'MAHESH KUMAR YADAV';
  static String mobileNumber = '9876543210';
  static const String madeBy = '';

  // ---------------- RATE CONSTANTS ----------------
  static double rateConstantA = 8.0;
  static double rateConstantB = 2.0;

  // ---------------- PDF SETTINGS ----------------
  static const PdfPageFormat defaultPageFormat = PdfPageFormat.a4;
  static const double defaultTitleFontSize = 20.0;
  static const double defaultTableFontSize = 10.0;
  static const double minFontSize = 6.0;
  static const double maxFontSize = 16.0;

  static const Map<String, PdfPageFormat> pageFormats = {
    'A4': PdfPageFormat.a4,
    'A5': PdfPageFormat.a5,
    'Letter': PdfPageFormat.letter,
    'Legal': PdfPageFormat.legal,
  };

  // ---------------- METHODS ----------------

  /// Load rate constants from SharedPreferences
  static Future<void> loadRateConstants() async {
    try {
      final db = DatabaseHelper();
      final rates = await db.getRateConstants();
      rateConstantA = rates['a'] ?? rateConstantA;
      rateConstantB = rates['b'] ?? rateConstantB;
    } catch (e) {
      print('Error loading rate constants: $e');
    }
  }

  /// Save rate constants to SharedPreferences
  static Future<void> saveRateConstants(double a, double b) async {
    try {
      final db = DatabaseHelper();

      rateConstantA = a;
      rateConstantB = b;
    } catch (e) {
      print('Error saving rate constants: $e');
    }
  }

  /// Load dairy details from SharedPreferences
  static Future<void> loadDairyDetails() async {
    try {
      final db = DatabaseHelper();
      final details = await db.getDairyDetails();

      dairyName = details['dairyName'] ?? dairyName;
      ownerName = details['ownerName'] ?? ownerName;
      mobileNumber = details['mobileNumber'] ?? mobileNumber;
    } catch (e) {
      print('Error loading dairy details: $e');
    }
  }

  /// Save dairy details to SharedPreferences
  static Future<void> saveDairyDetails({
    required String dairy,
    required String owner,
    required String mobile,
  }) async {
    try {
      final db = DatabaseHelper();
      await db.saveDairyDetails(
        dairyName: dairy,
        ownerName: owner,
        mobileNumber: mobile,
      );

      dairyName = dairy;
      ownerName = owner;
      mobileNumber = mobile;
    } catch (e) {
      print('Error saving dairy details: $e');
    }
  }
}
