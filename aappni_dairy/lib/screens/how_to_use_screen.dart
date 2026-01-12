import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({super.key});

  @override
  _HowToUseScreenState createState() => _HowToUseScreenState();
}

class _HowToUseScreenState extends State<HowToUseScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create staggered animations for 6 sections
    _fadeAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            (index + 1) * 0.15,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(6, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            (index + 1) * 0.15,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.howToUse),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              FadeTransition(
                opacity: _fadeAnimations[0],
                child: SlideTransition(
                  position: _slideAnimations[0],
                  child: Center(
                    child: Text(
                      localizations.howToUse,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.blue.shade200,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Introduction
              FadeTransition(
                opacity: _fadeAnimations[1],
                child: SlideTransition(
                  position: _slideAnimations[1],
                  child: _buildSection(
                    title: 'Getting Started',
                    icon: Icons.rocket_launch,
                    content:
                        'Welcome to AAPNI DAIRY! This guide will help you understand how to use the app effectively for managing your dairy operations.',
                  ),
                ),
              ),

              // Features
              FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: _slideAnimations[2],
                  child: _buildSection(
                    title: 'Key Features',
                    icon: Icons.star,
                    content: '',
                    children: [
                      _buildStep(
                        'Customer Registration',
                        'Register new customers with their details.',
                      ),
                      _buildStep(
                        'Milk Entry',
                        'Record daily milk collections from customers.',
                      ),
                      _buildStep(
                        'Edit/Delete Entries',
                        'Modify or remove existing milk entries.',
                      ),
                      _buildStep('Edit Rate', 'Update milk rates and pricing.'),
                      _buildStep(
                        'Daily Summary',
                        'View daily milk collection summaries.',
                      ),
                      _buildStep(
                        'PDF Exports',
                        'Generate and export various PDF reports.',
                      ),
                      _buildStep(
                        'Settings',
                        'Configure dairy details and preferences.',
                      ),
                    ],
                  ),
                ),
              ),

              // Step-by-step guide
              FadeTransition(
                opacity: _fadeAnimations[3],
                child: SlideTransition(
                  position: _slideAnimations[3],
                  child: _buildSection(
                    title: 'Step-by-Step Guide',
                    icon: Icons.list_alt,
                    content: '',
                    children: [
                      _buildStep(
                        '1. Setup',
                        'First, go to Settings to enter your dairy name, owner name, and mobile number. This information will appear on all PDF exports.',
                      ),
                      _buildStep(
                        '2. Register Customers',
                        'Use Customer Registration to add new customers. Enter their name, mobile number, and other details.',
                      ),
                      _buildStep(
                        '3. Record Milk Entries',
                        'Daily, use Milk Entry to record milk quantity, FAT, SNF, and other parameters for each customer.',
                      ),
                      _buildStep(
                        '4. Manage Entries',
                        'Use Edit/Delete Entries to modify or remove incorrect entries.',
                      ),
                      _buildStep(
                        '5. Adjust Rates',
                        'Update milk rates in Edit Rate if needed.',
                      ),
                      _buildStep(
                        '6. View Summaries',
                        'Check Daily Summary for daily collections and totals.',
                      ),
                      _buildStep(
                        '7. Export Reports',
                        'Generate PDF reports using Customer Summary PDF, Export Total PDF, Total Summary PDF, or Export Customer PDF.',
                      ),
                    ],
                  ),
                ),
              ),

              // Tips
              FadeTransition(
                opacity: _fadeAnimations[4],
                child: SlideTransition(
                  position: _slideAnimations[4],
                  child: _buildSection(
                    title: 'Tips',
                    icon: Icons.lightbulb,
                    content: '',
                    children: [
                      _buildTip(
                        'Always verify customer details before registration.',
                      ),
                      _buildTip('Double-check milk entry data for accuracy.'),
                      _buildTip(
                        'Regularly backup your data (app works offline).',
                      ),
                      _buildTip(
                        'Use PDF exports for record-keeping and sharing.',
                      ),
                    ],
                  ),
                ),
              ),

              // Support
              FadeTransition(
                opacity: _fadeAnimations[5],
                child: SlideTransition(
                  position: _slideAnimations[5],
                  child: _buildSection(
                    title: 'Need Help?',
                    icon: Icons.help,
                    content:
                        'If you encounter any issues or have questions, please contact our support team through our social media channels.',
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    IconData? icon,
    required String content,
    List<Widget>? children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 16, top: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_circle, color: Colors.white, size: 16),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
