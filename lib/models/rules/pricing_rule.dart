import 'business_rule.dart';

/// Regra de precificação com Strategy Pattern
abstract class PricingRule extends BusinessRule {
  PricingRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  String get ruleType => 'pricing';

  /// Calcula o ajuste de preço
  double calculatePriceAdjustment(RuleContext context);
}

/// Regra de desconto por volume
class VolumeDiscountRule extends PricingRule {
  final int minimumQuantity;
  final double discountPercentage;

  VolumeDiscountRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.minimumQuantity,
    required this.discountPercentage,
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

    final quantity =
        int.tryParse(context.formData['quantity']?.toString() ?? '0') ?? 0;
    return quantity >= minimumQuantity;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final adjustment = calculatePriceAdjustment(context);
    return RuleResult.success(
      message:
          'Desconto por volume aplicado: ${discountPercentage.toStringAsFixed(1)}%',
      changes: {
        'volumeDiscountPercentage': discountPercentage,
        'volumeDiscountAmount': adjustment,
      },
    );
  }

  @override
  double calculatePriceAdjustment(RuleContext context) {
    final basePrice = double.tryParse(
            context.calculatedData['basePrice']?.toString() ?? '0') ??
        0;
    return -(basePrice * discountPercentage / 100);
  }
}

/// Regra de taxa de urgência
class UrgencyFeeRule extends PricingRule {
  final int maxDeliveryDays;
  final double feePercentage;

  UrgencyFeeRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.maxDeliveryDays,
    required this.feePercentage,
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

    final deliveryDays =
        int.tryParse(context.formData['delivery_days']?.toString() ?? '30') ??
            30;
    return deliveryDays <= maxDeliveryDays;
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final adjustment = calculatePriceAdjustment(context);
    return RuleResult.success(
      message:
          'Taxa de urgência aplicada: +${feePercentage.toStringAsFixed(1)}%',
      changes: {
        'urgencyFeePercentage': feePercentage,
        'urgencyFeeAmount': adjustment,
      },
    );
  }

  @override
  double calculatePriceAdjustment(RuleContext context) {
    final basePrice = double.tryParse(
            context.calculatedData['basePrice']?.toString() ?? '0') ??
        0;
    return basePrice * feePercentage / 100;
  }
}

/// Regra de desconto para clientes VIP
class VipDiscountRule extends PricingRule {
  final double discountPercentage;
  final List<String> vipCustomers;

  VipDiscountRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
    required this.discountPercentage,
    required this.vipCustomers,
    super.isEnabled,
    super.applicableProductTypes,
    super.conditions,
  });

  @override
  bool isApplicable(RuleContext context) {
    if (!isEnabled) return false;

    final customerId = context.metadata['customerId']?.toString();
    return customerId != null && vipCustomers.contains(customerId);
  }

  @override
  RuleResult execute(RuleContext context) {
    if (!isApplicable(context)) {
      return RuleResult.success();
    }

    final adjustment = calculatePriceAdjustment(context);
    return RuleResult.success(
      message:
          'Desconto VIP aplicado: ${discountPercentage.toStringAsFixed(1)}%',
      changes: {
        'vipDiscountPercentage': discountPercentage,
        'vipDiscountAmount': adjustment,
      },
    );
  }

  @override
  double calculatePriceAdjustment(RuleContext context) {
    final basePrice = double.tryParse(
            context.calculatedData['basePrice']?.toString() ?? '0') ??
        0;
    return -(basePrice * discountPercentage / 100);
  }
}
