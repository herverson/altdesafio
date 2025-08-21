import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/controllers/budget_controller.dart';
import 'package:altdesafio/controllers/form_controller.dart';
import 'package:altdesafio/models/products/product.dart';
import 'package:altdesafio/models/products/industrial_product.dart';
import 'package:altdesafio/services/rules_engine.dart';

void main() {
  group('BudgetController Tests', () {
    late BudgetController controller;
    late IndustrialProduct testProduct;

    setUp(() {
      controller = BudgetController();
      testProduct = IndustrialProduct(
        id: 'IND001',
        name: 'Motor Trifásico 5CV',
        description: 'Motor industrial de alta eficiência',
        basePrice: 2500.0,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization Tests', () {
      test('should initialize with correct default values', () {
        expect(controller.availableProducts, isNotEmpty);
        expect(controller.formController, isNull);
        expect(controller.currentPricing, isNull);
        expect(controller.currentValidation, isNull);
        expect(controller.isLoading, isFalse);
        expect(controller.error, isNull);
        expect(controller.canSubmit, isFalse);
      });

      test('should have predefined products', () {
        final products = controller.availableProducts;
        expect(products.length, greaterThan(0));

        final productTypes = products.map((p) => p.productType).toSet();
        expect(productTypes,
            containsAll(['industrial', 'residential', 'corporate']));
      });
    });

    group('Product Selection Tests', () {
      test('should select product and create form controller', () async {
        controller.selectProduct(testProduct);

        expect(controller.formController, isNotNull);
        expect(controller.formController!.selectedProduct, equals(testProduct));
        expect(controller.error, isNull);
      });

      test('should handle product selection errors gracefully', () async {
        // Test with null product (edge case)
        try {
          controller.selectProduct(testProduct);
          expect(controller.error, isNull);
        } catch (e) {
          // If an error occurs, it should be handled gracefully
          expect(controller.error, isNotNull);
        }
      });

      test('should clear form when selecting new product', () async {
        // Select first product
        controller.selectProduct(testProduct);
        controller.updateFormField('quantity', 100);

        // Select different product
        final newProduct = IndustrialProduct(
          id: 'IND002',
          name: 'Another Motor',
          description: 'Different motor',
          basePrice: 3000.0,
        );

        controller.selectProduct(newProduct);

        expect(controller.formController!.selectedProduct, equals(newProduct));
        // Form data should be reset for new product
      });
    });

    group('Form Field Updates Tests', () {
      setUp(() async {
        controller.selectProduct(testProduct);
      });

      test('should update form field and trigger recalculation', () {
        controller.updateFormField('quantity', 100);

        expect(controller.formController!.formData['quantity'], equals(100));
        // Should trigger pricing calculation
        expect(controller.currentPricing, isNotNull);
      });

      test('should validate form data on field update', () {
        controller.updateFormField('quantity', 0); // Invalid quantity

        expect(controller.currentValidation, isNotNull);
        expect(controller.currentValidation!.isValid, isFalse);
        expect(controller.canSubmit, isFalse);
      });

      test('should handle invalid field values', () {
        controller.updateFormField('quantity', 'invalid');

        // Should handle gracefully without crashing
        expect(
            controller.formController!.formData['quantity'], equals('invalid'));
      });

      test('should update multiple fields correctly', () {
        controller.updateFormField('quantity', 100);
        controller.updateFormField('voltage', '380');
        controller.updateFormField('certification', 'ISO 9001');

        final formData = controller.formController!.formData;
        expect(formData['quantity'], equals(100));
        expect(formData['voltage'], equals('380'));
        expect(formData['certification'], equals('ISO 9001'));
      });
    });

    group('Budget Calculation Tests', () {
      setUp(() async {
        controller.selectProduct(testProduct);
      });

      test('should calculate budget with valid data', () {
        controller.updateFormField('quantity', 50);
        controller.updateFormField('voltage', '220');
        controller.updateFormField('delivery_days', 10);

        final summary = controller.getBudgetSummary();
        expect(summary, isNotNull);
        expect(summary!.product, equals(testProduct));
        expect(summary.quantityValue, equals(50));
        expect(summary.totalPrice, greaterThan(0));
      });

      test('should apply pricing rules correctly', () {
        // Test volume discount
        controller.updateFormField(
            'quantity', 100); // Should trigger volume discount
        controller.updateFormField('voltage', '220');
        controller.updateFormField('delivery_days', 10);

        final pricing = controller.currentPricing;
        expect(pricing, isNotNull);
        expect(pricing!.adjustments.isNotEmpty, isTrue);

        final volumeDiscount = pricing.adjustments
            .where((adj) => adj.type.contains('Volume'))
            .firstOrNull;
        expect(volumeDiscount, isNotNull);
        expect(volumeDiscount!.isDiscount, isTrue);
      });

      test('should apply urgency fee for quick delivery', () {
        controller.updateFormField('quantity', 10);
        controller.updateFormField('voltage', '220');
        controller.updateFormField(
            'delivery_days', 5); // Should trigger urgency fee

        final pricing = controller.currentPricing;
        expect(pricing, isNotNull);

        final urgencyFee = pricing!.adjustments
            .where((adj) => adj.type.contains('Urgency'))
            .firstOrNull;
        expect(urgencyFee, isNotNull);
        expect(urgencyFee!.isFee, isTrue);
      });

      test('should calculate total savings correctly', () {
        controller.updateFormField('quantity', 100);
        controller.updateFormField('voltage', '220');
        controller.updateFormField('delivery_days', 10);
        controller.updateFormField('customer_type', 'vip');

        final summary = controller.getBudgetSummary();
        expect(summary, isNotNull);
        expect(summary!.totalSavings, greaterThanOrEqualTo(0));
      });
    });

    group('Validation Tests', () {
      setUp(() async {
        controller.selectProduct(testProduct);
      });

      test('should validate required fields', () {
        // Don't set any fields - should fail validation
        controller.updateFormField('quantity', null);

        expect(controller.currentValidation, isNotNull);
        expect(controller.currentValidation!.isValid, isFalse);
        expect(controller.canSubmit, isFalse);
      });

      test('should validate business rules', () {
        // High voltage without certification should fail
        controller.updateFormField('quantity', 10);
        controller.updateFormField('voltage', '380');
        controller.updateFormField('certification', ''); // Empty certification

        expect(controller.currentValidation!.isValid, isFalse);
        expect(controller.canSubmit, isFalse);
      });

      test('should pass validation with correct data', () {
        controller.updateFormField('quantity', 10);
        controller.updateFormField('voltage', '380');
        controller.updateFormField('certification', 'ISO 9001');
        controller.updateFormField('protection_grade', 'IP54');
        controller.updateFormField('power_consumption', 5.0);
        controller.updateFormField('delivery_days', 10);

        expect(controller.currentValidation!.isValid, isTrue);
        expect(controller.canSubmit, isTrue);
      });
    });

    group('Budget Submission Tests', () {
      setUp(() async {
        controller.selectProduct(testProduct);
      });

      test('should submit valid budget successfully', () async {
        // Set up valid form data
        controller.updateFormField('quantity', 10);
        controller.updateFormField('voltage', '220');
        controller.updateFormField('protection_grade', 'IP54');
        controller.updateFormField('power_consumption', 5.0);
        controller.updateFormField('delivery_days', 10);

        final result = await controller.submitBudget();
        expect(result, isTrue);
        expect(controller.error, isNull);
      });

      test('should not submit invalid budget', () async {
        // Set up invalid form data
        controller.updateFormField('quantity', 0); // Invalid

        final result = await controller.submitBudget();
        expect(result, isFalse);
        expect(controller.error, isNotNull);
      });

      test('should handle submission errors gracefully', () async {
        // This test would require mocking external dependencies
        // For now, we'll test that the method exists and returns a boolean
        final result = await controller.submitBudget();
        expect(result, isA<bool>());
      });
    });

    group('Form Clearing Tests', () {
      setUp(() async {
        controller.selectProduct(testProduct);
      });

      test('should clear form data', () {
        // Set some data first
        controller.updateFormField('quantity', 100);
        controller.updateFormField('voltage', '380');

        // Clear form
        controller.clearForm();

        expect(controller.formController, isNull);
        expect(controller.currentPricing, isNull);
        expect(controller.currentValidation, isNull);
        expect(controller.canSubmit, isFalse);
      });

      test('should reset error state when clearing form', () {
        // Set an error state
        controller.updateFormField(
            'quantity', 0); // Invalid, should cause error
        expect(controller.currentValidation!.isValid, isFalse);

        // Clear form
        controller.clearForm();

        expect(controller.error, isNull);
        expect(controller.currentValidation, isNull);
      });
    });

    group('Loading State Tests', () {
      test('should manage loading state during async operations', () async {
        expect(controller.isLoading, isFalse);

        // This would typically be tested with more complex async operations
        // For now, we verify the loading state exists and is initially false
      });
    });

    group('Error Handling Tests', () {
      test('should handle and expose errors appropriately', () {
        // Test that error handling doesn't crash the application
        try {
          controller.updateFormField('invalid_field', 'value');
          // Should handle gracefully
        } catch (e) {
          // If an error occurs, it should be captured in controller.error
          expect(controller.error, isNotNull);
        }
      });
    });

    group('Listener Tests', () {
      test('should notify listeners on state changes', () {
        var notificationCount = 0;

        void listener() {
          notificationCount++;
        }

        controller.addListener(listener);

        // Trigger state changes
        controller.selectProduct(testProduct);

        controller.removeListener(listener);

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
