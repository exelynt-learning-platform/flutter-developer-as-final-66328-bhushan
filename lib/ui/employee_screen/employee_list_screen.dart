import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/employees/domain/entities/employee.dart';
import '../../features/employees/presentation/bloc/employee_cubit.dart';
import '../../features/employees/presentation/bloc/employee_state.dart';
import '../../features/theme/theme_cubit.dart';
import '../../injection_container.dart';
import '../auth_screen/login_screen.dart';
import '../country_screen/country_list_screen.dart';
import '../helper/confirm_dialog.dart';
import '../helper/employee_card.dart';
import '../helper/empty_state_widget.dart';
import '../helper/error_widget.dart';
import '../helper/loading_widget.dart';
import '../helper/snackbar_helper.dart';
import 'add_edit_employee_screen.dart';
import 'employee_detail_screen.dart';
import 'search_employee_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeeCubit>(
      create: (_) => sl<EmployeeCubit>()..fetchAll(),
      child: const _EmployeeListView(),
    );
  }
}

class _EmployeeListView extends StatefulWidget {
  const _EmployeeListView();

  @override
  State<_EmployeeListView> createState() => _EmployeeListViewState();
}

class _EmployeeListViewState extends State<_EmployeeListView> {
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

  List<Employee> _employeesFrom(EmployeeState s) {
    if (s is EmployeeLoaded) return s.filtered;
    if (s is EmployeeCrudLoading) return s.filtered;
    if (s is EmployeeCrudSuccess) return s.filtered;
    if (s is EmployeeCrudError) return s.filtered;
    return [];
  }

  String _queryFrom(EmployeeState s) {
    if (s is EmployeeLoaded) return s.searchQuery;
    if (s is EmployeeCrudLoading) return s.searchQuery;
    if (s is EmployeeCrudSuccess) return s.searchQuery;
    if (s is EmployeeCrudError) return s.searchQuery;
    return '';
  }

  String _fieldFrom(EmployeeState s) {
    if (s is EmployeeLoaded) return s.filterField;
    if (s is EmployeeCrudLoading) return s.filterField;
    if (s is EmployeeCrudSuccess) return s.filterField;
    if (s is EmployeeCrudError) return s.filterField;
    return 'name';
  }

  Future<void> _deleteEmployee(
      BuildContext context, Employee employee) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Employee',
      message:
          'Are you sure you want to delete "${employee.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed || !context.mounted) return;
    context.read<EmployeeCubit>().delete(employee.id!);
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      confirmColor: Colors.orange,
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<AuthCubit>().signOut();
  }

  void _showProfileSheet(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final user =
        authState is Authenticated ? authState.user : null;
    final colorScheme = Theme.of(context).colorScheme;
    final initials = ((user?.displayName?.isNotEmpty == true
                ? user!.displayName![0]
                : user?.email?[0]) ??
            'U')
        .toUpperCase();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: colorScheme.onSurface
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: user?.photoURL != null
                      ? CachedNetworkImageProvider(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Text(initials,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(user?.displayName ?? 'User',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.55))),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 8),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.amber
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(12)),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                      ),
                      title: Text(
                          isDark ? 'Light Mode' : 'Dark Mode',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleTheme(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    _signOut(context);
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: colorScheme.error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.logout_rounded,
                        color: colorScheme.error, size: 20),
                  ),
                  title: Text('Sign Out',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.error)),
                  subtitle: Text('Log out of your account',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.45))),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: colorScheme.error
                          .withValues(alpha: 0.5)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeCubit, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeCrudSuccess) {
          SnackbarHelper.showSuccess(context, state.message);
        } else if (state is EmployeeCrudError) {
          SnackbarHelper.showError(context, state.message);
        }
        // After sign-out, AuthCubit emits Unauthenticated
      },
      builder: (context, state) {
        final employees = _employeesFrom(state);
        final query = _queryFrom(state);
        final field = _fieldFrom(state);
        final colorScheme = Theme.of(context).colorScheme;

        final authState = context.watch<AuthCubit>().state;
        if (authState is Unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                (r) => false,
              );
            }
          });
        }

        final initials = (() {
          if (authState is Authenticated) {
            return ((authState.user.displayName?.isNotEmpty == true
                        ? authState.user.displayName![0]
                        : authState.user.email?[0]) ??
                    'U')
                .toUpperCase();
          }
          return 'U';
        })();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Employees'),
            actions: [
              IconButton(
                icon: const Icon(Icons.public_rounded),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const CountryListScreen())),
                tooltip: 'Countries',
              ),
              IconButton(
                icon: const Icon(Icons.manage_search_rounded),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                              value: context.read<EmployeeCubit>(),
                              child:
                                  const SearchEmployeeScreen(),
                            ))),
                tooltip: 'Search by ID',
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 12, left: 4),
                child: GestureDetector(
                  onTap: () => _showProfileSheet(context),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage: (() {
                      if (authState is Authenticated &&
                          authState.user.photoURL != null) {
                        return CachedNetworkImageProvider(
                            authState.user.photoURL!);
                      }
                      return null;
                    })(),
                    child: (authState is! Authenticated ||
                            authState.user.photoURL == null)
                        ? Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))
                        : null,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: _buildFilterBar(
                  context, colorScheme, field),
            ),
          ),
          body: _buildBody(
              context, state, employees, query, field),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final messenger =
                  ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              final cubit = context.read<EmployeeCubit>();
              final result = await nav.push<Employee?>(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const AddEditEmployeeScreen(),
                  ),
                ),
              );
              if (result != null) {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Employee added successfully!'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Employee'),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(
      BuildContext context, ColorScheme cs, String field) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((f) {
            final isSelected = field == f;
            final icon = _filterIcons[f];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    context.read<EmployeeCubit>().setFilterField(f),
                child: Semantics(
                  label:
                      'Filter by ${_filterLabels[f] ?? f}',
                  selected: isSelected,
                  button: true,
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white
                                .withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon,
                              size: 14,
                              color: isSelected
                                  ? cs.primary
                                  : Colors.white),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          _filterLabels[f] ?? f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? cs.primary
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

  Widget _buildBody(
      BuildContext context,
      EmployeeState state,
      List<Employee> employees,
      String query,
      String field) {
    if (state is EmployeeLoading) {
      return const EmployeeListShimmer();
    }

    if (state is EmployeeError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () => context.read<EmployeeCubit>().fetchAll(),
      );
    }

    return Column(
      children: [
        _buildSearchBar(context, query, field),
        if (state is EmployeeLoaded &&
            state.warningMessage != null)
          Container(
            width: double.infinity,
            color: Colors.orange.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.warningMessage!,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: employees.isEmpty
              ? EmptyStateWidget(
                  title: query.isNotEmpty
                      ? 'No results found'
                      : 'No Employees Yet',
                  subtitle: query.isNotEmpty
                      ? 'Try a different search term or filter'
                      : 'Tap the + button to add your first employee',
                  icon: query.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.people_outline_rounded,
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<EmployeeCubit>().fetchAll(),
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      final isWide =
                          constraints.maxWidth >= 700;
                      if (isWide) {
                        return GridView.builder(
                          padding: const EdgeInsets.only(
                              bottom: 80,
                              top: 4,
                              left: 8,
                              right: 8),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 480,
                            childAspectRatio: 3.4,
                          ),
                          itemCount: employees.length,
                          itemBuilder: (_, i) =>
                              _buildCard(context, employees[i]),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 80, top: 4),
                        itemCount: employees.length,
                        itemBuilder: (_, i) =>
                            _buildCard(context, employees[i]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Employee employee) {
    final nav = Navigator.of(context);
    final cubit = context.read<EmployeeCubit>();
    return EmployeeCard(
      employee: employee,
      onTap: () => nav.push(MaterialPageRoute(
          builder: (_) =>
              EmployeeDetailScreen(employee: employee))),
      onEdit: () async {
        final result = await nav.push<Employee?>(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: AddEditEmployeeScreen(employee: employee),
            ),
          ),
        );
        if (result != null && context.mounted) {
          SnackbarHelper.showSuccess(
              context, 'Employee updated successfully!');
        }
      },
      onDelete: employee.id != null
          ? () => _deleteEmployee(context, employee)
          : null,
    );
  }

  Widget _buildSearchBar(
      BuildContext context, String query, String field) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (val) =>
            context.read<EmployeeCubit>().setSearchQuery(val),
        decoration: InputDecoration(
          hintText:
              'Search by ${_filterLabels[field] ?? "name"}...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      context.read<EmployeeCubit>().clearSearch(),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
