import 'package:flutter/material.dart';

/// Reusable dropdown field with consistent styling
class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only pass a value when it actually exists in the items list.
    // If items is empty or the value isn't present, use null to avoid the
    // "exactly one item" assertion inside DropdownButtonFormField.
    final resolvedValue =
        (value != null && value!.isNotEmpty && items.contains(value))
            ? value
            : null;

    return DropdownButtonFormField<String>(
      initialValue: resolvedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
