import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/milk_entry.dart';
import '../models/customer.dart';

class ApiService {
  static const String _baseUrl = 'http://10.37.7.47:5000';

  // ================= AUTH TOKEN =================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ================= GENERIC REQUESTS =================
  Future<Map<String, dynamic>> _get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('GET failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }

    throw Exception('POST failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('PUT failed: ${response.statusCode} ${response.body}');
  }

  Future<void> _delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('DELETE failed: ${response.statusCode} ${response.body}');
    }
  }

  // ================= AUTHENTICATION =================
  Future<Map<String, dynamic>> login(String mobile, String password) async {
    final response = await _post('/api/user/login', {
      'Mobile_no': mobile,
      'password': password,
    });

    if (response.containsKey('token')) {
      await _setToken(response['token']);
    }

    return response;
  }

  Future<Map<String, dynamic>> signup(
    String ownerName,
    String email,
    String mobile,
    String dairyName,
    String password,
  ) async {
    final response = await _post('/api/user/register', {
      'o_name': ownerName,
      'email': email,
      'Mobile_no': mobile,
      'Dairy_name': dairyName,
      'password': password,
    });

    if (response.containsKey('token')) {
      await _setToken(response['token']);
    }

    return response;
  }

  // ================= PROFILE =================
  Future<Map<String, dynamic>> getProfile() async {
    return await _get('/api/user/profile');
  }

  // ================= UPDATE A & B =================
  Future<Map<String, dynamic>> updateAB(double a, double b) async {
    return await _put('/api/user/update-ab', {'a': a, 'b': b});
  }

  // ================= GET A & B =================
  Future<Map<String, dynamic>> getAB() async {
    return await _get('/api/user/ab');
  }

  // ================= CUSTOMER APIs =================
  Future<Customer> createCustomer(String name) async {
    final response = await _post('/api/customer/register', {'c_name': name});
    return Customer.fromMap(response['customer']);
  }

  Future<List<Customer>> getAllCustomers() async {
    final response = await _get('/api/customer/list');
    final List list = response['customers'] ?? [];
    return list.map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _put('/api/customer/update/${customer.id}', {
      'c_name': customer.name,
    });
    return Customer.fromMap(response['customer']);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _delete('/api/customer/remove/$customerId');
  }

  // ================= MILK ENTRY =================
  Future<MilkEntry> createMilkEntry(
    int customerCid,
    Map<String, dynamic> body,
  ) async {
    final res = await _post('/api/entry/milk-entry/$customerCid', body);
    return MilkEntry.fromMap(res['data']);
  }

  Future<MilkEntry> createOrUpdateMilkEntry(
    int customerCid,
    Map<String, dynamic> body,
  ) async {
    final res = await _post('/api/entry/milk-entry/$customerCid', body);
    return MilkEntry.fromMap(res['data']);
  }

  Future<MilkEntry> updateMilkEntry(
    String entryId,
    Map<String, dynamic> body,
  ) async {
    final res = await _put('/api/entry/update-entry/$entryId', body);
    return MilkEntry.fromMap(res['data']);
  }

  Future<List<MilkEntry>> getMilkEntriesByDateAndCustomer(
    int customerCid,
    String date,
  ) async {
    final res = await _get(
      '/api/entry/customer/$customerCid/by-date?entryDate=$date',
    );
    final List list = res['data'] ?? [];
    return list.map((e) => MilkEntry.fromMap(e)).toList();
  }

  Future<void> deleteMilkEntry(String entryId) async {
    await _delete('/api/entry/$entryId');
  }

  Future<List<MilkEntry>> getAllEntriesForUser() async {
    final res = await _get('/api/entry/all');
    final List list = res['data'] ?? [];
    return list.map((e) => MilkEntry.fromMap(e)).toList();
  }

  Future<List<MilkEntry>> getMilkEntriesByCustomer(int customerCid) async {
    final res = await _get('/api/entry/milk-entries/customer/$customerCid/all');
    final List list = res['data'] ?? [];
    return list.map((e) => MilkEntry.fromMap(e)).toList();
  }

  // ================= ENTRY SUMMARIES =================
  Future<Map<String, dynamic>> getTotalSummary(String start, String end) async {
    final res = await _get('/api/entry/summary/total?start=$start&end=$end');
    return res;
  }

  Future<Map<String, dynamic>> getLifetimeSummary() async {
    final res = await _get('/api/entry/summary/lifetime');
    return res;
  }
}
