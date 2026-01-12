import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milk_entry.dart';
import '../services/api_service.dart';
import 'edit_milk_entry_screen.dart';

class EditDeleteEntriesScreen extends StatefulWidget {
  const EditDeleteEntriesScreen({super.key});

  @override
  State<EditDeleteEntriesScreen> createState() =>
      _EditDeleteEntriesScreenState();
}

class _EditDeleteEntriesScreenState extends State<EditDeleteEntriesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _customerIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<MilkEntry> _entries = [];
  final ApiService _apiService = ApiService();
  bool _loading = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _listAnimationController;

  Future<void> _fetchEntries() async {
    final raw = _customerIdController.text.trim();
    final cid = int.tryParse(raw);
    if (cid == null) {
      setState(() => _entries = []);
      return;
    }

    setState(() => _loading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final entries = await _apiService.getMilkEntriesByDateAndCustomer(
        cid,
        dateStr,
      );
      setState(() => _entries = entries);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchEntries();
    }
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await _apiService.deleteMilkEntry(id);
      setState(() => _entries.removeWhere((e) => e.id == id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
    }
  }

  Future<void> _editEntry(MilkEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditMilkEntryScreen(entry: entry)),
    );
    if (result == true) _fetchEntries();
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit / Delete Entries'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _customerIdController,
                      decoration: InputDecoration(
                        labelText: 'Customer C_ID (number)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (_) => _fetchEntries(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      onTap: _pickDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _entries.isEmpty
                    ? const Center(child: Text('No entries found'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (_, index) {
                          final entry = _entries[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + index * 100),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 50 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Row(
                                        children: [
                                          Icon(
                                            entry.shift == 'Morning'
                                                ? Icons.wb_sunny
                                                : Icons.nightlight_round,
                                            color: entry.shift == 'Morning'
                                                ? Colors.orange
                                                : Colors.indigo,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Shift: ${entry.shift} | Qty: ${entry.quantity} L | Fat: ${entry.fat}%',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Rate: ₹${entry.rate} | Amount: ₹${entry.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () =>
                                                  _editEntry(entry),
                                              tooltip: 'Edit Entry',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _deleteEntry(entry.id!),
                                              tooltip: 'Delete Entry',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
