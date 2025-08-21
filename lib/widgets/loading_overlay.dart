import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 1.seconds),
              const SizedBox(height: 16),
              Text(
                message ?? 'Carregando...',
                style: AppTheme.body1.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}
