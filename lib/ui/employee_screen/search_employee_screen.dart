import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/employees/presentation/bloc/employee_cubit.dart';
import '../../features/employees/presentation/bloc/employee_state.dart';
import '../helper/snackbar_helper.dart';
import 'employee_detail_screen.dart';

class SearchEmployeeScreen extends StatefulWidget {
  const SearchEmployeeScreen({super.key});

  @override
  State<SearchEmployeeScreen> createState() =>
      _SearchEmployeeScreenState();
}

class _SearchEmployeeScreenState
    extends State<SearchEmployeeScreen> {
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeCubit>().clearSearchState();
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _search() {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      SnackbarHelper.showInfo(context, 'Please enter an employee ID');
      return;
    }
    context.read<EmployeeCubit>().searchById(id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<EmployeeCubit, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeSearchResult) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<EmployeeCubit>(),
                child: EmployeeDetailScreen(
                    employee: state.employee),
              ),
            ),
          );
        } else if (state is EmployeeSearchNotFound) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is EmployeeLoading;
        return Scaffold(
          appBar: AppBar(title: const Text('Search by ID')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          prefixIcon:
                              Icon(Icons.badge_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _search,
                        style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(64, 56)),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.search_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Expanded(
                    child: _buildState(
                        context, state, colorScheme)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildState(BuildContext context, EmployeeState state,
      ColorScheme cs) {
    if (state is EmployeeLoading) {
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

    if (state is EmployeeSearchNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined,
                size: 72,
                color: cs.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('Employee not found',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // idle state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded,
              size: 80,
              color: cs.primary.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('Enter an ID to search',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                      color: cs.onSurface
                          .withValues(alpha: 0.5))),
          const SizedBox(height: 6),
          Text(
            'Find any employee by their numeric ID',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }
}
