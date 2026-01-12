import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/auth_service.dart';
import 'db/db_helper.dart';
import 'screens/customer_registration_screen.dart';
import 'screens/milk_entry_screen.dart';
import 'screens/edit_delete_entries_screen.dart';
import 'screens/edit_rate_screen.dart';
import 'screens/daily_summary_screen.dart';
import 'screens/customer_summary_pdf_screen.dart';
import 'screens/export_total_pdf_screen.dart';
import 'screens/export_customer_pdf_screen.dart';
import 'screens/total_summary_pdf_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/how_to_use_screen.dart';
import 'l10n/app_localizations.dart';
import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Caught Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String _dairyName = Constants.dairyName;
  String _ownerName = Constants.ownerName;
  String _mobileNumber = Constants.mobileNumber;
  Locale _locale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _initializeApp();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  void _changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Starting app initialization...');
      final authService = AuthService();
      final user = authService.currentUser;

      debugPrint('Current user: ${user ?? 'null'}');

      if (user != null) {
        await _loadDairyDetails();
        setState(() {
          _isLoggedIn = true;
          _isInitialized = true;
        });
        debugPrint('App initialized: showing home screen');
      } else {
        setState(() {
          _isLoggedIn = false;
          _isInitialized = true;
        });
        debugPrint('No user logged in, showing login screen');
      }
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      setState(() {
        _isLoggedIn = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadDairyDetails() async {
    try {
      final dairyDetails = await DatabaseHelper().getDairyDetails();
      setState(() {
        _dairyName = dairyDetails['dairyName'] ?? Constants.dairyName;
        _ownerName = dairyDetails['ownerName'] ?? Constants.ownerName;
        _mobileNumber = dairyDetails['mobileNumber'] ?? Constants.mobileNumber;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dairyName', _dairyName);
      await prefs.setString('ownerName', _ownerName);
      await prefs.setString('mobileNumber', _mobileNumber);

      Constants.dairyName = _dairyName;
      Constants.ownerName = _ownerName;
      Constants.mobileNumber = _mobileNumber;
    } catch (e) {
      debugPrint('Error loading dairy details: $e');
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _dairyName = prefs.getString('dairyName') ?? Constants.dairyName;
        _ownerName = prefs.getString('ownerName') ?? Constants.ownerName;
        _mobileNumber =
            prefs.getString('mobileNumber') ?? Constants.mobileNumber;
      });

      Constants.dairyName = _dairyName;
      Constants.ownerName = _ownerName;
      Constants.mobileNumber = _mobileNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'AAPNI DAIRY',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Initializing AAPNI DAIRY...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'AAPNI DAIRY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('pa')],
      home: _isLoggedIn
          ? HomeScreen(
              dairyName: _dairyName,
              ownerName: _ownerName,
              mobileNumber: _mobileNumber,
            )
          : const LoginScreen(),
      routes: {
        '/customer_registration': (context) =>
            const CustomerRegistrationScreen(),
        '/milk_entry': (context) => const MilkEntryScreen(),
        '/edit_delete_entries': (context) => EditDeleteEntriesScreen(),

        '/edit_rate': (context) => const EditRateScreen(userId: ''),
        '/daily_summary': (context) => const DailySummaryScreen(),
        '/customer_summary_pdf': (context) => const CustomerSummaryPdfScreen(),
        '/export_total_pdf': (context) => ExportTotalPdfScreen(),
        '/export_customer_pdf': (context) => ExportCustomerPdfScreen(),
        '/total_summary_pdf': (context) => const TotalSummaryPdfScreen(),
        '/settings': (context) =>
            SettingsScreen(onLocaleChanged: _changeLocale),
        '/about_us': (context) => const AboutUsScreen(),
        '/how_to_use': (context) => const HowToUseScreen(),
      },
    );
  }
}

// Enhanced AboutUsScreen with animations and detailed content
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.aboutUs),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Title with animation
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Text(
                            'About Us: Aapni Dairy 🤝',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Welcome content
                    _buildAnimatedCard(
                      child: Text(
                        "Welcome to 'Aapni Dairy'—an app born not from theory, but from the solid, real-world experience of 20 years in dairy management by HRB Dairy, Kheda Rampura.\n\nWe created this app to eliminate the common headaches of manual collection and accounting, making the entire dairy process simple, transparent, and accurate.",
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Expertise section
                    _buildAnimatedCard(
                      child: Column(
                        children: [
                          Text(
                            '🌟 Our Expertise and Trust',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "'Aapni Dairy' is built on practical needs and proven reliability:\n\n• 15 Years of Experience: The app is a result of HRB Dairy's deep, 15-year understanding of the dairy collection ecosystem.\n\n• Tested Reliability: It has been successfully operating across 10-12 HRB Dairy centers for the past 6 months, ensuring accuracy and saving significant time.\n\n• Pinpoint Accuracy: It makes all milk calculations (FAT, SNF, payments) precise, drastically reducing errors.\n\n• Why the Name 'Aapni Dairy'?: We named it 'Aapni Dairy' (Your Own Dairy) because we want every user to feel empowered to store and manage their dairy data securely and conveniently, just like it's their very own setup.\n\nOur goal is simple: To provide a digital solution you can trust, proven by our own extensive operational experience.",
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Team section
                    _buildAnimatedCard(
                      child: Column(
                        children: [
                          Text(
                            'HRB Dairy Kheda Rampura Team',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'HRB Dairy Team:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildTeamMember('Pannaramji Yadav(Founder)'),
                          _buildTeamMember(
                            'Mahesh Kumar Yadav (20+ years experience)',
                          ),
                          _buildTeamMember(
                            'Suresh Kumar Yadav (Marketing Head)',
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Online Marketing Team:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildTeamMember('Ramesh Kumar Yadav'),
                          _buildTeamMember('Rahul Yadav'),
                          _buildTeamMember('Nitin Yadav'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Social links section
                    _buildAnimatedCard(
                      child: Column(
                        children: [
                          Text(
                            'Follow Our Journey',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You can follow us on social media to stay updated with our latest news and updates',
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildSocialLink(
                            'Instagram',
                            'https://www.instagram.com/aapni.dairy?igsh=MWxpbXYzNmdsanN3Ng==',
                            Icons.camera_alt,
                            Colors.pink,
                          ),
                          const SizedBox(height: 10),
                          _buildSocialLink(
                            'Facebook',
                            'https://www.facebook.com/share/1D6Kf7nZa3/',
                            Icons.facebook,
                            Colors.blue,
                          ),
                          const SizedBox(height: 10),
                          _buildSocialLink(
                            'WhatsApp',
                            'https://whatsapp.com/channel/0029VbB4m2b5PO0uSvtgbJ43',
                            Icons.message,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Version info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      
                )],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTeamMember(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildSocialLink(
    String platform,
    String url,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not open $platform')));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              platform,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
