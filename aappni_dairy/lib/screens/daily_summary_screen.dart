import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aapni_dairy/widgets/custom_date_picker.dart';
import 'package:aapni_dairy/widgets/common_summary_card.dart';
import 'package:aapni_dairy/models/milk_entry.dart';
import 'package:aapni_dairy/services/api_service.dart';
import 'package:shimmer/shimmer.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  _DailySummaryScreenState createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  DateTime _selectedDate = DateTime.now();
  double _morningMilk = 0;
  double _morningAmount = 0;
  double _eveningMilk = 0;
  double _eveningAmount = 0;
  double _totalMilk = 0;
  double _totalAmount = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> _fetchSummary() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _retryCount = 0;
    });

    try {
      String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final List<MilkEntry> entries = await _api.getAllEntriesForUser();

      double morningMilk = 0;
      double morningAmount = 0;
      double eveningMilk = 0;
      double eveningAmount = 0;

      for (var entry in entries) {
        try {
          final entryDate = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.parse(entry.entryDate));

          if (entryDate == dateStr) {
            if (entry.shift == 'Morning') {
              morningMilk += entry.quantity;
              morningAmount += entry.totalAmount;
            } else if (entry.shift == 'Evening') {
              eveningMilk += entry.quantity;
              eveningAmount += entry.totalAmount;
            }
          }
        } catch (e) {
          // Skip entries with invalid date format
          continue;
        }
      }

      setState(() {
        _morningMilk = morningMilk;
        _morningAmount = morningAmount;
        _eveningMilk = eveningMilk;
        _eveningAmount = eveningAmount;
        _totalMilk = morningMilk + eveningMilk;
        _totalAmount = morningAmount + eveningAmount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _fetchSummary: $e');
      if (_retryCount < 2) {
        _retryCount++;
        print('Retrying... attempt $_retryCount');
        await Future.delayed(const Duration(seconds: 1));
        return _fetchSummary();
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load summary: ${e.toString()}';
      });
    }
  }

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
    _fetchSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
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
                            child: CustomDatePicker(
                              selectedDate: _selectedDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedDate = date;
                                });
                                _fetchSummary();
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Summary Cards with Staggered Animation
                Expanded(
                  child: _isLoading
                      ? _buildShimmerLoading()
                      : _hasError
                      ? _buildErrorWidget()
                      : RefreshIndicator(
                          onRefresh: _fetchSummary,
                          color: Colors.blue.shade700,
                          child: ListView(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value.clamp(0.0, 1.0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: CommonSummaryCard(
                                        title: 'Morning Shift',
                                        totalMilk: _morningMilk,
                                        totalAmount: _morningAmount,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value.clamp(0.0, 1.0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: CommonSummaryCard(
                                        title: 'Evening Shift',
                                        totalMilk: _eveningMilk,
                                        totalAmount: _eveningAmount,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value.clamp(0.0, 1.0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: CommonSummaryCard(
                                        title: 'Total Summary',
                                        totalMilk: _totalMilk,
                                        totalAmount: _totalAmount,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                        ),
                ),
                ),
           ] ),
        ),
      ),
    ));
  }

  Widget _buildShimmerLoading() {
    return ListView(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 32, height: 32, color: Colors.white),
                      const SizedBox(width: 12),
                      Container(width: 120, height: 20, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(width: 80, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 24, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(width: 80, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 90, height: 22, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 32, height: 32, color: Colors.white),
                      const SizedBox(width: 12),
                      Container(width: 120, height: 20, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(width: 80, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 100, height: 24, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(width: 80, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 90, height: 22, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSummary,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
