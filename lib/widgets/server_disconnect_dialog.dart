import 'package:flutter/material.dart';

/// Dialog untuk menampilkan status server disconnect/maintenance
class ServerDisconnectDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool isDismissible;

  const ServerDisconnectDialog({
    super.key,
    this.title = 'Server Tidak Terkoneksi',
    this.message = 'Mohon periksa koneksi internet atau coba lagi nanti',
    this.actionButtonText = 'Coba Lagi',
    this.onActionPressed,
    this.secondaryButtonText = 'Keluar',
    this.onSecondaryPressed,
    this.isDismissible = false,
  });

  @override
  State<ServerDisconnectDialog> createState() => _ServerDisconnectDialogState();
}

class _ServerDisconnectDialogState extends State<ServerDisconnectDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated disconnect icon
              _buildDisconnectIcon(),
              const SizedBox(height: 24),
              
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              
              // Buttons
              Row(
                children: [
                  // Secondary button (optional)
                  if (widget.secondaryButtonText != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onSecondaryPressed ??
                            () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.secondaryButtonText!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  
                  if (widget.secondaryButtonText != null)
                    const SizedBox(width: 12),
                  
                  // Primary action button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        widget.actionButtonText ?? 'Coba Lagi',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated disconnect icon
  Widget _buildDisconnectIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red[50],
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main icon
          Icon(
            Icons.cloud_off,
            size: 48,
            color: Colors.red[600],
          ),
          
          // Pulse animation effect
          if (_animationController.isAnimating)
            Positioned(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 80 + (_animationController.value * 20),
                    height: 80 + (_animationController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(
                          (1 - _animationController.value) * 0.5,
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget convenience function untuk show dialog
void showServerDisconnectDialog(
  BuildContext context, {
  String title = 'Server Tidak Terkoneksi',
  String message = 'Mohon periksa koneksi internet atau coba lagi nanti',
  String? actionButtonText = 'Coba Lagi',
  VoidCallback? onActionPressed,
  String? secondaryButtonText = 'Keluar',
  VoidCallback? onSecondaryPressed,
  bool isDismissible = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) => ServerDisconnectDialog(
      title: title,
      message: message,
      actionButtonText: actionButtonText,
      onActionPressed: onActionPressed ?? () => Navigator.pop(context),
      secondaryButtonText: secondaryButtonText,
      onSecondaryPressed: onSecondaryPressed,
      isDismissible: isDismissible,
    ),
  );
}

/// Maintenance mode dialog variant
void showMaintenanceDialog(BuildContext context) {
  showServerDisconnectDialog(
    context,
    title: 'Mode Maintenance',
    message: 'Server sedang dalam pemeliharaan. Silakan coba lagi nanti.',
    actionButtonText: 'Coba Lagi',
    onActionPressed: () {
      Navigator.pop(context);
      // User bisa click retry button
    },
    secondaryButtonText: 'Keluar',
  );
}
