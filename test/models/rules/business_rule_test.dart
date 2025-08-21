import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/models/rules/business_rule.dart';
import 'package:altdesafio/models/rules/pricing_rule.dart';
import 'package:altdesafio/models/rules/validation_rule.dart';
import 'package:altdesafio/models/rules/visibility_rule.dart';

void main() {
  group('BusinessRule Tests', () {
    group('RuleContext Tests', () {
      test('should create context with required data', () {
        final context = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 100.0},
          metadata: {'productType': 'industrial'},
        );

        expect(context.formData['quantity'], equals(10));
        expect(context.calculatedData['basePrice'], equals(100.0));
        expect(context.metadata['productType'], equals('industrial'));
      });

      test('should create context with optional data', () {
        final context = RuleContext(
          formData: {'quantity': 10},
        );

        expect(context.formData['quantity'], equals(10));
        expect(context.calculatedData, isEmpty);
        expect(context.metadata, isEmpty);
      });

      test('should copy context with new data', () {
        final original = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 100.0},
          metadata: {'productType': 'industrial'},
        );

        final copy = original.copyWith(
          formData: {'quantity': 20},
          calculatedData: {'basePrice': 200.0},
        );

        expect(copy.formData['quantity'], equals(20));
        expect(copy.calculatedData['basePrice'], equals(200.0));
        expect(copy.metadata['productType'], equals('industrial'));
      });
    });

    group('RuleResult Tests', () {
      test('should create success result', () {
        final result = RuleResult.success(
          message: 'Operation successful',
          changes: {'discount': 10.0},
        );

        expect(result.success, isTrue);
        expect(result.message, equals('Operation successful'));
        expect(result.changes['discount'], equals(10.0));
        expect(result.errors, isEmpty);
        expect(result.shouldStopExecution, isFalse);
      });

      test('should create failure result', () {
        final result = RuleResult.failure(
          errors: ['Invalid quantity', 'Invalid price'],
          shouldStopExecution: true,
        );

        expect(result.success, isFalse);
        expect(result.message, isNull);
        expect(result.changes, isEmpty);
        expect(result.errors, equals(['Invalid quantity', 'Invalid price']));
        expect(result.shouldStopExecution, isTrue);
      });
    });

    group('PricingRule Tests', () {
      test('VolumeDiscountRule should apply discount for large quantities', () {
        final rule = VolumeDiscountRule(
          id: 'volume_discount_1',
          name: 'Volume Discount Rule',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );
        final context = RuleContext(
          formData: {'quantity': 100},
          calculatedData: {'basePrice': 2500.0},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isTrue);
        expect(result.changes['volumeDiscountAmount'], lessThan(0));
        expect(result.changes['volumeDiscountPercentage'], equals(15.0));
      });

      test('VolumeDiscountRule should not apply for small quantities', () {
        final rule = VolumeDiscountRule(
          id: 'volume_discount_2',
          name: 'Volume Discount Rule 2',
          description: 'Applies discount for large quantities',
          priority: 80,
          minimumQuantity: 50,
          discountPercentage: 15.0,
        );
        final context = RuleContext(
          formData: {'quantity': 10},
          calculatedData: {'basePrice': 2500.0},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isFalse);
      });

      test('UrgencyFeeRule should apply fee for urgent delivery', () {
        final rule = UrgencyFeeRule(
          id: 'urgency_fee_1',
          name: 'Urgency Fee Rule',
          description: 'Applies fee for urgent delivery',
          priority: 90,
          maxDeliveryDays: 7,
          feePercentage: 20.0,
        );
        final context = RuleContext(
          formData: {'delivery_days': 5},
          calculatedData: {'basePrice': 2500.0},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isTrue);
        expect(result.changes['urgencyFeeAmount'], greaterThan(0));
        expect(result.changes['urgencyFeePercentage'], equals(20.0));
      });

      test('VipDiscountRule should apply discount for VIP customers', () {
        final rule = VipDiscountRule(
          id: 'vip_discount_1',
          name: 'VIP Discount Rule',
          description: 'Applies discount for VIP customers',
          priority: 70,
          discountPercentage: 10.0,
          vipCustomers: ['customer_001'],
        );
        final context = RuleContext(
          formData: {'customer_type': 'vip'},
          calculatedData: {'basePrice': 2500.0},
          metadata: {'productType': 'industrial', 'customerId': 'customer_001'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isTrue);
        expect(result.changes['vipDiscountAmount'], lessThan(0));
        expect(result.changes['vipDiscountPercentage'], equals(10.0));
      });
    });

    group('ValidationRule Tests', () {
      test('QuantityValidationRule should validate minimum quantity', () {
        final rule = QuantityValidationRule(
          id: 'quantity_validation_1',
          name: 'Quantity Validation Rule',
          description: 'Validates minimum quantity',
          priority: 50,
          minimumQuantity: 1,
        );
        final context = RuleContext(
          formData: {'quantity': 0},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('Quantidade mínima'));
      });

      test(
          'CertificationValidationRule should validate certification for high voltage',
          () {
        final rule = CertificationValidationRule(
          id: 'certification_validation_1',
          name: 'Certification Validation Rule',
          description: 'Validates certification for high voltage',
          priority: 60,
          voltageThreshold: 220.0,
        );
        final context = RuleContext(
          formData: {
            'voltage': '380',
            'certification': '',
          },
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('Certificação é obrigatória'));
      });

      test('DeliveryValidationRule should validate delivery days', () {
        final rule = DeliveryValidationRule(
          id: 'delivery_validation_1',
          name: 'Delivery Validation Rule',
          description: 'Validates delivery days',
          priority: 55,
          maxDeliveryDays: 30,
          minDeliveryDays: 1,
        );
        final context = RuleContext(
          formData: {'delivery_days': 0},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isFalse);
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('Prazo mínimo'));
      });
    });

    group('VisibilityRule Tests', () {
      test('CertificationVisibilityRule should show certification fields', () {
        final rule = CertificationVisibilityRule(
          id: 'certification_visibility_1',
          name: 'Certification Visibility Rule',
          description: 'Shows certification fields',
          priority: 40,
          triggerField: 'voltage',
          triggerValue: '380',
        );
        final context = RuleContext(
          formData: {'voltage': '380'},
          metadata: {'productType': 'industrial'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isTrue);
        expect(result.changes['certificationFieldsVisible'], isTrue);
      });

      test(
          'SupportVisibilityRule should show support fields for corporate products',
          () {
        final rule = SupportVisibilityRule(
          id: 'support_visibility_1',
          name: 'Support Visibility Rule',
          description: 'Shows support fields for corporate products',
          priority: 45,
          productType: 'corporate',
        );
        final context = RuleContext(
          formData: {},
          metadata: {'productType': 'corporate'},
        );

        expect(rule.isApplicable(context), isTrue);

        final result = rule.execute(context);
        expect(result.success, isTrue);
        expect(result.changes['supportFieldsVisible'], isTrue);
      });
    });

    group('Rule Priority Tests', () {
      test('should execute rules in priority order', () {
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

        // Sort by priority (higher priority first)
        rules.sort((a, b) => b.priority.compareTo(a.priority));

        expect(rules[0].priority, equals(90)); // UrgencyFeeRule
        expect(rules[1].priority, equals(80)); // VolumeDiscountRule
        expect(rules[2].priority, equals(70)); // VipDiscountRule
      });
    });
  });
}
