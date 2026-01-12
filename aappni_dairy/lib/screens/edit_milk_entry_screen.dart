import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/milk_entry.dart';
import '../services/api_service.dart';
import '../constants.dart';

class EditMilkEntryScreen extends StatefulWidget {
  final MilkEntry entry;

  const EditMilkEntryScreen({super.key, required this.entry});

  @override
  _EditMilkEntryScreenState createState() => _EditMilkEntryScreenState();
}

class _EditMilkEntryScreenState extends State<EditMilkEntryScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _quantityController;
  late TextEditingController _fatController;
  late TextEditingController _snfController;
  late TextEditingController _snfKatotiController;

  late String _selectedShift;
  late DateTime _selectedDate;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.entry.quantity.toString(),
    );
    _fatController = TextEditingController(text: widget.entry.fat.toString());
    _snfController = TextEditingController(text: widget.entry.snf.toString());
    _snfKatotiController = TextEditingController(
      text: widget.entry.snfK.toString(),
    );
    _selectedShift = widget.entry.shift;
    _selectedDate = DateTime.parse(widget.entry.entryDate);

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

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    double quantity = double.parse(_quantityController.text);
    double fat = double.parse(_fatController.text);
    double snf = _snfController.text.isEmpty
        ? 8.5
        : double.parse(_snfController.text);
    double snfK = _snfKatotiController.text.isEmpty
        ? 0.0
        : double.parse(_snfKatotiController.text);

    double rate = Constants.rateConstantA * fat + Constants.rateConstantB;
    double totalAmount = rate * quantity;

    Map<String, dynamic> body = {
      'entryDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'shift': _selectedShift,
      'quantity': quantity,
      'fat': fat,
      'snf': snf,
      'rate': rate,
      'total_amount': totalAmount,
      'SNF_K': snfK,
    };

    try {
      await _api.updateMilkEntry(widget.entry.id!, body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating entry: $e')));
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _buttonController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _snfKatotiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Milk Entry'),
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
          child: Form(
            key: _formKey,
            child: ListView(
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
                            color: Colors.black.withOpacity(0.1),
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
                const SizedBox(height: 16),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedShift,
                        items: const [
                          DropdownMenuItem(
                            value: 'Morning',
                            child: Row(
                              children: [
                                Icon(Icons.wb_sunny, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Morning'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Evening',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  color: Colors.indigo,
                                ),
                                SizedBox(width: 8),
                                Text('Evening'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null)
                            setState(() => _selectedShift = value);
                        },
                        decoration: InputDecoration(
                          labelText: 'Shift',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.schedule,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity (Liters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.local_drink,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
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
                  ),
                ),
                const SizedBox(height: 16),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _fatController,
                        decoration: InputDecoration(
                          labelText: 'Fat (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.opacity,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
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
                  ),
                ),
                const SizedBox(height: 16),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _snfController,
                        decoration: InputDecoration(
                          labelText: 'SNF (default 8.5)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.science,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _snfKatotiController,
                        decoration: InputDecoration(
                          labelText: 'SNF Katoti (default 0.0)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(
                            Icons.calculate,
                            color: Colors.blue,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _buttonScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonScaleAnimation.value,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Entry',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
