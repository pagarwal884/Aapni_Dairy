import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';

class EditRateScreen extends StatefulWidget {
  final String userId;

  const EditRateScreen({super.key, required this.userId});

  @override
  _EditRateScreenState createState() => _EditRateScreenState();
}

class _EditRateScreenState extends State<EditRateScreen>
    with TickerProviderStateMixin {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _cardASlideAnimation;
  late Animation<Offset> _cardBSlideAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
        );

    _cardASlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
          ),
        );

    _cardBSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
          ),
        );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _loadFromServer();
  }

  // ********** FETCH FROM MONGODB **********
  Future<void> _loadFromServer() async {
    try {
      final res = await _apiService.getAB();

      final double? a = (res['a'] as num?)?.toDouble();
      final double? b = (res['b'] as num?)?.toDouble();

      setState(() {
        _aController.text = a?.toString() ?? '';
        _bController.text = b?.toString() ?? '';
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load values: $e')));
    }
  }

  // ********** UPDATE ON SERVER **********
  void _saveConstants() async {
    // Trigger button scale animation
    _buttonController.forward().then((_) => _buttonController.reverse());

    final double? a = double.tryParse(_aController.text);
    final double? b = double.tryParse(_bController.text);

    if (a == null || b == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _apiService.updateAB(a, b);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Constants updated successfully')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update constants: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Rate'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 53, 164, 255),
              Color.fromARGB(255, 30, 62, 247),
              Color.fromARGB(255, 235, 235, 237),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 200, height: 30, color: Colors.white),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _titleSlideAnimation,
                        child: const Text(
                          'Adjust Rate Constants',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The rate is calculated using the formula:\nRATE = A * FAT + B\n\nExample: RATE = 8 * FAT + 2',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SlideTransition(
                        position: _cardASlideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: _aController,
                                  decoration: const InputDecoration(
                                    labelText: 'Constant A',
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 21, 145, 222),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.calculate,
                                      color: Color.fromARGB(255, 66, 111, 223),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 65, 119, 235),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _cardBSlideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: _bController,
                                  decoration: const InputDecoration(
                                    labelText: 'Constant B',
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 43, 49, 232),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.calculate,
                                      color: Color.fromARGB(255, 55, 155, 236),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 84, 117, 238),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SlideTransition(
                        position: _buttonSlideAnimation,
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: _isSaving
                                ? Matrix4.diagonal3Values(0.9, 0.9, 1.0)
                                : Matrix4.identity(),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color.fromARGB(255, 97, 175, 76), Colors.lightGreen],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveConstants,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isSaving
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Save Constants',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
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
