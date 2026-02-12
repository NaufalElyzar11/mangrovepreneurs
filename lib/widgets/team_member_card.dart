import 'package:flutter/material.dart';
import '../core/theme/mangrove_theme.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData? avatarIcon;
  final Color? avatarColor;
  final String? imagePath;
  
  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.avatarIcon,
    this.avatarColor,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAvatarColor = avatarColor ?? MangroveTheme.primaryGreen;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (imagePath != null)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: effectiveAvatarColor.withValues(alpha: 0.15),
                      child: Icon(
                        avatarIcon ?? Icons.person_outline,
                        color: effectiveAvatarColor,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: effectiveAvatarColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  avatarIcon ?? Icons.person_outline,
                  color: effectiveAvatarColor,
                  size: 28,
                ),
              ),
            const SizedBox(width: 14),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MangroveTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? imagePath;
  
  const TeamSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          if (imagePath != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: MangroveTheme.oliveGreen.withValues(alpha: 0.15),
                    child: Icon(
                      icon,
                      color: MangroveTheme.oliveGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MangroveTheme.oliveGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: MangroveTheme.oliveGreen,
                size: 20,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: MangroveTheme.oliveGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
