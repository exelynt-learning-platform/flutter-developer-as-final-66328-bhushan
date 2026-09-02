import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/employees/domain/entities/employee.dart';
import '../../features/employees/presentation/bloc/country_cubit.dart';
import '../../features/employees/presentation/bloc/employee_cubit.dart';
import '../../features/employees/presentation/bloc/employee_state.dart';
import '../../injection_container.dart';
import '../helper/custom_dropdown.dart';
import '../helper/custom_text_field.dart';
import '../helper/snackbar_helper.dart';

class AddEditEmployeeScreen extends StatelessWidget {
  final Employee? employee;
  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountryCubit>(
      create: (_) => sl<CountryCubit>()..fetchCountries(),
      child: _AddEditView(employee: employee),
    );
  }
}

class _AddEditView extends StatefulWidget {
  final Employee? employee;
  const _AddEditView({this.employee});

  @override
  State<_AddEditView> createState() => _AddEditViewState();
}

class _AddEditViewState extends State<_AddEditView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  String? _country;

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final e = widget.employee!;
      _nameCtrl.text = e.name;
      _emailCtrl.text = e.email;
      _mobileCtrl.text = e.mobile;
      _stateCtrl.text = e.state;
      _districtCtrl.text = e.district;
      _country = e.country;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_country == null) {
      SnackbarHelper.showError(context, 'Please select a country');
      return;
    }
    final emp = Employee(
      id: widget.employee?.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      country: _country!,
      state: _stateCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      createdAt: widget.employee?.createdAt,
    );
    if (isEditing) {
      context.read<EmployeeCubit>().update(emp);
    } else {
      context.read<EmployeeCubit>().create(emp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeCubit, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeCrudSuccess) {
          final emp = state.all.firstWhere(
            (e) => e.name == _nameCtrl.text.trim(),
            orElse: () => state.all.first,
          );
          Navigator.pop(context, emp);
        } else if (state is EmployeeCrudError) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      builder: (context, empState) {
        final isLoading = empState is EmployeeCrudLoading;
        return Scaffold(
          appBar: AppBar(
              title: Text(
                  isEditing ? 'Edit Employee' : 'Add Employee')),
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final hPad =
                      isWide ? (constraints.maxWidth - 560) / 2 : 20.0;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: hPad, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                              title: 'Personal Information'),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _nameCtrl,
                            label: 'Full Name',
                            hint: 'Enter employee name',
                            prefixIcon: Icons.person_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Name is required';
                              }
                              if (v.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email Address',
                            hint: 'employee@company.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                                  .hasMatch(v.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _mobileCtrl,
                            label: 'Mobile Number',
                            hint: '9876543210',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (v.trim().length < 7) {
                                return 'Enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(title: 'Location'),
                          const SizedBox(height: 16),
                          BlocBuilder<CountryCubit, CountryState>(
                            builder: (context, cs) {
                              if (cs is CountryLoading) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12),
                                  child:
                                      CircularProgressIndicator(),
                                ));
                              }
                              if (cs is CountryError) {
                                return Row(children: [
                                  Expanded(
                                    child: Text(
                                      'Failed to load countries',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => context
                                        .read<CountryCubit>()
                                        .fetchCountries(
                                            forceRefresh: true),
                                    icon: const Icon(Icons.refresh,
                                        size: 16),
                                    label: const Text('Retry'),
                                  ),
                                ]);
                              }
                              final names = cs is CountryLoaded
                                  ? cs.names
                                  : <String>[];
                              return CustomDropdown(
                                label: 'Country',
                                value: _country,
                                items: names,
                                prefixIcon: Icons.flag_outlined,
                                onChanged: (v) =>
                                    setState(() => _country = v),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please select a country';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _stateCtrl,
                            label: 'State / Province',
                            hint: 'Enter state or province',
                            prefixIcon: Icons.map_outlined,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'State is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _districtCtrl,
                            label: 'District / City',
                            hint: 'Enter district or city',
                            prefixIcon:
                                Icons.location_city_outlined,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _save(),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'District is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 36),
                          ElevatedButton(
                            onPressed: isLoading ? null : _save,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5),
                                  )
                                : Text(isEditing
                                    ? 'Update Employee'
                                    : 'Add Employee'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (isLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                      child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
}
