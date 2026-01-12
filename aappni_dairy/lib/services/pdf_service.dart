import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:aapni_dairy/constants.dart';
import 'package:aapni_dairy/models/milk_entry.dart';

class PdfService {
  String _formatDate(String dateString) {
    try {
      // If the date string contains 'T' (ISO format), split and take only date part
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      // If it contains space (common format), split and take only date part
      if (dateString.contains(' ')) {
        return dateString.split(' ')[0];
      }
      // Otherwise return as is (assuming it's already date only)
      return dateString;
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  Future<Uint8List> generateCustomerSummaryPdf(
    List<MilkEntry> entries,
    String customerName,
    String startDate,
    String endDate,
  ) async {
    final pdf = pw.Document();

    double totalQty = entries.fold(0, (sum, entry) => sum + entry.quantity);
    double totalAmount = entries.fold(
      0,
      (sum, entry) => sum + entry.totalAmount,
    );

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
                        fontSize: 18,
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
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            Constants.dairyName,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            Constants.ownerName,
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColors.grey700,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Mob: ${Constants.mobileNumber}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Title Section
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: pw.Text(
                      'Customer Milk Summary',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Customer: $customerName',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Period: $startDate to $endDate',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),

                  // Table Section
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 1),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.TableHelper.fromTextArray(
                      headers: ['Date', 'Shift', 'Qty', 'Fat', 'SNF', 'Amt'],
                      data: entries
                          .map(
                            (entry) => [
                              _formatDate(entry.entryDate),
                              entry.shift,
                              entry.quantity.toStringAsFixed(2),
                              entry.fat.toStringAsFixed(2),
                              entry.snf.toStringAsFixed(2),
                              entry.totalAmount.toStringAsFixed(2),
                            ],
                          )
                          .toList(),
                      headerStyle: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      cellStyle: pw.TextStyle(fontSize: 8),
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
                  pw.SizedBox(height: 10),

                  // Summary Section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Quantity:',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${totalQty.toStringAsFixed(2)} L',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 3),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total Amount:',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'Rs.${totalAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 10,
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
                  pw.SizedBox(height: 15),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'Generated by Aapni Dairy App',
                      style: pw.TextStyle(
                        fontSize: 8,
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

  Future<void> generateAllCustomersPdf(
    List<Map<String, dynamic>> customerSummaries,
  ) async {
    final pdf = pw.Document();

    for (var summary in customerSummaries) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  Constants.dairyName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(Constants.ownerName),
                pw.Text('Mob: ${Constants.mobileNumber}'),
                pw.SizedBox(height: 20),
                pw.Text('Customer: ${summary['name']}'),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: [
                    'Date',
                    'Shift',
                    'Quantity',
                    'Fat',
                    'SNF',
                    'Amount',
                  ],
                  data: (summary['entries'] as List<MilkEntry>)
                      .map(
                        (entry) => [
                          _formatDate(entry.entryDate),
                          entry.shift,
                          entry.quantity.toStringAsFixed(2),
                          entry.fat.toStringAsFixed(2),
                          entry.snf.toStringAsFixed(2),
                          entry.totalAmount.toStringAsFixed(2),
                        ],
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'all_customers_summary.pdf',
    );
  }

  Future<void> generateTotalSummaryPdf(
    List<Map<String, dynamic>> summaries,
    String startDate,
    String endDate, {
    required bool lifetime,
  }) async {
    final pdf = pw.Document();
    double grandTotalMilk = summaries.fold(0, (sum, s) => sum + s['totalMilk']);
    double grandTotalAmount = summaries.fold(
      0,
      (sum, s) => sum + s['totalAmount'],
    );

    pdf.addPage(
      pw.Page(
        pageFormat: Constants.defaultPageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      Constants.ownerName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      Constants.dairyName,
                      style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
                    ),
                    pw.Text(
                      'Mob: ${Constants.mobileNumber}',
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'Grand Totals',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Total Milk: ${grandTotalMilk.toStringAsFixed(2)} L',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Text(
                          'Total Amount: Rs.${grandTotalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Title Section
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      lifetime
                          ? 'Lifetime Total Summary Report'
                          : 'Total Summary Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    if (!lifetime) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'From $startDate to $endDate',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Table Section
              pw.Text(
                'Customer Summaries',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Customer Name',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Customer ID',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Quantity',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Amount',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...summaries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final summary = entry.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0
                            ? PdfColors.white
                            : PdfColors.grey50,
                      ),
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            summary['name'].toString(),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            summary['customerId'].toString(),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            summary['totalMilk'].toStringAsFixed(2),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            'Rs.${summary['totalAmount'].toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Grand Totals',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Milk Quantity:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          '${grandTotalMilk.toStringAsFixed(2)} L',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Amount:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          'Rs.${grandTotalAmount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer
              pw.Spacer(),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Text(
                'Report generated by Aapni Dairy App',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'total_summary.pdf',
    );
  }

  // Method 1: Customer ID, Date, Shift, Quantity, Fat, Rate, Amount with totals
  Future<Uint8List> generateCustomerSummaryPdfMethod1(
    List<MilkEntry> entries,
    String customerName,
    String date,
  ) async {
    final pdf = pw.Document();
    double totalQuantity = entries.fold(
      0,
      (sum, entry) => sum + entry.quantity,
    );
    double totalAmount = entries.fold(
      0,
      (sum, entry) => sum + entry.totalAmount,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                Constants.dairyName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(Constants.ownerName),
              pw.Text('Mob: ${Constants.mobileNumber}'),
              pw.SizedBox(height: 20),
              pw.Text('Customer: $customerName'),
              pw.Text('Date: $date'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Customer ID',
                  'Date',
                  'Shift',
                  'Quantity',
                  'Fat',
                  'Rate',
                  'Amount',
                ],
                data: entries
                    .map(
                      (entry) => [
                        entry.customerCid.toString(),
                        _formatDate(entry.entryDate),
                        entry.shift,
                        entry.quantity.toStringAsFixed(2),
                        entry.fat.toStringAsFixed(2),
                        entry.rate.toStringAsFixed(2),
                        entry.totalAmount.toStringAsFixed(2),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Quantity: ${totalQuantity.toStringAsFixed(2)}'),
              pw.Text('Total Amount: ${totalAmount.toStringAsFixed(2)}'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Method 2: Customer ID, Date, Shift, Fat, SNF, Amount with totals
  Future<Uint8List> generateCustomerSummaryPdfMethod2(
    List<MilkEntry> entries,
    String customerName,
    String date,
  ) async {
    final pdf = pw.Document();
    double totalQuantity = entries.fold(
      0,
      (sum, entry) => sum + entry.quantity,
    );
    double totalAmount = entries.fold(
      0,
      (sum, entry) => sum + entry.totalAmount,
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                Constants.dairyName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(Constants.ownerName),
              pw.Text('Mob: ${Constants.mobileNumber}'),
              pw.SizedBox(height: 20),
              pw.Text('Customer: $customerName'),
              pw.Text('Date: $date'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Customer ID',
                  'Date',
                  'Shift',
                  'Fat',
                  'SNF',
                  'Amount',
                ],
                data: entries
                    .map(
                      (entry) => [
                        entry.customerCid.toString(),
                        _formatDate(entry.entryDate),
                        entry.shift,
                        entry.fat.toString(),
                        entry.snf.toString(),
                        entry.totalAmount.toString(),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total Quantity: $totalQuantity'),
              pw.Text('Total Amount: $totalAmount'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
