import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../framework/data/status_enum.dart';
import '../../framework/providers/provider/employee_provider.dart';
import '../../framework/repository/model/employee_model/employee_model.dart';
import '../helper/snackbar_helper.dart';
import 'employee_detail_screen.dart';

class SearchEmployeeScreen extends ConsumerStatefulWidget {
  const SearchEmployeeScreen({super.key});

  @override
  ConsumerState<SearchEmployeeScreen> createState() =>
      _SearchEmployeeScreenState();
}

class _SearchEmployeeScreenState extends ConsumerState<SearchEmployeeScreen> {
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider).setSelectedEmployee(null);
      ref.read(employeeProvider).clearCrudStatus();
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      SnackbarHelper.showInfo(context, 'Please enter an employee ID');
      return;
    }

    // Clear previous result before searching
    ref.read(employeeProvider).setSelectedEmployee(null);
    ref.read(employeeProvider).clearCrudStatus();

    await ref.read(employeeProvider).fetchEmployeeById(id);

    if (!mounted) return;
    final notifier = ref.read(employeeProvider);
    if (notifier.crudStatus == StatusEnum.error) {
      SnackbarHelper.showError(
        context,
        notifier.crudErrorMessage ?? 'Employee not found',
      );
    } else if (notifier.selectedEmployee != null) {
      // Navigate to detail screen on success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmployeeDetailScreen(employee: notifier.selectedEmployee!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(employeeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search by ID')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Input row ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Employee ID',
                      hintText: 'e.g. 1',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: notifier.isCrudLoading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(64, 56),
                    ),
                    child: notifier.isCrudLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── State area ───────────────────────────────────────────────
            Expanded(child: _buildState(notifier, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildState(EmployeeNotifier notifier, ColorScheme colorScheme) {
    // Loading
    if (notifier.isCrudLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    // Error
    if (notifier.crudStatus == StatusEnum.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 72,
              color: colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Employee not found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              notifier.crudErrorMessage ?? 'No employee with that ID exists',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Success — show inline result card
    if (notifier.selectedEmployee != null) {
      return _ResultCard(
        employee: notifier.selectedEmployee!,
        onViewDetails: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EmployeeDetailScreen(employee: notifier.selectedEmployee!),
          ),
        ),
      );
    }

    // Initial / idle state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.manage_search_rounded,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter an ID to search',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Find any employee by their numeric ID',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline result card ────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onViewDetails;

  const _ResultCard({required this.employee, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _initials(employee.name);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Found label
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Employee found',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar + name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (employee.id != null)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'ID: ${employee.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Details
                  _InfoRow(Icons.email_outlined, 'Email', employee.email),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.phone_outlined, 'Mobile', employee.mobile),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.flag_outlined, 'Country', employee.country),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.map_outlined, 'State', employee.state),
                  const SizedBox(height: 10),
                  _InfoRow(
                    Icons.location_city_outlined,
                    'District',
                    employee.district,
                  ),
                  const SizedBox(height: 20),

                  // View details button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('View Full Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value.isNotEmpty ? value : '—'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
