import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shimmer/shimmer.dart';

import 'package:aapni_dairy/constants.dart';
import '../services/api_service.dart';
import '../models/customer.dart';

class TotalSummaryPdfScreen extends StatefulWidget {
  final bool lifetime; // true = lifetime summary, false = date range
  const TotalSummaryPdfScreen({super.key, this.lifetime = false});

  @override
  _TotalSummaryPdfScreenState createState() => _TotalSummaryPdfScreenState();
}

class _TotalSummaryPdfScreenState extends State<TotalSummaryPdfScreen>
    with SingleTickerProviderStateMixin {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _loading = false;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final bytes = await _buildPdfBytes();
      final filename = widget.lifetime
          ? 'milk_summary_lifetime.pdf'
          : 'milk_summary_${DateFormat('ddMMyyyy').format(_startDate)}_${DateFormat('ddMMyyyy').format(_endDate)}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: filename);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = 'Failed to generate PDF: ${e.toString()}';
      });
    } finally {
      if (!_hasError) {
        setState(() => _loading = false);
      }
    }
  }

  Future<Uint8List> _buildPdfBytes() async {
    final startStr = widget.lifetime
        ? ''
        : DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = widget.lifetime
        ? ''
        : DateFormat('yyyy-MM-dd').format(_endDate);

    // Fetch summary and grand totals
    final res = widget.lifetime
        ? await ApiService().getLifetimeSummary()
        : await ApiService().getTotalSummary(startStr, endStr);
    final List summaryList = res['customers'] ?? [];
    final totalsJson = res['grandTotals'] ?? {};

    // Fetch all customers
    final allCustomers = await ApiService().getAllCustomers();

    // Map customers by c_id
    final Map<int, Customer> customerMap = {
      for (var c in allCustomers)
        if (c.localID != null) c.localID!: c,
    };

    if (summaryList.isEmpty) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(40),
          build: (_) => pw.Center(
            child: pw.Text(
              'No entries found',
              style: pw.TextStyle(fontSize: 18, color: PdfColors.grey600),
            ),
          ),
        ),
      );
      return pdf.save();
    }

    double totalQty = 0;
    double totalAmount = 0;

    final rows = summaryList.map((cJson) {
      final customerCid = cJson['customerCid']?.toInt() ?? 0;
      final customer = customerMap[customerCid];

      final qty = (cJson['totalQty'] ?? 0).toDouble();
      final amount = (cJson['totalAmount'] ?? 0).toDouble();

      totalQty += qty;
      totalAmount += amount;

      return [
        customer?.localID?.toString() ?? customerCid.toString(),
        customer?.name ?? 'Unknown',
        qty.toStringAsFixed(2),
        amount.toStringAsFixed(2),
      ];
    }).toList();

    final payable = (totalsJson['payable'] ?? totalAmount).toDouble();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          pw.Stack(
            children: [
              // Background watermark centered on the entire page
              pw.Positioned.fill(
                child: pw.Transform.rotate(
                  angle:
                      45 * (3.141592653589793 / 180), // 45 degrees in radians
                  child: pw.Center(
                    child: pw.Text(
                      'AAPNI DAIRY',
                      style: pw.TextStyle(
                        fontSize: 24,
                        color: PdfColors.grey200,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // Content on top
              pw.Column(
                children: [
                  // Header Section
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            Constants.dairyName,
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            Constants.ownerName,
                            style: pw.TextStyle(
                              fontSize: 16,
                              color: PdfColors.grey700,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Mob: ${Constants.mobileNumber}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.grey600,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Title Section
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: pw.Text(
                      'Total Milk Collection Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      widget.lifetime
                          ? 'Period: Lifetime'
                          : 'Period: ${DateFormat('dd-MM-yyyy').format(_startDate)} to ${DateFormat('dd-MM-yyyy').format(_endDate)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Table Section
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 1),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.TableHelper.fromTextArray(
                      headers: [
                        'Customer ID',
                        'Customer Name',
                        'Quantity',
                        'Amount',
                      ],
                      data: rows,
                      headerStyle: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      cellStyle: pw.TextStyle(fontSize: 9),
                      cellAlignment: pw.Alignment.centerLeft,
                      headerDecoration: pw.BoxDecoration(
                        color: PdfColors.grey700,
                      ),
                      rowDecoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.grey300,
                            width: 0.5,
                          ),
                        ),
                      ),
                      cellPadding: const pw.EdgeInsets.all(4),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Summary Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border.all(color: PdfColors.grey400, width: 1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Summary',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Quantity:',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${totalQty.toStringAsFixed(2)} L',
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount:',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'Rs.${payable.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.black,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      'Generated by Aapni Dairy App',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lifetime ? 'Lifetime Summary PDF' : 'Total Summary PDF',
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _hasError
                ? _buildErrorWidget()
                : Column(
                    children: [
                      if (!widget.lifetime) ...[
                        // Animated Start Date Picker
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(-50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    title: Text(
                                      'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.calendar_today,
                                      color: Colors.blue.shade700,
                                    ),
                                    onTap: _pickStartDate,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Animated End Date Picker
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    title: Text(
                                      'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.calendar_today,
                                      color: Colors.blue.shade700,
                                    ),
                                    onTap: _pickEndDate,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                      // Animated Generate PDF Button
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _loading
                                      ? [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600,
                                        ]
                                      : [
                                          Colors.blue.shade600,
                                          Colors.blue.shade800,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_loading ? Colors.grey : Colors.blue)
                                            .shade400
                                            .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _generatePdf,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? _buildShimmerLoading()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.picture_as_pdf,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Generate PDF',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.white.withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 120, height: 18, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
