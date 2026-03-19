import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classModel;
  final bool isReserved;
  final VoidCallback? onTap;

  const ClassCard({
    super.key,
    required this.classModel,
    this.isReserved = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spotsColor = classModel.isFull
        ? AppTheme.error
        : classModel.availableSpots <= 3
            ? AppTheme.warning
            : AppTheme.success;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReserved
                ? AppTheme.primary.withOpacity(0.5)
                : const Color(0xFF2A2A2A),
            width: isReserved ? 1.5 : 1,
          ),
          boxShadow: isReserved
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.fitness_center,
                    color: AppTheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            classModel.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isReserved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Réservé',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: AppTheme.onSurfaceMuted),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('EEE dd MMM', 'fr_FR')
                              .format(classModel.date),
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_outlined,
                            size: 13, color: AppTheme.onSurfaceMuted),
                        const SizedBox(width: 4),
                        Text(
                          classModel.time,
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_outlined,
                            size: 13, color: AppTheme.onSurfaceMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${classModel.duration}min',
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 4,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: classModel.maxParticipants > 0
                                ? classModel.currentParticipants /
                                    classModel.maxParticipants
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: spotsColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          classModel.isFull
                              ? 'Complet'
                              : '${classModel.availableSpots} place(s)',
                          style: TextStyle(
                            color: spotsColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: onTap != null
                    ? AppTheme.onSurfaceMuted
                    : AppTheme.surfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
