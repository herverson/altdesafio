import 'package:flutter_test/flutter_test.dart';
import '../../lib/repositories/product_repository.dart';
import '../../lib/models/products/product.dart';
import '../../lib/models/products/industrial_product.dart';
import '../../lib/models/products/residential_product.dart';
import '../../lib/models/products/corporate_product.dart';

void main() {
  group('ProductRepository Tests', () {
    late ProductRepository repository;

    setUp(() {
      repository = ProductRepository();
    });

    group('Basic Repository Operations', () {
      test('should return all predefined products', () async {
        final result = await repository.getAll();

        expect(result.isSuccess, isTrue);
        
        final products = result.data!;
        expect(products, isNotEmpty);
        expect(products.length, greaterThanOrEqualTo(6)); // At least 2 of each type

        // Check that we have all product types
        final types = products.map((p) => p.productType).toSet();
        expect(types, containsAll(['industrial', 'residential', 'corporate']));
      });

      test('should find product by id', () async {
        final result = await repository.getAll();
        expect(result.isSuccess, isTrue);
        
        final products = result.data!;
        final firstProduct = products.first;

        final foundResult = await repository.findById(firstProduct.id);

        expect(foundResult.isSuccess, isTrue);
        final foundProduct = foundResult.data;
        expect(foundProduct, isNotNull);
        expect(foundProduct!.id, equals(firstProduct.id));
        expect(foundProduct.name, equals(firstProduct.name));
      });

      test('should return null for non-existent id', () async {
        final result = await repository.findById('non_existent_id');
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });

      test('should filter products by type', () async {
        final result = await repository.findByType('industrial');

        expect(result.isSuccess, isTrue);
        final industrialProducts = result.data!;
        expect(industrialProducts, isNotEmpty);
        for (final product in industrialProducts) {
          expect(product.productType, equals('industrial'));
          expect(product, isA<IndustrialProduct>());
        }
      });

      test('should return empty list for invalid type', () async {
        final result = await repository.findByType('invalid_type');
        expect(result.isSuccess, isTrue);
        expect(result.data!, isEmpty);
      });

      test('should filter products by price range', () async {
        final result = await repository.findByPriceRange(10000, 100000);

        expect(result.isSuccess, isTrue);
        final expensiveProducts = result.data!;
        expect(expensiveProducts, isNotEmpty);
        for (final product in expensiveProducts) {
          expect(product.basePrice, greaterThanOrEqualTo(10000));
          expect(product.basePrice, lessThanOrEqualTo(100000));
        }
      });

      test('should return empty list for impossible price range', () async {
        final result = await repository.findByPriceRange(1000000, 2000000);
        expect(result.isSuccess, isTrue);
        expect(result.data!, isEmpty);
      });
    });

    group('Product Type Validation', () {
      test('should contain correct industrial products', () async {
        final result = await repository.findByType('industrial');

        expect(result.isSuccess, isTrue);
        final industrialProducts = result.data!;
        expect(industrialProducts.length, greaterThanOrEqualTo(2));

        final motorProduct = industrialProducts.firstWhere(
            (p) => p.name.contains('Motor'),
            orElse: () => throw Exception('Motor not found'));
        expect(motorProduct.basePrice, greaterThan(0));
        expect(motorProduct.description, isNotEmpty);
      });

      test('should contain correct residential products', () async {
        final result = await repository.findByType('residential');

        expect(result.isSuccess, isTrue);
        final residentialProducts = result.data!;
        expect(residentialProducts.length, greaterThanOrEqualTo(2));

        // Check for typical residential products
        final productNames = residentialProducts.map((p) => p.name.toLowerCase()).join(' ');
        expect(productNames, contains('ventilador'));
      });

      test('should contain correct corporate products', () async {
        final result = await repository.findByType('corporate');

        expect(result.isSuccess, isTrue);
        final corporateProducts = result.data!;
        expect(corporateProducts.length, greaterThanOrEqualTo(2));

        // Check for typical corporate products
        final productNames = corporateProducts.map((p) => p.name.toLowerCase()).join(' ');
        expect(productNames, contains('erp'));
      });
    });

    group('Product Attributes', () {
      test('all products should have valid attributes', () async {
        final result = await repository.getAll();
        expect(result.isSuccess, isTrue);
        
        final products = result.data!;
        for (final product in products) {
          expect(product.id, isNotEmpty);
          expect(product.name, isNotEmpty);
          expect(product.description, isNotEmpty);
          expect(product.basePrice, greaterThan(0));
          expect(product.productType, isNotEmpty);
        }
      });

      test('products should have correct types', () async {
        final result = await repository.getAll();
        expect(result.isSuccess, isTrue);
        
        final products = result.data!;
        final industrialCount = products.where((p) => p is IndustrialProduct).length;
        final residentialCount = products.where((p) => p is ResidentialProduct).length;
        final corporateCount = products.where((p) => p is CorporateProduct).length;

        expect(industrialCount, greaterThanOrEqualTo(2));
        expect(residentialCount, greaterThanOrEqualTo(2));
        expect(corporateCount, greaterThanOrEqualTo(2));
      });
    });

    group('Repository Consistency', () {
      test('should return consistent results', () async {
        final result1 = await repository.getAll();
        final result2 = await repository.getAll();

        expect(result1.isSuccess, isTrue);
        expect(result2.isSuccess, isTrue);
        
        final products1 = result1.data!;
        final products2 = result2.data!;
        
        expect(products1.length, equals(products2.length));
        
        for (int i = 0; i < products1.length; i++) {
          expect(products1[i].id, equals(products2[i].id));
          expect(products1[i].name, equals(products2[i].name));
          expect(products1[i].basePrice, equals(products2[i].basePrice));
        }
      });

      test('findByType should be consistent with getAll filtering', () async {
        final allResult = await repository.getAll();
        final industrialResult = await repository.findByType('industrial');

        expect(allResult.isSuccess, isTrue);
        expect(industrialResult.isSuccess, isTrue);
        
        final allProducts = allResult.data!;
        final industrialProducts = industrialResult.data!;
        
        final filteredIndustrial = allProducts.where((p) => p.productType == 'industrial').toList();
        
        expect(industrialProducts.length, equals(filteredIndustrial.length));
        
        for (final product in industrialProducts) {
          expect(filteredIndustrial.any((p) => p.id == product.id), isTrue);
        }
      });
    });

    group('Error Handling', () {
      test('should handle empty id gracefully', () async {
        final result = await repository.findById('');
        expect(result.isFailure, isTrue);
        expect(result.error, contains('ID não pode ser vazio'));
      });

      test('should handle null-like ids gracefully', () async {
        final result = await repository.findById('null');
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent requests', () async {
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(repository.getAll());
        }
        final results = await Future.wait(futures);
        
        for (final result in results) {
          expect((result as dynamic).isSuccess, isTrue);
          expect((result as dynamic).data!, isNotEmpty);
        }
      });
    });
  });
}