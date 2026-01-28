import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               FittedBox(
                 fit: BoxFit.scaleDown,
                 alignment: Alignment.centerLeft,
                 child: Text(
                   value,
                   style: theme.textTheme.headlineSmall?.copyWith(
                     fontWeight: ThemeTokens.fontWeightBold,
                     color: theme.colorScheme.onSurface,
                     fontSize: 22,
                   ),
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 title,
                 style: theme.textTheme.bodyMedium?.copyWith(
                   color: theme.colorScheme.onSurfaceVariant,
                   fontSize: 12,
                 ),
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
               ),
             ],
          ),
        ],
      ),
    );
  }
}
