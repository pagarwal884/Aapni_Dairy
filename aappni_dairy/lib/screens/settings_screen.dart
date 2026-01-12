// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../constants.dart';
import '../db/db_helper.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final Function(Locale)? onLocaleChanged;

  const SettingsScreen({super.key, this.onSaved, this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dairyNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _languageCardSlideAnimation;
  late Animation<Offset> _formSlideAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExistingData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _languageCardSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadExistingData() async {
    // Fetch from DB/API first
    final dairyDetails = await DatabaseHelper().getDairyDetails();

    setState(() {
      _dairyNameController.text = dairyDetails['dairyName'] ?? '';
      _ownerNameController.text = dairyDetails['ownerName'] ?? '';
      _mobileController.text = dairyDetails['mobileNumber'] ?? '';
    });

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dairyName', _dairyNameController.text);
    await prefs.setString('ownerName', _ownerNameController.text);
    await prefs.setString('mobileNumber', _mobileController.text);
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final dairyName = _dairyNameController.text;
    final ownerName = _ownerNameController.text;
    final mobileNumber = _mobileController.text;

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dairyName', dairyName);
    await prefs.setString('ownerName', ownerName);
    await prefs.setString('mobileNumber', mobileNumber);

    // Update Constants
    Constants.dairyName = dairyName;
    Constants.ownerName = ownerName;
    Constants.mobileNumber = mobileNumber;

    // Save to DB/API
    await DatabaseHelper().saveDairyDetails(
      dairyName: dairyName,
      ownerName: ownerName,
      mobileNumber: mobileNumber,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );

    widget.onSaved?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SlideTransition(
                  position: _languageCardSlideAnimation,
                  child: _buildLanguageCard(),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _formSlideAnimation,
                  child: _buildDairyForm(localizations),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: Colors.blue.shade800, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Language / भाषा / ਭਾਸ਼ਾ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildLanguageButton('English', const Locale('en')),
                  const SizedBox(width: 12),
                  _buildLanguageButton('हिंदी', const Locale('hi')),
                  const SizedBox(width: 12),
                  _buildLanguageButton('ਪੰਜਾਬੀ', const Locale('pa')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildLanguageButton(String label, Locale locale) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => widget.onLocaleChanged?.call(locale),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildDairyForm(AppLocalizations localizations) {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Colors.blue.shade800, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      localizations.editDairyDetails,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.pdfDetails,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  _dairyNameController,
                  localizations.dairyName,
                  localizations.enterDairyName,
                  Icons.business,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _ownerNameController,
                  localizations.ownerName,
                  localizations.enterOwnerName,
                  Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _mobileController,
                  localizations.mobileNumber,
                  localizations.enterMobileNumber,
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.length != 10)
                      return localizations.enterValidMobile;
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                _isSaving
                    ? Shimmer.fromColors(
                        baseColor: Colors.blue.shade300,
                        highlightColor: Colors.blue.shade100,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            'Saving...',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() => _isSaving = true);
                          await _saveData();
                          setState(() => _isSaving = false);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: Colors.blue.shade300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              localizations.saveSettings,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(
    TextEditingController controller,
    String label,
    String emptyError,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? emptyError : null,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _dairyNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}
