import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../framwork/data/status_enum.dart';
import '../../framwork/providers/provider/auth_provider.dart';
import '../../framwork/providers/provider/employee_provider.dart';
import '../../framwork/providers/provider/theme_provider.dart';
import '../../framwork/repository/model/employee_model/employee_model.dart';
import '../country_screen/country_list_screen.dart';
import '../auth_screen/login_screen.dart';
import '../helper/confirm_dialog.dart';
import '../helper/employee_card.dart';
import '../helper/empty_state_widget.dart';
import '../helper/error_widget.dart';
import '../helper/loading_widget.dart';
import '../helper/snackbar_helper.dart';
import 'add_edit_employee_screen.dart';
import 'employee_detail_screen.dart';
import 'search_employee_screen.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() =>
      _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  final _filterOptions = ['name', 'email', 'mobile', 'country', 'id'];
  final _filterLabels = {
    'name': 'Name',
    'email': 'Email',
    'mobile': 'Mobile',
    'country': 'Country',
    'id': 'ID',
  };
  final _filterIcons = {
    'name': Icons.person_outline_rounded,
    'email': Icons.email_outlined,
    'mobile': Icons.phone_outlined,
    'country': Icons.flag_outlined,
    'id': Icons.badge_outlined,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider).fetchAllEmployees();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(employeeProvider).fetchAllEmployees();
  }

  Future<void> _deleteEmployee(EmployeeModel employee) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Employee',
      message:
          'Are you sure you want to delete "${employee.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed || !mounted) return;

    final success =
        await ref.read(employeeProvider).deleteEmployee(employee.id!);
    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, 'Employee deleted successfully!');
    } else {
      final error =
          ref.read(employeeProvider).crudErrorMessage ?? 'Delete failed';
      SnackbarHelper.showError(context, error);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      confirmColor: Colors.orange,
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !mounted) return;
    await ref.read(authProvider).signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfileSheet() {
    final user = ref.read(authProvider).user;
    final themeNotifier = ref.read(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final initials = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : user?.email?[0] ?? 'U')
        .toUpperCase();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: user?.photoURL != null
                      ? CachedNetworkImageProvider(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(
                          initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  user?.displayName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
                const SizedBox(height: 24),

                // Divider
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Theme toggle tile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      themeNotifier.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    themeNotifier.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    themeNotifier.isDarkMode
                        ? 'Switch to light theme'
                        : 'Switch to dark theme',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  ),
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (_) {
                      ref.read(themeProvider).toggleTheme();
                      setSheetState(() {});
                    },
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 8),

                // Sign out tile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    _signOut();
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.logout_rounded,
                        color: colorScheme.error, size: 20),
                  ),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: colorScheme.error),
                  ),
                  subtitle: Text(
                    'Log out of your account',
                    style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.45)),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: colorScheme.error.withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeNotifier = ref.watch(employeeProvider);
    final authNotifier = ref.watch(authProvider);
    final user = authNotifier.user;
    final colorScheme = Theme.of(context).colorScheme;

    final initials = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : user?.email?[0] ?? 'U')
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          // Countries
          IconButton(
            icon: const Icon(Icons.public_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CountryListScreen()),
            ),
            tooltip: 'Countries',
          ),
          // Search by ID
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SearchEmployeeScreen()),
            ),
            tooltip: 'Search by ID',
          ),
          // Profile avatar → opens bottom sheet
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: GestureDetector(
              onTap: _showProfileSheet,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: user?.photoURL != null
                    ? CachedNetworkImageProvider(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      )
                    : null,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildFilterBar(employeeNotifier, colorScheme),
        ),
      ),
      body: _buildBody(employeeNotifier),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditEmployeeScreen()),
          );
          if (result == true) {
            SnackbarHelper.showSuccessMessenger(
                messenger, 'Employee added successfully!');
          }
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Employee'),
      ),
    );
  }

  Widget _buildFilterBar(EmployeeNotifier notifier, ColorScheme colorScheme) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((field) {
            final isSelected = notifier.filterField == field;
            final icon = _filterIcons[field];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    ref.read(employeeProvider).setFilterField(field),
                child: Semantics(
                  label: 'Filter by ${_filterLabels[field] ?? field}',
                  selected: isSelected,
                  button: true,
                  child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 14,
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.white,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        _filterLabels[field] ?? field,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(EmployeeNotifier notifier) {
    if (notifier.status == StatusEnum.loading &&
        notifier.employees.isEmpty) {
      return const EmployeeListShimmer();
    }

    if (notifier.status == StatusEnum.error &&
        notifier.employees.isEmpty) {
      return AppErrorWidget(
        message: notifier.errorMessage ?? 'Failed to load employees',
        onRetry: () => ref.read(employeeProvider).fetchAllEmployees(),
      );
    }

    return Column(
      children: [
        _buildSearchBar(notifier),

        if (notifier.errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.orange.withValues(alpha: 0.1),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notifier.errorMessage!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: notifier.employees.isEmpty
              ? EmptyStateWidget(
                  title: notifier.searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No Employees Yet',
                  subtitle: notifier.searchQuery.isNotEmpty
                      ? 'Try a different search term or filter'
                      : 'Tap the + button to add your first employee',
                  icon: notifier.searchQuery.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.people_outline_rounded,
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // On wide screens (tablet / desktop) show a two-column grid
                      final isWide = constraints.maxWidth >= 700;
                      if (isWide) {
                        return GridView.builder(
                          padding: const EdgeInsets.only(
                              bottom: 80, top: 4, left: 8, right: 8),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 480,
                            childAspectRatio: 3.4,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: notifier.employees.length,
                          itemBuilder: (_, index) {
                            final employee = notifier.employees[index];
                            return EmployeeCard(
                              employee: employee,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EmployeeDetailScreen(employee: employee),
                                ),
                              ),
                              onEdit: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditEmployeeScreen(employee: employee),
                                  ),
                                );
                                if (result == true && mounted) {
                                  SnackbarHelper.showSuccess(context,
                                      'Employee updated successfully!');
                                }
                              },
                              onDelete: employee.id != null
                                  ? () => _deleteEmployee(employee)
                                  : null,
                            );
                          },
                        );
                      }
                      return ListView.builder(
                        padding:
                            const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: notifier.employees.length,
                        itemBuilder: (_, index) {
                          final employee = notifier.employees[index];
                          return EmployeeCard(
                            employee: employee,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EmployeeDetailScreen(employee: employee),
                              ),
                            ),
                            onEdit: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditEmployeeScreen(employee: employee),
                                ),
                              );
                              if (result == true && mounted) {
                                SnackbarHelper.showSuccess(
                                    context, 'Employee updated successfully!');
                              }
                            },
                            onDelete: employee.id != null
                                ? () => _deleteEmployee(employee)
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(EmployeeNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (val) =>
            ref.read(employeeProvider).setSearchQuery(val),
        decoration: InputDecoration(
          hintText:
              'Search by ${_filterLabels[notifier.filterField] ?? "name"}...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: notifier.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(employeeProvider).clearSearch(),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
