import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shimmer/shimmer.dart';

import 'package:aapni_dairy/constants.dart';
import 'package:aapni_dairy/services/api_service.dart';
import 'package:aapni_dairy/models/customer.dart';

class ExportTotalPdfScreen extends StatefulWidget {
  const ExportTotalPdfScreen({super.key});

  @override
  State<ExportTotalPdfScreen> createState() => _ExportTotalPdfScreenState();
}

class _ExportTotalPdfScreenState extends State<ExportTotalPdfScreen>
    with SingleTickerProviderStateMixin {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  final ApiService _api = ApiService();
  bool _isGeneratingPdf = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_start.isAfter(_end)) _end = _start;
        } else {
          _end = picked;
          if (_end.isBefore(_start)) _start = _end;
        }
      });
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final bytes = await _buildPdfBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'milk_summary_${DateFormat('ddMMyyyy').format(_start)}_${DateFormat('ddMMyyyy').format(_end)}.pdf',
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<Uint8List> _buildPdfBytes() async {
    final startStr = DateFormat('yyyy-MM-dd').format(_start);
    final endStr = DateFormat('yyyy-MM-dd').format(_end);

    // Fetch summary and grand totals
    final res = await _api.getTotalSummary(startStr, endStr);
    final List summaryList = res['customers'] ?? [];
    final totalsJson = res['grandTotals'] ?? {};

    // Fetch all customers
    final allCustomers = await _api.getAllCustomers();

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
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            Constants.dairyName,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            Constants.ownerName,
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.grey700,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Mob: ${Constants.mobileNumber}',
                            style: pw.TextStyle(
                              fontSize: 12,
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
                      vertical: 15,
                      horizontal: 20,
                    ),
                    child: pw.Text(
                      'Total Milk Collection Summary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      'Period: ${DateFormat('dd-MM-yyyy').format(_start)} to ${DateFormat('dd-MM-yyyy').format(_end)}',
                      style: pw.TextStyle(
                        fontSize: 12,
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
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      cellStyle: pw.TextStyle(fontSize: 11),
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
                      cellPadding: const pw.EdgeInsets.all(8),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Summary Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
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
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Quantity:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${totalQty.toStringAsFixed(2)} L',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'Rs.${payable.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 12,
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
                  pw.SizedBox(height: 30),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      'Generated by Aapni Dairy App',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic,
                      ),
                      textAlign: pw.TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Milk PDF'),
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
            child: Column(
              children: [
                // Enhanced Date Picker with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    'Start: ${df.format(_start)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.date_range,
                                    color: Colors.blue.shade700,
                                  ),
                                  onTap: () => _pickDate(true),
                                ),
                                const Divider(),
                                ListTile(
                                  title: Text(
                                    'End: ${df.format(_end)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.date_range,
                                    color: Colors.blue.shade700,
                                  ),
                                  onTap: () => _pickDate(false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Enhanced Share PDF Button with Animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value.clamp(0.0, 1.0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isGeneratingPdf
                                  ? [Colors.grey.shade400, Colors.grey.shade600]
                                  : [
                                      Colors.blue.shade600,
                                      Colors.blue.shade800,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withValues(
                                  alpha: 0.5,
                                ),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isGeneratingPdf ? null : _sharePdf,
                            icon: _isGeneratingPdf
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.share,
                                      key: ValueKey('share'),
                                    ),
                                  ),
                            label: Text(
                              _isGeneratingPdf
                                  ? 'Generating PDF...'
                                  : 'Share PDF',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // PDF Preview with Animation
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _isGeneratingPdf
                                  ? _buildShimmerPreview()
                                  : PdfPreview(
                                      build: (_) => _buildPdfBytes(),
                                      allowSharing: false,
                                      allowPrinting: true,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPreview() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Generating PDF Preview...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
