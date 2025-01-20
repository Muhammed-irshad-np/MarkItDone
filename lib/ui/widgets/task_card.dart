import 'package:flutter/material.dart';
import 'package:markitdone/config/theme.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime? dueDate;
  final String status;
  final bool fromCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onStatusChange;
  final VoidCallback? onReassign;

  const TaskCard({
    Key? key,
    required this.title,
    this.description = '',
    this.dueDate,
    required this.status,
    this.onTap,
    this.onStatusChange,
    this.onReassign,
    this.fromCompleted = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.completed;
      case 'in progress':
        return AppColors.inProgress;
      case 'postponed':
        return AppColors.postponed;
      default:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getStatusColor(),
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Visibility(
                    visible: !fromCompleted,
                    child: Checkbox(
                      value: status == 'completed',
                      onChanged: (bool? value) {
                        if (onStatusChange != null) onStatusChange!();
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !fromCompleted,
                    child: IconButton(
                      icon: const Icon(Icons.person_outline,
                          color: AppColors.darktextSecondary),
                      onPressed: onReassign,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (dueDate != null) ...[
                    _buildDueDate(context),
                    const SizedBox(width: 12),
                  ],
                  Visibility(
                      visible: !fromCompleted, child: _buildStatusChip()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.darktextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d, y').format(dueDate!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
