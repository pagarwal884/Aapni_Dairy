import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milk_entry.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../constants.dart';
import 'dart:async';

class MilkEntryScreen extends StatefulWidget {
  const MilkEntryScreen({super.key});

  @override
  _MilkEntryScreenState createState() => _MilkEntryScreenState();
}

class _MilkEntryScreenState extends State<MilkEntryScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _snfController = TextEditingController();
  final TextEditingController _snfKatotiController = TextEditingController();

  String? _customerName;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning';
  List<bool> _shiftSelections = [true, false];
  List<MilkEntry> _shiftEntries = [];
  Map<int, String> _customerNames = {};

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedShift = _getCurrentShift();
    _shiftSelections = _selectedShift == 'Morning'
        ? [true, false]
        : [false, true];
    _fetchShiftEntries(); // Load initial entries

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  String _getCurrentShift() =>
      DateTime.now().hour >= 12 ? 'Evening' : 'Morning';

  // Fetch customer by localID
  Future<void> _fetchCustomerName() async {
    if (_customerIdController.text.isEmpty) {
      setState(() {
        _customerName = null;
        _selectedCustomer = null;
        _customerNameController.text = '';
      });
      return;
    }

    int? localId = int.tryParse(_customerIdController.text);
    if (localId == null) {
      setState(() {
        _customerName = null;
        _selectedCustomer = null;
        _customerNameController.text = '';
      });
      return;
    }

    try {
      List<Customer> customers = await ApiService().getAllCustomers();
      Customer customer = customers.firstWhere(
        (c) => c.localID == localId,
        orElse: () => Customer(name: '', id: null),
      );

      setState(() {
        if (customer.name.isNotEmpty) {
          _customerName = customer.name;
          _selectedCustomer = customer;
          _customerNameController.text = _customerName!;
        } else {
          _customerName = null;
          _selectedCustomer = null;
          _customerNameController.text = '';
        }
      });
    } catch (_) {
      setState(() {
        _customerName = null;
        _selectedCustomer = null;
        _customerNameController.text = '';
      });
    }
  }

  // Save milk entry
  Future<void> _saveMilkEntry() async {
    if (!_formKey.currentState!.validate() || _selectedCustomer == null) return;

    double quantity = double.parse(_quantityController.text);
    double fat = double.parse(_fatController.text);
    double snf = _snfController.text.isEmpty
        ? 8.5
        : double.parse(_snfController.text);
    double snfKatoti = _snfKatotiController.text.isEmpty
        ? 0.0
        : double.parse(_snfKatotiController.text);

    double rate = Constants.rateConstantA * fat + Constants.rateConstantB;
    double totalAmount = rate * quantity;

    Map<String, dynamic> body = {
      'customerId': _selectedCustomer!.localID, // send int localID
      'entryDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'shift': _selectedShift,
      'quantity': quantity,
      'fat': fat,
      'snf': snf,
      'rate': rate,
      'total_amount': totalAmount,
      'SNF_K': snfKatoti,
    };

    try {
      MilkEntry createdEntry = await ApiService().createMilkEntry(
        _selectedCustomer!.localID!,
        body,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Milk Entry Saved'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅ Milk entry saved successfully!'),
              Text(
                '📊 Rate: ₹${createdEntry.rate.toStringAsFixed(2)} per liter',
              ),
              Text(
                '💰 Amount: ₹${createdEntry.totalAmount.toStringAsFixed(2)}',
              ),
              Text('💸 SNF Katoti: ₹${createdEntry.snfK.toStringAsFixed(2)}'),
              Text(
                '💵 Payable: ₹${(createdEntry.totalAmount - (createdEntry.snfK * createdEntry.quantity)).toStringAsFixed(2)}',
              ),
              Text(
                '🥛 Quantity: ${createdEntry.quantity.toStringAsFixed(2)} L',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      _quantityController.clear();
      _fatController.clear();
      _snfController.clear();
      _snfKatotiController.clear();
      _fetchShiftEntries(); // Refresh the list after saving
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving entry: $e')));
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchShiftEntries();
    }
  }

  // Fetch entries for the selected shift and date
  Future<void> _fetchShiftEntries() async {
    try {
      List<MilkEntry> allEntries = await ApiService().getAllEntriesForUser();
      List<MilkEntry> filteredEntries = allEntries.where((entry) {
        DateTime entryDate = DateTime.parse(entry.entryDate).toLocal();
        return entry.shift == _selectedShift &&
            entryDate.year == _selectedDate.year &&
            entryDate.month == _selectedDate.month &&
            entryDate.day == _selectedDate.day;
      }).toList();

      // Fetch customer names for the entries
      List<Customer> customers = await ApiService().getAllCustomers();
      Map<int, String> customerNames = {};
      for (var customer in customers) {
        if (customer.localID != null) {
          customerNames[customer.localID!] = customer.name;
        }
      }

      setState(() {
        _shiftEntries = filteredEntries;
        _customerNames = customerNames;
      });
    } catch (e) {
      setState(() {
        _shiftEntries = [];
        _customerNames = {};
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching entries: $e')));
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _customerNameController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _snfKatotiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Milk Entry'),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _pickDate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MM-dd-yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedShift = 'Morning';
                              _shiftSelections = [true, false];
                            });
                            _fetchShiftEntries();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedShift == 'Morning'
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.wb_sunny,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedShift = 'Evening';
                              _shiftSelections = [false, true];
                            });
                            _fetchShiftEntries();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedShift == 'Evening'
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Icon(
                              Icons.nightlight_round,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        toolbarHeight: 80.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Customer ID and Name fields below app bar
                Card(
                  elevation: 8,
                  shadowColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _customerIdController,
                            decoration: const InputDecoration(
                              labelText: 'Customer ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _fetchCustomerName(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Please enter customer ID';
                              if (int.tryParse(value) == null)
                                return 'Invalid customer ID';
                              if (_customerName == null)
                                return 'Customer not found';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _customerNameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.account_circle,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shadowColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Milk Entry Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity (L)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.scale,
                                    color: Colors.blue,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'Please enter quantity';
                                  if (double.tryParse(value) == null)
                                    return 'Invalid quantity';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _fatController,
                                decoration: const InputDecoration(
                                  labelText: 'Fat (%)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.opacity,
                                    color: Colors.blue,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'Please enter fat';
                                  if (double.tryParse(value) == null)
                                    return 'Invalid fat';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _snfController,
                                decoration: const InputDecoration(
                                  labelText: 'SNF (default 8.5)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.science,
                                    color: Colors.blue,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _snfKatotiController,
                                decoration: const InputDecoration(
                                  labelText: 'SNF Katoti (default 0.0)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.calculate,
                                    color: Colors.blue,
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _scaleController.forward();
                        await _scaleController.reverse();
                        _saveMilkEntry();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Entry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.blue.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Display shift entries
                if (_shiftEntries.isNotEmpty) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _shiftEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _shiftEntries[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _customerNames[entry.customerCid]?.substring(
                                    0,
                                    1,
                                  ) ??
                                  entry.customerCid.toString(),
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                          title: Text(
                            "Name : ${_customerNames[entry.customerCid] ?? 'Unknown'} , ID : ${entry.customerCid}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Qty: ${entry.quantity} L | Fat: ${entry.fat}% | SNF: ${entry.snf} | Rate: ₹${entry.rate.toStringAsFixed(2)} | Amount: ₹${entry.totalAmount.toStringAsFixed(2)}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Confirm deletion
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Entry'),
                                  content: const Text(
                                    'Are you sure you want to delete this entry?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await ApiService().deleteMilkEntry(entry.id!);
                                  _fetchShiftEntries(); // Refresh the list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Entry deleted successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error deleting entry: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ] else if (_shiftEntries.isEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'No entries found for this date and shift.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
