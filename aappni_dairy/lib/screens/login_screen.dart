import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as models;
import '../services/auth_service.dart';
import '../constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dairyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isAgreed = false;
  bool _isPasswordVisible = false;

  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _mobileFieldOpacityAnimation;
  late Animation<Offset> _mobileFieldSlideAnimation;
  late Animation<double> _passwordFieldOpacityAnimation;
  late Animation<Offset> _passwordFieldSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
        );

    _mobileFieldOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _mobileFieldSlideAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
          ),
        );

    _passwordFieldOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
          ),
        );

    _passwordFieldSlideAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
          ),
        );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _mobileController.text = prefs.getString('mobileNumber') ?? '';
    _dairyNameController.text = prefs.getString('dairyName') ?? '';
    _ownerNameController.text = prefs.getString('ownerName') ?? '';
  }

  Future<void> _authenticate() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && !_isAgreed) {
      setState(() => _errorMessage = 'Please accept Terms & Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      late models.User user;

      if (_isLogin) {
        user = await _authService.signIn(
          _mobileController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        user = await _authService.signUp(
          _mobileController.text.trim(),
          _passwordController.text.trim(),
          dairyName: _dairyNameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          email: _emailController.text.trim(),
        );
      }

      await _saveDairyDetails(
        dairyName: user.dairyName,
        ownerName: user.ownerName,
        mobile: user.mobile,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            dairyName: Constants.dairyName,
            ownerName: Constants.ownerName,
            mobileNumber: Constants.mobileNumber,
          ),
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception:', '').trim();
      if (_isLogin &&
          (errorMessage.toLowerCase().contains('not found') ||
              errorMessage.toLowerCase().contains('does not exist') ||
              errorMessage.toLowerCase().contains('user not registered'))) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Not Found'),
            content: const Text(
              'Account does not Exist ! Please create your account.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isLogin = false;
                    _errorMessage = null;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _errorMessage = errorMessage;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDairyDetails({
    required String dairyName,
    required String ownerName,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('dairyName', dairyName);
    await prefs.setString('ownerName', ownerName);
    await prefs.setString('mobileNumber', mobile);

    Constants.dairyName = dairyName;
    Constants.ownerName = ownerName;
    Constants.mobileNumber = mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Very light blue
              Color(0xFFBBDEFB), // Light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),

                // App Logo with animation
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(
                      0xFF90CAF9,
                    ).withValues(alpha: 0.3), // Light blue
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeTransition(
                  opacity: _titleOpacityAnimation,
                  child: SlideTransition(
                    position: _titleSlideAnimation,
                    child: Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFF1565C0), // Dark blue
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _mobileFieldOpacityAnimation,
                  child: SlideTransition(
                    position: _mobileFieldSlideAnimation,
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                      ),
                      validator: (v) {
                        if (v == null || v.length != 10) {
                          return 'Enter 10 digit mobile number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                          return 'Only numbers allowed';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _passwordFieldOpacityAnimation,
                  child: SlideTransition(
                    position: _passwordFieldSlideAnimation,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (v) => v != null && v.length >= 8
                          ? null
                          : 'Minimum 8 characters',
                    ),
                  ),
                ),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dairyNameController,
                    decoration: InputDecoration(
                      labelText: 'Dairy Name',
                      prefixIcon: const Icon(Icons.business),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ownerNameController,
                    decoration: InputDecoration(
                      labelText: 'Owner Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.9),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  CheckboxListTile(
                    value: _isAgreed,
                    onChanged: (v) {
                      setState(() => _isAgreed = v ?? false);
                      if (v == true) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Terms & Conditions'),
                            content: const SingleChildScrollView(
                              child: Text(
                                'आपको अपना पासवर्ड याद रखना चाहिए। अगर ऐप डिलीट हो जाए या आप किसी दूसरे फोन में लॉग इन करें, तो पासवर्ड की ज़रूरत होगी। आप कोई भी 8 अंकों का पासवर्ड रख सकते हैं। अगर आपका DAIRY कोड 318 है, तो पासवर्ड 00000318 रखें। अगर आप भूल भी जाएँ, तो DAIRY कोड से आपको पासवर्ड याद आ जाएगा।\n\n'
                                'अगर आपके डेटा का नुकसान होता है, तो कंपनी ज़िम्मेदार नहीं होगी।\n'
                                'ऐप में किसी भी प्रकार की पेमेंट में गलती होने पर कंपनी या ऐप ज़िम्मेदार नहीं होगा।\n'
                                'ऐप में किसी भी तरह की गलती से अगर आपको नुकसान होता है, तो ऐप ज़िम्मेदार नहीं होगा।\n'
                                'हर चीज़ को डबल-चेक करें।\n\n'
                                '2130 GROUP',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    title: const Text(
                      'I agree to Terms & Conditions',
                      style: TextStyle(color: Colors.white),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 16),

                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2), // Light blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: const Color(
                          0xFF1976D2,
                        ).withValues(alpha: 0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _errorMessage = null;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Create a new account'
                        : 'Already have an account?',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _dairyNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
