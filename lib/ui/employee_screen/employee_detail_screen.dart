import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/employees/domain/entities/employee.dart';
import '../../features/employees/presentation/bloc/employee_cubit.dart';
import '../../features/employees/presentation/bloc/employee_state.dart';
import '../helper/confirm_dialog.dart';
import '../helper/snackbar_helper.dart';
import 'add_edit_employee_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _initials(employee.name);

    return BlocConsumer<EmployeeCubit, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeCrudSuccess) {
          SnackbarHelper.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is EmployeeCrudError) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Employee Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () async {
                final cubit = context.read<EmployeeCubit>();
                final result = await Navigator.push<Employee?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child:
                          AddEditEmployeeScreen(employee: employee),
                    ),
                  ),
                );
                if (result != null && context.mounted) {
                  SnackbarHelper.showSuccess(
                      context, 'Employee updated successfully!');
                  Navigator.pop(context, true);
                }
              },
            ),
            if (employee.id != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
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
                  context
                      .read<EmployeeCubit>()
                      .delete(employee.id!);
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(initials,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary)),
                    ),
                    const SizedBox(height: 16),
                    Text(employee.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    if (employee.id != null)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('ID: ${employee.id}',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _card(context, 'Contact Information', [
                _Row(Icons.email_outlined, 'Email', employee.email),
                _Row(Icons.phone_outlined, 'Mobile', employee.mobile),
              ]),
              const SizedBox(height: 12),
              _card(context, 'Location', [
                _Row(Icons.flag_outlined, 'Country', employee.country),
                _Row(Icons.map_outlined, 'State', employee.state),
                _Row(Icons.location_city_outlined, 'District',
                    employee.district),
              ]),
              if (employee.createdAt != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _Row(
                        Icons.calendar_today_outlined,
                        'Created At',
                        _fmt(employee.createdAt!)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext ctx, String title, List<Widget> rows) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Divider(height: 20),
              ...rows.expand((w) => [w, const SizedBox(height: 14)]).toList()
                ..removeLast(),
            ],
          ),
        ),
      );

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return '${p[0][0]}${p[1][0]}'.toUpperCase();
  }

  String _fmt(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return d;
    }
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value.isNotEmpty ? value : '-',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      );
}
