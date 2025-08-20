import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fields/form_field_config.dart';

/// Factory para widgets dinâmicos usando Strategy Pattern
class DynamicFormFieldFactory {
  static Widget createField({
    required FormFieldConfig config,
    required dynamic value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    if (!config.isVisible) {
      return const SizedBox.shrink();
    }

    switch (config.runtimeType) {
      case TextFieldConfig:
        return _buildTextField(
          config as TextFieldConfig,
          value,
          onChanged,
          errorText,
        );
      case NumberFieldConfig:
        return _buildNumberField(
          config as NumberFieldConfig,
          value,
          onChanged,
          errorText,
        );
      case SelectFieldConfig:
        return _buildSelectField(
          config as SelectFieldConfig,
          value,
          onChanged,
          errorText,
        );
      default:
        return _buildTextField(
          config as TextFieldConfig,
          value,
          onChanged,
          errorText,
        );
    }
  }

  static Widget _buildTextField(
    TextFieldConfig config,
    dynamic value,
    Function(dynamic) onChanged,
    String? errorText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: config.label + (config.isRequired ? ' *' : ''),
          hintText: config.placeholder,
          errorText: errorText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        maxLength: config.maxLength,
        inputFormatters: config.pattern != null
            ? [FilteringTextInputFormatter.allow(config.pattern!)]
            : null,
        onChanged: onChanged,
        validator: (value) => config.validate(value),
      ),
    );
  }

  static Widget _buildNumberField(
    NumberFieldConfig config,
    dynamic value,
    Function(dynamic) onChanged,
    String? errorText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: config.label + (config.isRequired ? ' *' : ''),
          errorText: errorText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.numbers),
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: (config.decimals ?? 0) > 0,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,' + (config.decimals ?? 2).toString() + '}'),
          ),
        ],
        onChanged: onChanged,
        validator: (value) => config.validate(value),
      ),
    );
  }

  static Widget _buildSelectField(
    SelectFieldConfig config,
    dynamic value,
    Function(dynamic) onChanged,
    String? errorText,
  ) {
    if (config.allowMultiple) {
      return _buildMultiSelectField(config, value, onChanged, errorText);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value?.toString(),
        decoration: InputDecoration(
          labelText: config.label + (config.isRequired ? ' *' : ''),
          errorText: errorText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: config.options
            .where((option) => option.isEnabled)
            .map((option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                ))
            .toList(),
        onChanged: config.options.where((o) => o.isEnabled).isNotEmpty
            ? onChanged
            : null,
        validator: (value) => config.validate(value),
      ),
    );
  }

  static Widget _buildMultiSelectField(
    SelectFieldConfig config,
    dynamic value,
    Function(dynamic) onChanged,
    String? errorText,
  ) {
    final selectedValues = value is List ? value.cast<String>() : <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.label + (config.isRequired ? ' *' : ''),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: config.options
                  .where((option) => option.isEnabled)
                  .map((option) => CheckboxListTile(
                        title: Text(option.label),
                        value: selectedValues.contains(option.value),
                        onChanged: (checked) {
                          final newValues = List<String>.from(selectedValues);
                          if (checked == true) {
                            newValues.add(option.value);
                          } else {
                            newValues.remove(option.value);
                          }
                          onChanged(newValues);
                        },
                      ))
                  .toList(),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Builder(
                builder: (context) => Text(
                  errorText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget customizado para exibição de campo dinâmico
class DynamicFormField extends StatelessWidget {
  final FormFieldConfig config;
  final dynamic value;
  final Function(dynamic) onChanged;
  final String? errorText;

  const DynamicFormField({
    Key? key,
    required this.config,
    required this.value,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicFormFieldFactory.createField(
      config: config,
      value: value,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}

/// Widget para exibir informações do campo
class FieldInfoWidget extends StatelessWidget {
  final FormFieldConfig config;

  const FieldInfoWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFieldIcon(config),
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  config.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              if (config.isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Obrigatório',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          if (config.validationRules.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _getValidationInfo(config),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFieldIcon(FormFieldConfig config) {
    switch (config.runtimeType) {
      case NumberFieldConfig:
        return Icons.numbers;
      case SelectFieldConfig:
        return Icons.arrow_drop_down;
      default:
        return Icons.text_fields;
    }
  }

  String _getValidationInfo(FormFieldConfig config) {
    final rules = <String>[];

    if (config is NumberFieldConfig) {
      if (config.min != null) rules.add('Mín: ${config.min}');
      if (config.max != null) rules.add('Máx: ${config.max}');
    }

    if (config is TextFieldConfig) {
      if (config.maxLength != null) rules.add('Máx: ${config.maxLength} chars');
    }

    return rules.join(' • ');
  }
}
