import 'package:flutter/material.dart';

/// Role Badge Widget - menampilkan role user dengan style cantik
class RoleBadge extends StatelessWidget {
  final String role;
  final bool compact; // true: icon only, false: text + icon
  final Color? customColor;
  final VoidCallback? onTap;

  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
    this.customColor,
    this.onTap,
  });

  /// Get color berdasarkan role
  Color _getRoleColor() {
    if (customColor != null) return customColor!;

    switch (role.toLowerCase()) {
      case 'kader':
        return const Color(0xFF2196F3); // Blue
      case 'admin':
        return const Color(0xFFD32F2F); // Red (higher privilege)
      case 'simpatisan':
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get icon berdasarkan role
  IconData _getRoleIcon() {
    switch (role.toLowerCase()) {
      case 'kader':
        return Icons.verified;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'simpatisan':
      default:
        return Icons.person;
    }
  }

  /// Get display text
  String _getRoleDisplayText() {
    switch (role.toLowerCase()) {
      case 'kader':
        return 'KADER';
      case 'admin':
        return 'ADMIN';
      case 'simpatisan':
      default:
        return 'SIMPATISAN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor();
    final icon = _getRoleIcon();
    final displayText = _getRoleDisplayText();

    if (compact) {
      // Compact: icon only
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      );
    }

    // Full badge: icon + text
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              displayText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Role Status Card - untuk profile section
class RoleStatusCard extends StatelessWidget {
  final String role;
  final DateTime? verifiedSince;
  final bool isVerified;

  const RoleStatusCard({
    super.key,
    required this.role,
    this.verifiedSince,
    this.isVerified = true,
  });

  /// Get color berdasarkan role
  Color _getRoleColor() {
    switch (role.toLowerCase()) {
      case 'kader':
        return const Color(0xFF2196F3);
      case 'admin':
        return const Color(0xFFD32F2F);
      case 'simpatisan':
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Get icon berdasarkan role
  IconData _getRoleIcon() {
    switch (role.toLowerCase()) {
      case 'kader':
        return Icons.verified;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'simpatisan':
      default:
        return Icons.person;
    }
  }

  /// Get display text
  String _getRoleDisplayText() {
    switch (role.toLowerCase()) {
      case 'kader':
        return 'KADER ✓';
      case 'admin':
        return 'ADMIN';
      case 'simpatisan':
      default:
        return 'SIMPATISAN';
    }
  }

  /// Format verified date
  String _formatVerifiedDate() {
    if (verifiedSince == null) return 'N/A';

    final now = DateTime.now();
    final diff = now.difference(verifiedSince!);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Hari ini';
      }
      return '${diff.inHours}h lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d lalu';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w lalu';
    } else {
      return '${verifiedSince!.day}/${verifiedSince!.month}/${verifiedSince!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor();
    final icon = _getRoleIcon();
    final displayText = _getRoleDisplayText();
    final verifiedDate = _formatVerifiedDate();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Status Akun',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Status row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (isVerified && verifiedSince != null)
                      Text(
                        'Terverifikasi: $verifiedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    else if (!isVerified)
                      Text(
                        'Menunggu verifikasi admin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Role Indicator Strip - thin vertical line indicator
class RoleIndicatorStrip extends StatelessWidget {
  final String role;
  final double width;
  final double height;

  const RoleIndicatorStrip({
    super.key,
    required this.role,
    this.width = 3,
    this.height = double.infinity,
  });

  Color _getRoleColor() {
    switch (role.toLowerCase()) {
      case 'kader':
        return const Color(0xFF2196F3);
      case 'admin':
        return const Color(0xFFD32F2F);
      case 'simpatisan':
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: _getRoleColor(),
    );
  }
}

/// Floating Role Badge - untuk card
class FloatingRoleBadge extends StatelessWidget {
  final String role;

  const FloatingRoleBadge({
    super.key,
    required this.role,
  });

  Color _getRoleColor() {
    switch (role.toLowerCase()) {
      case 'kader':
        return const Color(0xFF2196F3);
      case 'admin':
        return const Color(0xFFD32F2F);
      case 'simpatisan':
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getRoleIcon() {
    switch (role.toLowerCase()) {
      case 'kader':
        return Icons.verified;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'simpatisan':
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayText() {
    switch (role.toLowerCase()) {
      case 'kader':
        return 'KADER';
      case 'admin':
        return 'ADMIN';
      case 'simpatisan':
      default:
        return 'SIMPATISAN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRoleIcon(), color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            _getRoleDisplayText(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
