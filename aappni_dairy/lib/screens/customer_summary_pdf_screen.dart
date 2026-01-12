import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:shimmer/shimmer.dart';

class CustomerSummaryPdfScreen extends StatefulWidget {
  const CustomerSummaryPdfScreen({super.key});

  @override
  _CustomerSummaryPdfScreenState createState() =>
      _CustomerSummaryPdfScreenState();
}

class _CustomerSummaryPdfScreenState extends State<CustomerSummaryPdfScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _customerIdController = TextEditingController();
  final ApiService _apiService = ApiService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  Customer? _selectedCustomer;
  bool _isGenerating = false;

  List<Customer> _allCustomers = [];

  @override
  void initState() {
    super.initState();
    _loadAllCustomers();
    _customerIdController.addListener(_updateSelectedCustomer);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  Future<void> _loadAllCustomers() async {
    try {
      _allCustomers = await _apiService.getAllCustomers();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching customers: $e')));
    }
  }

  void _updateSelectedCustomer() {
    final input = _customerIdController.text.trim();
    if (input.isEmpty) {
      setState(() => _selectedCustomer = null);
      return;
    }

    final id = int.tryParse(input);
    if (id == null) {
      setState(() => _selectedCustomer = null);
      return;
    }

    // Match against integer customer ID
    final customer = _allCustomers.firstWhere(
      (c) => c.localID == id || c.id == id,
      orElse: () => Customer(id: '', name: 'Not found', localID: -1),
    );

    setState(
      () => _selectedCustomer = (customer.localID == -1) ? null : customer,
    );
  }

  Future<void> _generateAndSharePdf() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid customer ID')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final customerCId = _selectedCustomer!.localID ?? 0;
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

      final allEntries = await _apiService.getMilkEntriesByCustomer(
        customerCId,
      );

      final filteredEntries = allEntries.where((e) {
        final entryDate = DateTime.parse(e.entryDate); // handle both types
        return !entryDate.isBefore(_startDate) && !entryDate.isAfter(_endDate);
      }).toList();

      // Sort filtered entries by date in ascending order
      filteredEntries.sort(
        (a, b) =>
            DateTime.parse(a.entryDate).compareTo(DateTime.parse(b.entryDate)),
      );

      if (filteredEntries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No entries found for this date range')),
        );
        setState(() => _isGenerating = false);
        return;
      }

      final pdfBytes = await PdfService().generateCustomerSummaryPdf(
        filteredEntries,
        _selectedCustomer!.name,
        startStr,
        endStr,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'customer_summary_${_selectedCustomer!.name}_${DateFormat('ddMMyyyy').format(_startDate)}_${DateFormat('ddMMyyyy').format(_endDate)}.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated and shared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Summary PDF'),
        backgroundColor: Colors.blue.shade700,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCustomerCard(),
                    const SizedBox(height: 16),
                    _buildDateRangeCard(),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Customer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                labelText: 'Customer ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCustomer == null
                  ? 'Customer Name: Not found'
                  : 'Customer Name: ${_selectedCustomer!.name}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedCustomer == null
                    ? Colors.red
                    : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: Colors.blue.shade300,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_view_month,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDatePickerRow('Start Date', _startDate, _pickStartDate),
                const SizedBox(height: 20),
                _buildDatePickerRow('End Date', _endDate, _pickEndDate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(String label, DateTime date, VoidCallback onTap) {
    final df = DateFormat('dd-MM-yyyy');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ${df.format(date)}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isGenerating
                ? [Colors.grey.shade400, Colors.grey.shade600]
                : [Colors.green.shade500, Colors.green.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isGenerating
                  ? Colors.grey.shade300
                  : Colors.green.shade300,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateAndSharePdf,
          icon: _isGenerating
              ? Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.grey.shade300,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    key: ValueKey('pdf'),
                    size: 24,
                  ),
                ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isGenerating ? 'Generating PDF...' : 'Generate & Share PDF',
              key: ValueKey(_isGenerating),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
