import 'business_rule.dart';
import '../fields/form_field_config.dart';

/// Regra de visibilidade com Strategy Pattern
abstract class VisibilityRule extends BusinessRule {
  VisibilityRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  String get ruleType => 'visibility';

  /// Determina modificações de visibilidade nos campos
  Map<String, FormFieldConfig> applyVisibilityChanges(
    List<FormFieldConfig> fields,
    RuleContext context,
  );
}

/// Regra de visibilidade condicional baseada em valores
class ConditionalVisibilityRule extends VisibilityRule {
  final String triggerField;
  final dynamic triggerValue;
  final Map<String, bool> fieldVisibilityChanges;
  final Map<String, bool> fieldRequiredChanges;

  ConditionalVisibilityRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.triggerField,
    required this.triggerValue,
    required this.fieldVisibilityChanges,
    this.fieldRequiredChanges = const {},
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  bool isApplicable(RuleContext context) {
    if (!isEnabled) return false;

    final productType = context.metadata['productType']?.toString();
    if (applicableProductTypes.isNotEmpty &&
        (productType == null ||
            !applicableProductTypes.contains(productType))) {
      return false;
    }

    final fieldValue = context.formData[triggerField];
    return fieldValue == triggerValue ||
        (triggerValue is num &&
            fieldValue is num &&
            _compareNumbers(fieldValue, triggerValue));
  }

  bool _compareNumbers(num value, dynamic trigger) {
    if (trigger is String && trigger.startsWith('>')) {
      final threshold = double.tryParse(trigger.substring(1)) ?? 0;
      return value > threshold;
    }
    if (trigger is String && trigger.startsWith('<')) {
      final threshold = double.tryParse(trigger.substring(1)) ?? 0;
      return value < threshold;
    }
    return value == trigger;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final changes = <String, dynamic>{};
    changes.addAll(fieldVisibilityChanges);
    changes.addAll(fieldRequiredChanges);

    return RuleResult.success(
      message: 'Regras de visibilidade aplicadas',
      changes: {'fieldChanges': changes},
    );
  }

  @override
  Map<String, FormFieldConfig> applyVisibilityChanges(
    List<FormFieldConfig> fields,
    RuleContext context,
  ) {
    if (!isApplicable(context)) {
      return {};
    }

    final modifiedFields = <String, FormFieldConfig>{};

    for (final field in fields) {
      bool modified = false;
      FormFieldConfig updatedField = field;

      // Aplicar mudanças de visibilidade
      if (fieldVisibilityChanges.containsKey(field.key)) {
        updatedField = updatedField.copyWith(
          isVisible: fieldVisibilityChanges[field.key],
        );
        modified = true;
      }

      // Aplicar mudanças de obrigatoriedade
      if (fieldRequiredChanges.containsKey(field.key)) {
        updatedField = updatedField.copyWith(
          isRequired: fieldRequiredChanges[field.key],
        );
        modified = true;
      }

      if (modified) {
        modifiedFields[field.key] = updatedField;
      }
    }

    return modifiedFields;
  }
}

/// Regra de visibilidade por tipo de produto
class ProductTypeVisibilityRule extends VisibilityRule {
  final Map<String, List<String>> productTypeFields;

  ProductTypeVisibilityRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.productTypeFields,
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  bool isApplicable(RuleContext context) {
    if (!isEnabled) return false;

    final productType = context.metadata['productType']?.toString();
    return productType != null && productTypeFields.containsKey(productType);
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final productType = context.metadata['productType']?.toString();
    final visibleFields = productTypeFields[productType] ?? [];

    return RuleResult.success(
      message: 'Campos específicos do produto $productType configurados',
      changes: {'visibleFields': visibleFields},
    );
  }

  @override
  Map<String, FormFieldConfig> applyVisibilityChanges(
    List<FormFieldConfig> fields,
    RuleContext context,
  ) {
    if (!isApplicable(context)) {
      return {};
    }

    final productType = context.metadata['productType']?.toString();
    final visibleFields = productTypeFields[productType] ?? [];
    final modifiedFields = <String, FormFieldConfig>{};

    for (final field in fields) {
      final shouldBeVisible = visibleFields.contains(field.key) ||
          field.key == 'quantity'; // Quantidade sempre visível

      if (field.isVisible != shouldBeVisible) {
        modifiedFields[field.key] = field.copyWith(isVisible: shouldBeVisible);
      }
    }

    return modifiedFields;
  }
}
