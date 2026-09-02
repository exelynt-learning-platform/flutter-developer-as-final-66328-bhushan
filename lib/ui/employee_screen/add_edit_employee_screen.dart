import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../framwork/providers/provider/country_provider.dart';
import '../../framwork/providers/provider/employee_provider.dart';
import '../../framwork/repository/model/employee_model/employee_model.dart';
import '../helper/custom_dropdown.dart';
import '../helper/custom_text_field.dart';
import '../helper/snackbar_helper.dart';

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final EmployeeModel? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState
    extends ConsumerState<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();

  String? _selectedCountry;

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final e = widget.employee!;
      _nameController.text = e.name;
      _emailController.text = e.email;
      _mobileController.text = e.mobile;
      _stateController.text = e.state;
      _districtController.text = e.district;
      _selectedCountry = e.country;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(countryProvider).fetchCountries();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null) {
      SnackbarHelper.showError(context, 'Please select a country');
      return;
    }

    final employee = EmployeeModel(
      id: widget.employee?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _selectedCountry!,
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      createdAt: widget.employee?.createdAt,
    );

    bool success;
    if (isEditing) {
      success = await ref
          .read(employeeProvider)
          .updateEmployee(widget.employee!.id!, employee);
    } else {
      success = await ref.read(employeeProvider).createEmployee(employee);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      final error = ref.read(employeeProvider).crudErrorMessage ??
          '${isEditing ? "Update" : "Create"} failed';
      SnackbarHelper.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeNotifier = ref.watch(employeeProvider);
    final countryNotifier = ref.watch(countryProvider);
    final isLoading = employeeNotifier.isCrudLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final horizontalPadding =
                  isWide ? (constraints.maxWidth - 560) / 2 : 20.0;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Personal Information ────────────────────────────────
                  _SectionHeader(title: 'Personal Information'),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter employee name',
                    prefixIcon: Icons.person_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (val.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'employee@company.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                          .hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hint: '9876543210',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Mobile number is required';
                      }
                      if (val.trim().length < 7) {
                        return 'Enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Location ────────────────────────────────────────────
                  _SectionHeader(title: 'Location'),
                  const SizedBox(height: 16),

                  // Country dropdown from API
                  countryNotifier.isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : countryNotifier.status.name == 'error'
                          ? _CountryErrorRetry(
                              onRetry: () => ref
                                  .read(countryProvider)
                                  .fetchCountries(forceRefresh: true),
                            )
                          : CustomDropdown(
                              label: 'Country',
                              value: _selectedCountry,
                              items: countryNotifier.countryNames,
                              prefixIcon: Icons.flag_outlined,
                              onChanged: (val) {
                                setState(() => _selectedCountry = val);
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please select a country';
                                }
                                return null;
                              },
                            ),
                  const SizedBox(height: 16),

                  // State — free text since API has no states
                  CustomTextField(
                    controller: _stateController,
                    label: 'State / Province',
                    hint: 'Enter state or province',
                    prefixIcon: Icons.map_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _districtController,
                    label: 'District / City',
                    hint: 'Enter district or city',
                    prefixIcon: Icons.location_city_outlined,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
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
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Employee' : 'Add Employee'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
            },
          ),  // LayoutBuilder

          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _CountryErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const _CountryErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Failed to load countries',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
