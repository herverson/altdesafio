import 'business_rule.dart';

/// Regra de validação com Strategy Pattern
abstract class ValidationRule extends BusinessRule {
  ValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  String get ruleType => 'validation';

  /// Executa validação específica
  List<String> validateFields(RuleContext context);
}

/// Regra de certificação obrigatória para produtos industriais
class CertificationRequiredRule extends ValidationRule {
  final double voltageThreshold;

  CertificationRequiredRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.voltageThreshold,
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

    final voltage =
        double.tryParse(context.formData['voltage']?.toString() ?? '0') ?? 0;
    return voltage > voltageThreshold;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(
      message: 'Validação de certificação passou',
      changes: {'certificationRequired': true},
    );
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final certification = context.formData['certification']?.toString() ?? '';

    if (certification.trim().isEmpty) {
      errors.add(
          'Certificação é obrigatória para produtos com voltagem superior a ${voltageThreshold}V');
    }

    return errors;
  }
}

/// Regra de validação de quantidade mínima
class MinimumQuantityRule extends ValidationRule {
  final int minimumQuantity;

  MinimumQuantityRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.minimumQuantity,
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

    return true;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(message: 'Validação de quantidade passou');
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final quantity =
        int.tryParse(context.formData['quantity']?.toString() ?? '0') ?? 0;

    if (quantity < minimumQuantity) {
      errors.add('Quantidade mínima é $minimumQuantity unidades');
    }

    return errors;
  }
}

/// Regra de validação de prazo de entrega
class DeliveryTimeValidationRule extends ValidationRule {
  final int maxDeliveryDays;
  final int minDeliveryDays;

  DeliveryTimeValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.maxDeliveryDays,
    required this.minDeliveryDays,
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

    return true;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(message: 'Validação de prazo passou');
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final deliveryDays =
        int.tryParse(context.formData['delivery_days']?.toString() ?? '0') ?? 0;

    if (deliveryDays < minDeliveryDays) {
      errors.add('Prazo mínimo de entrega é $minDeliveryDays dias');
    }

    if (deliveryDays > maxDeliveryDays) {
      errors.add('Prazo máximo de entrega é $maxDeliveryDays dias');
    }

    return errors;
  }
}

/// Regra de validação de quantidade (alias para MinimumQuantityRule)
class QuantityValidationRule extends ValidationRule {
  final int minimumQuantity;
  final int? maximumQuantity;

  QuantityValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.minimumQuantity,
    this.maximumQuantity,
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

    return true;
  }

  @override
  RuleResult execute(RuleContext context) {
    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(
      message: 'Validação de quantidade passou',
      changes: {'quantityValid': true},
    );
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final quantity =
        int.tryParse(context.formData['quantity']?.toString() ?? '0') ?? 0;

    if (quantity < minimumQuantity) {
      errors.add('Quantidade mínima é $minimumQuantity unidades');
    }

    if (maximumQuantity != null && quantity > maximumQuantity!) {
      errors.add('Quantidade máxima é $maximumQuantity unidades');
    }

    return errors;
  }
}

/// Regra de validação de certificação (alias para CertificationRequiredRule)
class CertificationValidationRule extends ValidationRule {
  final double voltageThreshold;

  CertificationValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.voltageThreshold,
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

    final voltage =
        double.tryParse(context.formData['voltage']?.toString() ?? '0') ?? 0;
    return voltage > voltageThreshold;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(
      message: 'Validação de certificação passou',
      changes: {'certificationRequired': true},
    );
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final certification = context.formData['certification']?.toString() ?? '';

    if (certification.trim().isEmpty) {
      errors.add(
          'Certificação é obrigatória para produtos com voltagem superior a ${voltageThreshold}V');
    }

    return errors;
  }
}

/// Regra de validação de entrega (alias para DeliveryTimeValidationRule)
class DeliveryValidationRule extends ValidationRule {
  final int maxDeliveryDays;
  final int minDeliveryDays;

  DeliveryValidationRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.maxDeliveryDays,
    required this.minDeliveryDays,
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

    return true;
  }

  @override
  RuleResult execute(RuleContext context) {
    final errors = validateFields(context);
    if (errors.isNotEmpty) {
      return RuleResult.failure(errors: errors);
    }

    return RuleResult.success(
      message: 'Validação de prazo passou',
      changes: {'deliveryTimeValid': true},
    );
  }

  @override
  List<String> validateFields(RuleContext context) {
    final errors = <String>[];
    final deliveryDays =
        int.tryParse(context.formData['delivery_days']?.toString() ?? '0') ?? 0;

    if (deliveryDays < minDeliveryDays) {
      errors.add('Prazo mínimo de entrega é $minDeliveryDays dias');
    }

    if (deliveryDays > maxDeliveryDays) {
      errors.add('Prazo máximo de entrega é $maxDeliveryDays dias');
    }

    return errors;
  }
}
