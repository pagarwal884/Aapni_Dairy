import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart'; // ✅ ONLY User class
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  static final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  Stream<User?> get authStateChanges => _authStateController.stream;

  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthService() {
    _loadCurrentUser();
  }

  // Load user from local storage (if token exists)
  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final dairyName = prefs.getString('dairyName') ?? '';
      final ownerName = prefs.getString('ownerName') ?? '';
      final mobile = prefs.getString('mobileNumber') ?? '';

      _currentUser = User(
        ownerName: ownerName,
        dairyName: dairyName,
        mobile: mobile,
        password: '',
      );

      _authStateController.add(_currentUser);
    }
  }

  // ================= SIGN UP =================
  Future<User> signUp(
    String mobile,
    String password, {
    required String dairyName,
    required String ownerName,
    required String email,
  }) async {
    try {
      final response = await _apiService.signup(
        ownerName,
        email,
        mobile,
        dairyName,
        password,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Signup failed');
      }

      // Create user object from input parameters since backend doesn't return user data
      _currentUser = User(
        ownerName: ownerName,
        dairyName: dairyName,
        mobile: mobile,
        password: password,
      );
      _authStateController.add(_currentUser);

      return _currentUser!;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // ================= SIGN IN =================
  Future<User> signIn(String mobile, String password) async {
    try {
      final response = await _apiService.login(mobile, password);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Login failed');
      }

      // For login, we need to get user data from somewhere else
      // Since backend doesn't return user data, we'll create a basic user object
      // In a real app, you'd make another API call to get user profile
      _currentUser = User(
        ownerName: '', // These would be fetched from another endpoint
        dairyName: '',
        mobile: mobile,
        password: password,
      );
      _authStateController.add(_currentUser);

      return _currentUser!;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _currentUser = null;
    _authStateController.add(null);
  }

  // ================= OTP (PLACEHOLDERS) =================
  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true, 'message': 'OTP sent'};
  }

  Future<User> verifyOtp(
    String mobile,
    String otp,
    String password,
    String dairyName,
    String ownerName,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      ownerName: ownerName,
      dairyName: dairyName,
      mobile: mobile,
      password: password,
    );

    _authStateController.add(_currentUser);
    return _currentUser!;
  }
}
