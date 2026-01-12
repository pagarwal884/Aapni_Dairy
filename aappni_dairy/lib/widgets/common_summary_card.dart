import 'package:flutter/material.dart';

class CommonSummaryCard extends StatefulWidget {
  final String title;
  final double totalMilk;
  final double totalAmount;

  const CommonSummaryCard({
    super.key,
    required this.title,
    required this.totalMilk,
    required this.totalAmount,
  });

  @override
  State<CommonSummaryCard> createState() => _CommonSummaryCardState();
}

class _CommonSummaryCardState extends State<CommonSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getIconForTitle(String title) {
    if (title.toLowerCase().contains('morning')) {
      return Icons.wb_sunny; // Sun for morning
    } else if (title.toLowerCase().contains('evening')) {
      return Icons.nights_stay; // Moon for evening
    } else if (title.toLowerCase().contains('total')) {
      return Icons.analytics; // Analytics for total
    }
    return Icons.local_drink; // Default milk icon
  }

  Color _getColorForTitle(String title) {
    if (title.toLowerCase().contains('morning')) {
      return Colors.orange;
    } else if (title.toLowerCase().contains('evening')) {
      return Colors.indigo;
    } else if (title.toLowerCase().contains('total')) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForTitle(widget.title);
    final icon = _getIconForTitle(widget.title);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Card(
              elevation: 8,
              shadowColor: color.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Icon and Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 32, color: color),
                          const SizedBox(width: 12),
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Milk Amount with Animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.totalMilk),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              Text(
                                'Total Milk',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${value.toStringAsFixed(2)} L',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Amount with Animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.totalAmount),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
