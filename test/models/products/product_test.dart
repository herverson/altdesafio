import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/models/products/product.dart';
import 'package:altdesafio/models/products/industrial_product.dart';
import 'package:altdesafio/models/products/residential_product.dart';
import 'package:altdesafio/models/products/corporate_product.dart';

void main() {
  group('Product Tests', () {
    late IndustrialProduct industrialProduct;
    late ResidentialProduct residentialProduct;
    late CorporateProduct corporateProduct;

    setUp(() {
      industrialProduct = IndustrialProduct(
        id: 'IND001',
        name: 'Motor Trifásico 5CV',
        description: 'Motor industrial de alta eficiência',
        basePrice: 2500.0,
      );

      residentialProduct = ResidentialProduct(
        id: 'RES001',
        name: 'Ventilador de Teto',
        description: 'Ventilador residencial silencioso',
        basePrice: 350.0,
      );

      corporateProduct = CorporateProduct(
        id: 'CORP001',
        name: 'Sistema ERP',
        description: 'Sistema de gestão empresarial',
        basePrice: 50000.0,
      );
    });

    group('Industrial Product Tests', () {
      test('should have correct product type', () {
        expect(industrialProduct.productType, equals('industrial'));
      });

      test('should return correct form fields', () {
        final fields = industrialProduct.getFormFields();
        expect(fields.length, greaterThan(0));
        
        final quantityField = fields.firstWhere((field) => field.key == 'quantity');
        expect(quantityField.label, equals('Quantidade'));
        expect(quantityField.isRequired, isTrue);
      });

      test('should calculate base price with voltage adjustment', () {
        final formData = {
          'voltage': '380',
          'protection_grade': 'IP54',
        };
        
        final calculatedPrice = industrialProduct.calculateBasePrice(formData);
        expect(calculatedPrice, equals(3000.0)); // 2500 * 1.2 (20% for high voltage)
      });

      test('should calculate base price with protection grade adjustment', () {
        final formData = {
          'voltage': '220',
          'protection_grade': 'IP65',
        };
        
        final calculatedPrice = industrialProduct.calculateBasePrice(formData);
        expect(calculatedPrice, equals(2750.0)); // 2500 * 1.1 (10% for IP65)
      });

      test('should validate certification requirement for high voltage', () {
        final formData = {
          'voltage': '380',
          'certification': '',
        };
        
        final errors = industrialProduct.validate(formData);
        expect(errors.length, equals(1));
        expect(errors.first, contains('certificação'));
      });

      test('should validate power consumption vs voltage', () {
        final formData = {
          'voltage': '220',
          'power_consumption': '15',
          'certification': 'ISO 9001',
        };
        
        final errors = industrialProduct.validate(formData);
        expect(errors.length, equals(1));
        expect(errors.first, contains('Consumo muito alto'));
      });

      test('should pass validation with correct data', () {
        final formData = {
          'voltage': '380',
          'certification': 'ISO 9001',
          'power_consumption': '5',
        };
        
        final errors = industrialProduct.validate(formData);
        expect(errors.isEmpty, isTrue);
      });

      test('should create copy with modifications', () {
        final copy = industrialProduct.copyWith(
          name: 'Motor Atualizado',
          basePrice: 3000.0,
        );
        
        expect(copy.name, equals('Motor Atualizado'));
        expect(copy.basePrice, equals(3000.0));
        expect(copy.id, equals(industrialProduct.id));
        expect(copy.description, equals(industrialProduct.description));
      });

      test('should convert to JSON correctly', () {
        final json = industrialProduct.toJson();
        
        expect(json['id'], equals('IND001'));
        expect(json['name'], equals('Motor Trifásico 5CV'));
        expect(json['basePrice'], equals(2500.0));
        expect(json['productType'], equals('industrial'));
      });
    });

    group('Residential Product Tests', () {
      test('should have correct product type', () {
        expect(residentialProduct.productType, equals('residential'));
      });

      test('should return residential-specific form fields', () {
        final fields = residentialProduct.getFormFields();
        expect(fields.length, greaterThan(0));
        
        // Check for common residential fields
        final quantityField = fields.firstWhere((field) => field.key == 'quantity');
        expect(quantityField.label, equals('Quantidade'));
        
        final colorField = fields.firstWhere((field) => field.key == 'color');
        expect(colorField.label, equals('Cor'));
      });

      test('should calculate base price with residential adjustments', () {
        final formData = {
          'color': 'white',
          'installation_type': 'standard',
        };
        
        final calculatedPrice = residentialProduct.calculateBasePrice(formData);
        expect(calculatedPrice, greaterThanOrEqualTo(350.0));
      });
    });

    group('Corporate Product Tests', () {
      test('should have correct product type', () {
        expect(corporateProduct.productType, equals('corporate'));
      });

      test('should return corporate-specific form fields', () {
        final fields = corporateProduct.getFormFields();
        expect(fields.length, greaterThan(0));
        
        // Check for common corporate fields
        final quantityField = fields.firstWhere((field) => field.key == 'quantity');
        expect(quantityField.label, equals('Quantidade'));
        
        final contractField = fields.firstWhere((field) => field.key == 'contract_type');
        expect(contractField.label, equals('Tipo de contrato'));
      });

      test('should calculate base price with corporate adjustments', () {
        final formData = {
          'quantity': 1,
          'contract_type': 'enterprise',
        };
        
        final calculatedPrice = corporateProduct.calculateBasePrice(formData);
        expect(calculatedPrice, greaterThanOrEqualTo(50000.0));
      });
    });

    group('Polymorphism Tests', () {
      test('should handle products polymorphically', () {
        final products = <Product>[
          industrialProduct,
          residentialProduct,
          corporateProduct,
        ];
        
        for (final product in products) {
          expect(product.id, isNotEmpty);
          expect(product.name, isNotEmpty);
          expect(product.basePrice, greaterThan(0));
          expect(product.getFormFields(), isNotEmpty);
          expect(product.productType, isNotEmpty);
        }
      });

      test('should have different product types', () {
        final products = <Product>[
          industrialProduct,
          residentialProduct,
          corporateProduct,
        ];
        
        final types = products.map((p) => p.productType).toSet();
        expect(types.length, equals(3));
        expect(types, containsAll(['industrial', 'residential', 'corporate']));
      });
    });
  });
}
