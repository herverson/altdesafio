import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/services/rules_engine.dart';
import 'package:altdesafio/models/rules/pricing_rule.dart';
import 'package:altdesafio/models/rules/validation_rule.dart';
import 'package:altdesafio/models/rules/visibility_rule.dart';
import 'package:altdesafio/models/rules/business_rule.dart';
import 'package:altdesafio/models/fields/form_field_config.dart';

void main() {
  group('RulesEngine Tests', () {
    late PricingEngine pricingEngine;
    late ValidationEngine validationEngine;
    late VisibilityEngine visibilityEngine;

    setUp(() {
      pricingEngine = PricingEngine();
      validationEngine = ValidationEngine();
      visibilityEngine = VisibilityEngine();
    });

    group('PricingEngine Tests', () {
      test('should calculate final price with single rule', () {
        final rule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );

        pricingEngine.addRule(rule);

        final context = RuleContext(
          formData: {'quantity': 100},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.finalPrice, lessThan(1000.0));
        expect(result.adjustments.length, equals(1));
        expect(result.adjustments.first.type, contains('Volume Discount'));
      });

      test('should calculate final price with multiple rules', () {
        final rules = [
          VolumeDiscountRule(
            id: 'volume_discount_1',
            name: 'Volume Discount Rule',
            description: 'Applies discount for large quantities',
            priority: 80,
            minimumQuantity: 50,
            discountPercentage: 15.0,
          ),
          UrgencyFeeRule(
            id: 'urgency_fee_1',
            name: 'Urgency Fee Rule',
            description: 'Applies fee for urgent delivery',
            priority: 90,
            maxDeliveryDays: 7,
            feePercentage: 20.0,
          ),
        ];

        pricingEngine.addRules(rules);

        final context = RuleContext(
          formData: {'quantity': 100, 'delivery_days': 5},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.adjustments.length, equals(2));
        expect(result.messages.length, equals(2));
      });

      test('should apply rules in priority order', () {
        final lowPriorityRule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 70,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );
        final highPriorityRule = UrgencyFeeRule(
          id: 'urgency_fee_1',
          name: 'Urgency Fee Rule',
          description: 'Applies fee for urgent delivery',
          priority: 90,
          maxDeliveryDays: 7,
          feePercentage: 20.0,
        );

        pricingEngine.addRule(lowPriorityRule);
        pricingEngine.addRule(highPriorityRule);

        final context = RuleContext(
          formData: {'quantity': 100, 'delivery_days': 5},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        // High priority rule should be applied first
        expect(result.adjustments.first.type, contains('Urgency Fee'));
      });

      test('should handle rule execution errors gracefully', () {
        final faultyRule = _FaultyPricingRule(
          id: 'faulty_rule_1',
          name: 'Faulty Rule',
          description: 'A rule that causes errors',
          priority: 50,
        );

        pricingEngine.addRule(faultyRule);

        final context = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.errors.isNotEmpty, isTrue);
        expect(result.errors.first, contains('Faulty Rule'));
      });

      test('should stop execution when rule indicates', () {
        final stoppingRule = _StoppingPricingRule(
          id: 'stopping_rule_1',
          name: 'Stopping Rule',
          description: 'A rule that stops execution',
          priority: 50,
        );

        pricingEngine.addRule(stoppingRule);

        final context = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.errors.isNotEmpty, isTrue);
        expect(result.errors.first, contains('Stopping Rule'));
      });

      test('should handle empty rules list', () {
        final context = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.finalPrice, equals(1000.0));
        expect(result.adjustments, isEmpty);
        expect(result.errors, isEmpty);
      });

      test('should handle rule with no applicable conditions', () {
        final rule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
          applicableProductTypes: ['residential'],
        );

        pricingEngine.addRule(rule);

        final context = RuleContext(
          formData: {'quantity': 100},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.finalPrice, equals(1000.0));
        expect(result.adjustments, isEmpty);
      });

      test('should handle specialized pricing engines', () {
        final specializedPricingEngine = PricingEngine();
        final rule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );

        specializedPricingEngine.addRule(rule);

        final context = RuleContext(
          formData: {'quantity': 100},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result =
            specializedPricingEngine.calculateFinalPrice(1000.0, context);

        expect(result.finalPrice, lessThan(1000.0));
        expect(result.adjustments.length, equals(1));
      });

      test('should handle concurrent rule execution', () async {
        final rules = [
          VolumeDiscountRule(
            id: 'volume_discount_1',
            name: 'Volume Discount Rule',
            description: 'Applies discount for large quantities',
            priority: 80,
            minimumQuantity: 50,
            discountPercentage: 15.0,
          ),
          UrgencyFeeRule(
            id: 'urgency_fee_1',
            name: 'Urgency Fee Rule',
            description: 'Applies fee for urgent delivery',
            priority: 90,
            maxDeliveryDays: 7,
            feePercentage: 20.0,
          ),
          VipDiscountRule(
            id: 'vip_discount_1',
            name: 'VIP Discount Rule',
            description: 'Applies discount for VIP customers',
            priority: 70,
            discountPercentage: 10.0,
            vipCustomers: ['customer_001'],
          ),
        ];

        pricingEngine.addRules(rules);

        final context = RuleContext(
          formData: {'quantity': 100, 'delivery_days': 5},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial', 'customerId': 'customer_001'},
        );

        // Execute multiple times concurrently
        final futures = List.generate(
            10,
            (index) => Future.value(
                pricingEngine.calculateFinalPrice(1000.0, context)));

        final results = await Future.wait(futures);

        // All results should be consistent
        for (final result in results) {
          expect(result.adjustments.length, equals(3));
          expect(result.finalPrice, lessThan(1000.0));
        }
      });

      test('should handle rule removal', () {
        final rule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );

        pricingEngine.addRule(rule);
        expect(pricingEngine.ruleCount, equals(1));

        pricingEngine.removeRule(rule.id);
        expect(pricingEngine.ruleCount, equals(0));

        final context = RuleContext(
          formData: {'quantity': 100},
          calculatedData: {'basePrice': 1000.0},
          metadata: {'productType': 'industrial'},
        );

        final result = pricingEngine.calculateFinalPrice(1000.0, context);
        expect(result.finalPrice, equals(1000.0));
        expect(result.adjustments, isEmpty);
      });
    });

    group('ValidationEngine Tests', () {
      test('should validate with single rule', () {
        final rule = QuantityValidationRule(
          id: 'quantity_validation_1',
          name: 'Quantity Validation Rule',
          description: 'Validates minimum quantity',
          priority: 50,
          minimumQuantity: 1,
        );

        validationEngine.addRule(rule);

        final context = RuleContext(
          formData: {'quantity': 0},
          metadata: {'productType': 'industrial'},
        );

        final result = validationEngine.validateAll(context);

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('Quantidade mínima'));
      });

      test('should validate with multiple rules', () {
        final rules = [
          QuantityValidationRule(
            id: 'quantity_validation_1',
            name: 'Quantity Validation Rule',
            description: 'Validates minimum quantity',
            priority: 50,
            minimumQuantity: 1,
          ),
          CertificationValidationRule(
            id: 'certification_validation_1',
            name: 'Certification Validation Rule',
            description: 'Validates certification',
            priority: 60,
            voltageThreshold: 220.0,
          ),
        ];

        validationEngine.addRules(rules);

        final context = RuleContext(
          formData: {'quantity': 0, 'voltage': '380', 'certification': ''},
          metadata: {'productType': 'industrial'},
        );

        final result = validationEngine.validateAll(context);

        expect(result.isValid, isFalse);
        expect(result.errors.length, equals(2));
      });
    });

    group('VisibilityEngine Tests', () {
      test('should apply visibility rules', () {
        final rule = CertificationVisibilityRule(
          id: 'certification_visibility_1',
          name: 'Certification Visibility Rule',
          description: 'Shows certification fields',
          priority: 40,
          triggerField: 'voltage',
          triggerValue: '380',
        );

        visibilityEngine.addRule(rule);

        final context = RuleContext(
          formData: {'voltage': '380'},
          metadata: {'productType': 'industrial'},
        );

        final result = visibilityEngine.applyVisibilityRules([], context);

        expect(result, isA<List<FormFieldConfig>>());
      });

      test('should handle multiple visibility rules', () {
        final rules = [
          CertificationVisibilityRule(
            id: 'certification_visibility_1',
            name: 'Certification Visibility Rule',
            description: 'Shows certification fields',
            priority: 40,
            triggerField: 'voltage',
            triggerValue: '380',
          ),
          ProductTypeVisibilityRule(
            id: 'product_type_visibility_1',
            name: 'Product Type Visibility Rule',
            description: 'Shows fields based on product type',
            priority: 45,
            productTypeFields: {
              'industrial': ['voltage', 'power']
            },
          ),
        ];

        visibilityEngine.addRules(rules);

        final context = RuleContext(
          formData: {'voltage': '380'},
          metadata: {'productType': 'industrial'},
        );

        final result = visibilityEngine.applyVisibilityRules([], context);

        expect(result, isA<List<FormFieldConfig>>());
      });
    });

    group('PriceAdjustment Tests', () {
      test('should correctly identify discount vs fee', () {
        final discount = PriceAdjustment(
          type: 'Volume Discount',
          amount: -250.0,
          percentage: 10.0,
        );

        final fee = PriceAdjustment(
          type: 'Urgency Fee',
          amount: 500.0,
          percentage: 20.0,
        );

        expect(discount.isDiscount, isTrue);
        expect(discount.isFee, isFalse);
        expect(fee.isDiscount, isFalse);
        expect(fee.isFee, isTrue);
      });
    });

    group('PricingResult Tests', () {
      test('should calculate total adjustment correctly', () {
        final result = PricingResult(
          basePrice: 2500.0,
          finalPrice: 2750.0,
          adjustments: [],
          errors: [],
          messages: [],
        );

        expect(result.totalAdjustment, equals(250.0));
      });

      test('should calculate savings amount correctly', () {
        final adjustments = [
          const PriceAdjustment(type: 'Volume Discount', amount: -375.0),
          const PriceAdjustment(type: 'VIP Discount', amount: -250.0),
          const PriceAdjustment(type: 'Urgency Fee', amount: 500.0),
        ];

        final result = PricingResult(
          basePrice: 2500.0,
          finalPrice: 2375.0,
          adjustments: adjustments,
          errors: [],
          messages: [],
        );

        expect(result.savingsAmount, equals(625.0)); // 375 + 250
      });
    });
  });
}

/// Test rule that causes errors
class _FaultyPricingRule extends PricingRule {
  _FaultyPricingRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
  });

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult execute(RuleContext context) {
    throw Exception('This rule is faulty');
  }

  @override
  double calculatePriceAdjustment(RuleContext context) {
    throw Exception('This rule is faulty');
  }
}

/// Test rule that stops execution
class _StoppingPricingRule extends PricingRule {
  _StoppingPricingRule({
    required super.id,
    required super.name,
    required super.description,
    required super.priority,
  });

  @override
  bool isApplicable(RuleContext context) => true;

  @override
  RuleResult execute(RuleContext context) {
    return RuleResult.failure(
      errors: ['Stopping Rule: Execution stopped'],
      shouldStopExecution: true,
    );
  }

  @override
  double calculatePriceAdjustment(RuleContext context) {
    return 0.0;
  }
}
