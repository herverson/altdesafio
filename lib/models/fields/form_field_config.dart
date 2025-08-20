/// Configuração abstrata para campos dinâmicos de formulário
abstract class FormFieldConfig {
  final String key;
  final String label;
  final bool isRequired;
  final bool isVisible;
  final int order;
  final Map<String, dynamic> validationRules;

  const FormFieldConfig({
    required this.key,
    required this.label,
    required this.isRequired,
    this.isVisible = true,
    required this.order,
    this.validationRules = const {},
  });

  /// Validação específica do campo
  String? validate(dynamic value);

  /// Cópia com modificações para estados dinâmicos
  FormFieldConfig copyWith({
    String? key,
    String? label,
    bool? isRequired,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? validationRules,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'isRequired': isRequired,
        'isVisible': isVisible,
        'order': order,
        'validationRules': validationRules,
        'type': runtimeType.toString(),
      };
}

/// Campo de texto
class TextFieldConfig extends FormFieldConfig {
  final String? placeholder;
  final int? maxLength;
  final RegExp? pattern;

  const TextFieldConfig({
    required super.key,
    required super.label,
    required super.isRequired,
    super.isVisible,
    required super.order,
    super.validationRules,
    this.placeholder,
    this.maxLength,
    this.pattern,
  });

  @override
  String? validate(dynamic value) {
    if (isRequired && (value == null || value.toString().trim().isEmpty)) {
      return '$label é obrigatório';
    }

    if (value != null &&
        maxLength != null &&
        value.toString().length > maxLength!) {
      return '$label deve ter no máximo $maxLength caracteres';
    }

    if (value != null &&
        pattern != null &&
        !pattern!.hasMatch(value.toString())) {
      return '$label tem formato inválido';
    }

    return null;
  }

  @override
  FormFieldConfig copyWith({
    String? key,
    String? label,
    bool? isRequired,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? validationRules,
  }) {
    return TextFieldConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      validationRules: validationRules ?? this.validationRules,
      placeholder: placeholder,
      maxLength: maxLength,
      pattern: pattern,
    );
  }
}

/// Campo numérico
class NumberFieldConfig extends FormFieldConfig {
  final double? min;
  final double? max;
  final int? decimals;

  const NumberFieldConfig({
    required super.key,
    required super.label,
    required super.isRequired,
    super.isVisible,
    required super.order,
    super.validationRules,
    this.min,
    this.max,
    this.decimals,
  });

  @override
  String? validate(dynamic value) {
    if (isRequired && (value == null || value.toString().trim().isEmpty)) {
      return '$label é obrigatório';
    }

    if (value != null) {
      final numValue = double.tryParse(value.toString());
      if (numValue == null) {
        return '$label deve ser um número válido';
      }

      if (min != null && numValue < min!) {
        return '$label deve ser maior que $min';
      }

      if (max != null && numValue > max!) {
        return '$label deve ser menor que $max';
      }
    }

    return null;
  }

  @override
  FormFieldConfig copyWith({
    String? key,
    String? label,
    bool? isRequired,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? validationRules,
  }) {
    return NumberFieldConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      validationRules: validationRules ?? this.validationRules,
      min: min,
      max: max,
      decimals: decimals,
    );
  }
}

/// Campo de seleção
class SelectFieldConfig extends FormFieldConfig {
  final List<SelectOption> options;
  final bool allowMultiple;

  const SelectFieldConfig({
    required super.key,
    required super.label,
    required super.isRequired,
    super.isVisible,
    required super.order,
    super.validationRules,
    required this.options,
    this.allowMultiple = false,
  });

  @override
  String? validate(dynamic value) {
    if (isRequired &&
        (value == null ||
            (value is List && value.isEmpty) ||
            value.toString().trim().isEmpty)) {
      return '$label é obrigatório';
    }

    return null;
  }

  @override
  FormFieldConfig copyWith({
    String? key,
    String? label,
    bool? isRequired,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? validationRules,
  }) {
    return SelectFieldConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      validationRules: validationRules ?? this.validationRules,
      options: options,
      allowMultiple: allowMultiple,
    );
  }
}

class SelectOption {
  final String value;
  final String label;
  final bool isEnabled;

  const SelectOption({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'isEnabled': isEnabled,
      };
}
