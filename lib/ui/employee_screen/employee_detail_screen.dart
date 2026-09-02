import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../framework/providers/provider/employee_provider.dart';
import '../../framework/repository/model/employee_model/employee_model.dart';
import '../helper/confirm_dialog.dart';
import '../helper/snackbar_helper.dart';
import 'add_edit_employee_screen.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final EmployeeModel employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _getInitials(employee.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditEmployeeScreen(employee: employee),
                ),
              );
              if (result == true && context.mounted) {
                SnackbarHelper.showSuccess(
                    context, 'Employee updated successfully!');
                Navigator.pop(context, true);
              }
            },
            tooltip: 'Edit',
          ),
          if (employee.id != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Delete Employee',
                  message:
                      'Are you sure you want to delete "${employee.name}"?',
                  confirmLabel: 'Delete',
                  icon: Icons.delete_forever_rounded,
                );

                if (!confirmed || !context.mounted) return;
                final success = await ref
                    .read(employeeProvider)
                    .deleteEmployee(employee.id!);
                if (!context.mounted) return;
                if (success) {
                  SnackbarHelper.showSuccess(
                      context, 'Employee deleted successfully!');
                  Navigator.pop(context, true);
                } else {
                  SnackbarHelper.showError(
                      context,
                      ref.read(employeeProvider).crudErrorMessage ??
                          'Delete failed');
                }
              },
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    employee.name,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                    textAlign: TextAlign.center,
                  ),
                  if (employee.id != null)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${employee.id}',
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Contact Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: employee.email,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Mobile',
                      value: employee.mobile,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Country',
                      value: employee.country,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.map_outlined,
                      label: 'State',
                      value: employee.state,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.location_city_outlined,
                      label: 'District',
                      value: employee.district,
                    ),
                  ],
                ),
              ),
            ),

            if (employee.createdAt != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created At',
                    value: _formatDate(employee.createdAt!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '-',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
