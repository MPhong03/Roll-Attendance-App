import 'package:flutter/material.dart';

class EventPreviewModal extends StatelessWidget {
  final String eventName;
  final DateTime? startTime;
  final DateTime? endTime;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EventPreviewModal({
    Key? key,
    required this.eventName,
    this.startTime,
    this.endTime,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AlertDialog(
      title: Text(
        eventName,
        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "START: ${startTime != null ? startTime?.toLocal().toString() : 'UNAVAILABLE'}",
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_filled,
                  color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "END: ${endTime != null ? endTime?.toLocal().toString() : 'UNAVAILABLE'}",
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text("Cancel"),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onError,
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text("Activate"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
