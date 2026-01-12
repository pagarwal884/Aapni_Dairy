import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pwPdf;
import 'package:aapni_dairy/constants.dart';
import '../models/milk_entry.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class ExportCustomerPdfScreen extends StatefulWidget {
  const ExportCustomerPdfScreen({super.key});

  @override
  _ExportCustomerPdfScreenState createState() =>
      _ExportCustomerPdfScreenState();
}

class _ExportCustomerPdfScreenState extends State<ExportCustomerPdfScreen> {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _selectedMethod = 'Method 1';
  List<bool> _methodSelections = [true, false];
  final String _selectedPageFormat = 'A4';
  final double _titleFontSize = Constants.defaultTitleFontSize;
  final double _tableFontSize = Constants.defaultTableFontSize;

  final ApiService _api = ApiService();

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

  void _onMethodToggle(int index) {
    setState(() {
      for (int i = 0; i < _methodSelections.length; i++) {
        _methodSelections[i] = i == index;
      }
      _selectedMethod = index == 0 ? 'Method 1' : 'Method 2';
    });
  }

  Map<String, double> _calculateFontSizes(int entryCount) {
    return {'title': _titleFontSize, 'table': _tableFontSize};
  }

  Future<Uint8List> _buildPdfBytes() async {
    try {
      final allCustomers = await _api.getAllCustomers();
      final pdfDoc = pw.Document();
      bool hasPages = false;

      if (allCustomers.isEmpty) {
        pdfDoc.addPage(
          pw.Page(
            build: (context) =>
                pw.Center(child: pw.Text('No customers found.')),
          ),
        );
        return pdfDoc.save();
      }

      for (var customer in allCustomers) {
        final custId = customer.localID;
        if (custId == null) continue;

        // Fetch entries for customer within selected range
        final entries = <MilkEntry>[];
        DateTime currentDate = _start;
        while (!currentDate.isAfter(_end)) {
          final dayEntries = await _api.getMilkEntriesByDateAndCustomer(
            custId,
            DateFormat('yyyy-MM-dd').format(currentDate),
          );
          entries.addAll(dayEntries);
          currentDate = currentDate.add(const Duration(days: 1));
        }

        if (entries.isEmpty) continue;

        double totalQuantity = entries.fold(0, (sum, e) => sum + e.quantity);
        double totalAmount = entries.fold(0, (sum, e) => sum + e.totalAmount);
        double totalSnfKatoti = entries.fold(0, (sum, e) => sum + e.snfK);
        double payableAmount = totalAmount - totalSnfKatoti;

        List<List<MilkEntry>> chunks = [];
        for (int i = 0; i < entries.length; i += 30) {
          chunks.add(
            entries.sublist(
              i,
              i + 30 > entries.length ? entries.length : i + 30,
            ),
          );
        }

        for (var chunk in chunks) {
          final fontSizes = _calculateFontSizes(chunk.length);

          pdfDoc.addPage(
            pw.MultiPage(
              pageFormat: Constants.pageFormats[_selectedPageFormat]!,
              margin: const pw.EdgeInsets.all(40),
              build: (_) => [
                pw.Stack(
                  children: [
                    // Background watermark centered on the entire page
                    pw.Positioned.fill(
                      child: pw.Transform.rotate(
                        angle:
                            45 *
                            (3.141592653589793 / 180), // 45 degrees in radians
                        child: pw.Center(
                          child: pw.Text(
                            'AAPNI DAIRY',
                            style: pw.TextStyle(
                              fontSize: 24,
                              color: pwPdf.PdfColors.grey200,
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
                              color: pwPdf.PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(10),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  Constants.dairyName,
                                  style: pw.TextStyle(
                                    fontSize: 24,
                                    fontWeight: pw.FontWeight.bold,
                                    color: pwPdf.PdfColors.black,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  Constants.ownerName,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    color: pwPdf.PdfColors.grey700,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Mob: ${Constants.mobileNumber}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    color: pwPdf.PdfColors.grey600,
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
                            'Customer Milk Summary',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: pwPdf.PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Column(
                          children: [
                            pw.Text(
                              'Customer: ${customer.name}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: pwPdf.PdfColors.grey800,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Period: ${DateFormat("dd-MM-yyyy").format(_start)} to ${DateFormat("dd-MM-yyyy").format(_end)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: pwPdf.PdfColors.grey800,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 20),

                        // Table Section
                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Container(
                            width: pwPdf.PdfPageFormat.a4.width * 0.75,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: pwPdf.PdfColors.grey400,
                                width: 1,
                              ),
                              borderRadius: pw.BorderRadius.circular(5),
                            ),
                            child: pw.TableHelper.fromTextArray(
                              headers: _selectedMethod == 'Method 1'
                                  ? [
                                      'Date',
                                      'Shift',
                                      'Quantity',
                                      'Fat',
                                      'Rate',
                                      'Amount',
                                    ]
                                  : (chunk.any((e) => e.snf > 0)
                                        ? [
                                            'Date',
                                            'Shift',
                                            'Quantity',
                                            'Fat',
                                            'SNF',
                                            'Amount',
                                          ]
                                        : [
                                            'Date',
                                            'Shift',
                                            'Quantity',
                                            'Fat',
                                            'Amount',
                                          ]),
                              data: chunk.map((entry) {
                                List<String> row = [
                                  DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(DateTime.parse(entry.entryDate)),
                                  entry.shift,
                                  entry.quantity.toStringAsFixed(2),
                                  entry.fat.toStringAsFixed(2),
                                ];
                                if (_selectedMethod == 'Method 1') {
                                  row.add(entry.rate.toStringAsFixed(2));
                                } else if (chunk.any((e) => e.snf > 0)) {
                                  row.add(entry.snf.toStringAsFixed(2));
                                }
                                row.add(entry.totalAmount.toStringAsFixed(2));
                                return row;
                              }).toList(),
                              headerStyle: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: pwPdf.PdfColors.white,
                              ),
                              cellStyle: pw.TextStyle(fontSize: 11),
                              cellAlignment: pw.Alignment.centerLeft,
                              headerDecoration: pw.BoxDecoration(
                                color: pwPdf.PdfColors.grey700,
                              ),
                              rowDecoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: pwPdf.PdfColors.grey300,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              cellPadding: const pw.EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),

                        // Summary Section
                        pw.Container(
                          padding: const pw.EdgeInsets.all(15),
                          decoration: pw.BoxDecoration(
                            color: pwPdf.PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'Total Quantity:',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    '${totalQuantity.toStringAsFixed(2)} L',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      color: pwPdf.PdfColors.blue900,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'Total Amount:',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    'Rs.${totalAmount.toStringAsFixed(2)}',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      color: pwPdf.PdfColors.black,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (totalSnfKatoti != 0) ...[
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'SNF KATOTI:',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      'Rs.${totalSnfKatoti.toStringAsFixed(2)}',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        color: pwPdf.PdfColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      'Payable Amount:',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      'Rs.${payableAmount.toStringAsFixed(2)}',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        color: pwPdf.PdfColors.black,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Footer
                        pw.SizedBox(height: 30),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: pwPdf.PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Text(
                            'Generated by Aapni Dairy App',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: pwPdf.PdfColors.grey600,
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

          hasPages = true;
        }
      }

      if (!hasPages) {
        pdfDoc.addPage(
          pw.Page(
            build: (context) => pw.Center(
              child: pw.Text('No milk entries found for selected date range.'),
            ),
          ),
        );
      }

      return pdfDoc.save();
    } catch (e, stack) {
      print('Error generating customer PDF: $e\n$stack');
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (context) =>
              pw.Center(child: pw.Text('Error generating PDF.')),
        ),
      );
      return pdf.save();
    }
  }

  pw.Widget _buildSummaryRow(String label, String value, pwPdf.PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Customer PDF'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ToggleButtons(
              isSelected: _methodSelections,
              onPressed: _onMethodToggle,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Method 1'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Method 2'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PdfPreview(
                  build: (format) => _buildPdfBytes(),
                  canChangePageFormat: false,
                  allowPrinting: true,
                  allowSharing: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
