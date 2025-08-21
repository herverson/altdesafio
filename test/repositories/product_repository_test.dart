import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/repositories/product_repository.dart';
import 'package:altdesafio/repositories/repository.dart';
import 'package:altdesafio/models/products/product.dart';
import 'package:altdesafio/models/products/industrial_product.dart';

void main() {
  group('ProductRepository Tests', () {
    late ProductRepository repository;

    setUp(() {
      repository = ProductRepository();
    });

    group('Basic Repository Operations', () {
      test('should return all predefined products', () async {
        final products = await repository.getAll();

        expect(products, isNotEmpty);
        expect(products.length,
            greaterThanOrEqualTo(6)); // At least 2 of each type

        // Check that we have all product types
        final types = products.map((p) => p.productType).toSet();
        expect(types, containsAll(['industrial', 'residential', 'corporate']));
      });

      test('should find product by id', () async {
        final products = await repository.getAll();
        final firstProduct = products.first;

        final foundProduct = await repository.findById(firstProduct.id);

        expect(foundProduct, isNotNull);
        expect(foundProduct!.id, equals(firstProduct.id));
        expect(foundProduct.name, equals(firstProduct.name));
      });

      test('should return null for non-existent id', () async {
        final product = await repository.findById('non_existent_id');
        expect(product, isNull);
      });

      test('should filter products by type', () async {
        final industrialProducts = await repository.findByType('industrial');

        expect(industrialProducts, isNotEmpty);
        for (final product in industrialProducts) {
          expect(product.productType, equals('industrial'));
          expect(product, isA<IndustrialProduct>());
        }
      });

      test('should return empty list for invalid type', () async {
        final products = await repository.findByType('invalid_type');
        expect(products, isEmpty);
      });

      test('should filter products by price range', () async {
        final expensiveProducts =
            await repository.findByPriceRange(10000, 100000);

        expect(expensiveProducts, isNotEmpty);
        for (final product in expensiveProducts) {
          expect(product.basePrice, greaterThanOrEqualTo(10000));
          expect(product.basePrice, lessThanOrEqualTo(100000));
        }
      });

      test('should return empty list for impossible price range', () async {
        final products = await repository.findByPriceRange(1000000, 2000000);
        expect(products, isEmpty);
      });
    });

    group('Product Type Validation', () {
      test('should contain correct industrial products', () async {
        final industrialProducts = await repository.findByType('industrial');

        expect(industrialProducts.length, greaterThanOrEqualTo(2));

        final motorProduct = industrialProducts.firstWhere(
            (p) => p.name.contains('Motor'),
            orElse: () => throw Exception('Motor not found'));
        expect(motorProduct.basePrice, greaterThan(0));
        expect(motorProduct.description, isNotEmpty);
      });

      test('should contain correct residential products', () async {
        final residentialProducts = await repository.findByType('residential');

        expect(residentialProducts.length, greaterThanOrEqualTo(2));

        // Check for typical residential products
        final productNames =
            residentialProducts.map((p) => p.name.toLowerCase()).join(' ');
        expect(
            productNames,
            anyOf([
              contains('ventilador'),
              contains('ar condicionado'),
              contains('residential'),
            ]));
      });

      test('should contain correct corporate products', () async {
        final corporateProducts = await repository.findByType('corporate');

        expect(corporateProducts.length, greaterThanOrEqualTo(2));

        // Corporate products should generally be more expensive
        final avgPrice =
            corporateProducts.map((p) => p.basePrice).reduce((a, b) => a + b) /
                corporateProducts.length;
        expect(avgPrice,
            greaterThan(10000)); // Corporate products should be expensive
      });
    });

    group('Repository Interface Compliance', () {
      test('should implement IRepository interface correctly', () {
        expect(repository, isA<IRepository<Product>>());
      });

      test('should handle async operations properly', () async {
        // Test that all methods return Future
        expect(repository.getAll(), isA<Future<List<Product>>>());
        expect(repository.findById('test'), isA<Future<Product?>>());
      });

      test('should maintain data consistency across calls', () async {
        final products1 = await repository.getAll();
        final products2 = await repository.getAll();

        expect(products1.length, equals(products2.length));

        // Check that the same products are returned
        for (int i = 0; i < products1.length; i++) {
          expect(products1[i].id, equals(products2[i].id));
          expect(products1[i].name, equals(products2[i].name));
        }
      });
    });

    group('Product Attributes', () {
      test('should have valid form fields for all products', () async {
        final products = await repository.getAll();

        for (final product in products) {
          final fields = product.getFormFields();
          expect(fields, isNotEmpty);

          // Each field should have required properties
          for (final field in fields) {
            expect(field.key, isNotEmpty);
            expect(field.label, isNotEmpty);
            expect(field.order, greaterThanOrEqualTo(0));
          }
        }
      });

      test('should have unique form field keys within each product', () async {
        final products = await repository.getAll();

        for (final product in products) {
          final fields = product.getFormFields();
          final keys = fields.map((f) => f.key).toList();
          final uniqueKeys = keys.toSet();

          expect(uniqueKeys.length, equals(keys.length),
              reason: 'Product ${product.name} has duplicate field keys');
        }
      });

      test('should have consistent field ordering', () async {
        final products = await repository.getAll();

        for (final product in products) {
          final fields = product.getFormFields();

          // Fields should be ordered by their order property
          for (int i = 1; i < fields.length; i++) {
            expect(fields[i].order, greaterThanOrEqualTo(fields[i - 1].order),
                reason: 'Fields not properly ordered in ${product.name}');
          }
        }
      });
    });

    group('Business Logic Validation', () {
      test('should validate products have reasonable base prices', () async {
        final products = await repository.getAll();

        for (final product in products) {
          expect(product.basePrice, greaterThan(0));
          expect(
              product.basePrice, lessThan(1000000)); // Reasonable upper limit
        }
      });

      test('should validate industrial products have appropriate fields',
          () async {
        final industrialProducts = await repository.findByType('industrial');

        for (final product in industrialProducts) {
          final fields = product.getFormFields();
          final fieldKeys = fields.map((f) => f.key).toSet();

          // Industrial products should have these critical fields
          expect(fieldKeys, contains('quantity'));
          expect(fieldKeys, contains('voltage'));
          expect(fieldKeys, contains('delivery_days'));
        }
      });

      test('should validate residential products have appropriate fields',
          () async {
        final residentialProducts = await repository.findByType('residential');

        for (final product in residentialProducts) {
          final fields = product.getFormFields();
          final fieldKeys = fields.map((f) => f.key).toSet();

          // Residential products should have quantity at minimum
          expect(fieldKeys, contains('quantity'));
        }
      });

      test('should validate corporate products have appropriate fields',
          () async {
        final corporateProducts = await repository.findByType('corporate');

        for (final product in corporateProducts) {
          final fields = product.getFormFields();
          final fieldKeys = fields.map((f) => f.key).toSet();

          // Corporate products should have these business-oriented fields
          expect(fieldKeys, contains('contract_type'));
          expect(fieldKeys, contains('support_level'));
        }
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent requests', () async {
        final futures = List.generate(10, (index) => repository.getAll());
        final results = await Future.wait(futures);

        expect(results.length, equals(10));

        // All results should be identical
        for (int i = 1; i < results.length; i++) {
          expect(results[i].length, equals(results[0].length));
        }
      });

      test('should complete operations within reasonable time', () async {
        final stopwatch = Stopwatch()..start();

        await repository.getAll();

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });
    });

    group('Error Handling', () {
      test('should handle null/empty parameters gracefully', () async {
        expect(() => repository.findById(''), returnsNormally);
        expect(() => repository.findByType(''), returnsNormally);
      });

      test('should return consistent results for edge cases', () async {
        final emptyTypeProducts = await repository.findByType('');
        expect(emptyTypeProducts, isEmpty);

        final invalidRangeProducts =
            await repository.findByPriceRange(-100, -50);
        expect(invalidRangeProducts, isEmpty);
      });
    });
  });
}
