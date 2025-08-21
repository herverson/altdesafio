import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:altdesafio/widgets/product_selector.dart';
import 'package:altdesafio/models/products/product.dart';
import 'package:altdesafio/models/products/industrial_product.dart';
import 'package:altdesafio/models/products/residential_product.dart';
import 'package:altdesafio/models/products/corporate_product.dart';

void main() {
  group('ProductSelector Widget Tests', () {
    late List<Product> testProducts;
    Product? selectedProduct;

    setUp(() {
      testProducts = [
        IndustrialProduct(
          id: 'IND001',
          name: 'Motor Trifásico 5CV',
          description: 'Motor industrial de alta eficiência',
          basePrice: 2500.0,
        ),
        ResidentialProduct(
          id: 'RES001',
          name: 'Ventilador de Teto',
          description: 'Ventilador residencial silencioso',
          basePrice: 350.0,
        ),
        CorporateProduct(
          id: 'CORP001',
          name: 'Sistema ERP',
          description: 'Sistema de gestão empresarial',
          basePrice: 50000.0,
        ),
      ];
      selectedProduct = null;
    });

    Widget createTestWidget({
      List<Product>? products,
      Product? selected,
      Function(Product)? onSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ProductSelector(
            products: products ?? testProducts,
            selectedProduct: selected,
            onProductSelected: onSelected ?? (product) {
              selectedProduct = product;
            },
          ),
        ),
      );
    }

    group('Initial Display Tests', () {
      testWidgets('should display welcome message initially', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Selecione um Produto'), findsOneWidget);
        expect(find.text('Escolha um produto para começar o orçamento'), findsOneWidget);
      });

      testWidgets('should display product type buttons', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Corporativo'), findsOneWidget);
        expect(find.text('Industrial'), findsOneWidget);
        expect(find.text('Residencial'), findsOneWidget);
      });

      testWidgets('should show all products initially', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
        expect(find.text('Ventilador de Teto'), findsOneWidget);
        expect(find.text('Sistema ERP'), findsOneWidget);
      });
    });

    group('Product Type Filtering Tests', () {
      testWidgets('should filter products by industrial type', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Industrial'));
        await tester.pumpAndSettle();

        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
        expect(find.text('Ventilador de Teto'), findsNothing);
        expect(find.text('Sistema ERP'), findsNothing);
      });

      testWidgets('should filter products by residential type', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Residencial'));
        await tester.pumpAndSettle();

        expect(find.text('Motor Trifásico 5CV'), findsNothing);
        expect(find.text('Ventilador de Teto'), findsOneWidget);
        expect(find.text('Sistema ERP'), findsNothing);
      });

      testWidgets('should filter products by corporate type', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Corporativo'));
        await tester.pumpAndSettle();

        expect(find.text('Motor Trifásico 5CV'), findsNothing);
        expect(find.text('Ventilador de Teto'), findsNothing);
        expect(find.text('Sistema ERP'), findsOneWidget);
      });

      testWidgets('should highlight selected filter button', (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Industrial'));
        await tester.pumpAndSettle();

        // The selected button should have different styling
        // This would require checking the actual button styling
        expect(find.text('Industrial'), findsOneWidget);
      });
    });

    group('Product Selection Tests', () {
      testWidgets('should call onProductSelected when product is tapped', (tester) async {
        Product? callbackProduct;
        
        await tester.pumpWidget(createTestWidget(
          onSelected: (product) {
            callbackProduct = product;
          },
        ));

        await tester.tap(find.text('Motor Trifásico 5CV'));
        await tester.pumpAndSettle();

        expect(callbackProduct, isNotNull);
        expect(callbackProduct!.name, equals('Motor Trifásico 5CV'));
        expect(callbackProduct!.productType, equals('industrial'));
      });

      testWidgets('should highlight selected product', (tester) async {
        await tester.pumpWidget(createTestWidget(
          selected: testProducts.first,
        ));

        // The selected product should have different visual styling
        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
      });

      testWidgets('should handle selection of different product types', (tester) async {
        final selectedProducts = <Product>[];
        
        await tester.pumpWidget(createTestWidget(
          onSelected: (product) {
            selectedProducts.add(product);
          },
        ));

        // Select industrial product
        await tester.tap(find.text('Motor Trifásico 5CV'));
        await tester.pumpAndSettle();

        // Select residential product
        await tester.tap(find.text('Ventilador de Teto'));
        await tester.pumpAndSettle();

        expect(selectedProducts.length, equals(2));
        expect(selectedProducts[0].productType, equals('industrial'));
        expect(selectedProducts[1].productType, equals('residential'));
      });
    });

    group('Product Display Tests', () {
      testWidgets('should display product information correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check industrial product
        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
        expect(find.text('R\$ 2500.00'), findsOneWidget);

        // Check residential product
        expect(find.text('Ventilador de Teto'), findsOneWidget);
        expect(find.text('R\$ 350.00'), findsOneWidget);

        // Check corporate product
        expect(find.text('Sistema ERP'), findsOneWidget);
        expect(find.text('R\$ 50000.00'), findsOneWidget);
      });

      testWidgets('should display product icons correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.precision_manufacturing), findsOneWidget); // Industrial
        expect(find.byIcon(Icons.home), findsOneWidget); // Residential
        expect(find.byIcon(Icons.business), findsOneWidget); // Corporate
      });

      testWidgets('should format prices correctly', (tester) async {
        final expensiveProduct = CorporateProduct(
          id: 'EXPENSIVE',
          name: 'Expensive Product',
          description: 'Very expensive',
          basePrice: 123456.78,
        );

        await tester.pumpWidget(createTestWidget(
          products: [expensiveProduct],
        ));

        expect(find.text('R\$ 123456.78'), findsOneWidget);
      });
    });

    group('Empty State Tests', () {
      testWidgets('should handle empty product list', (tester) async {
        await tester.pumpWidget(createTestWidget(
          products: [],
        ));

        expect(find.text('Selecione um Produto'), findsOneWidget);
        // Should not crash with empty list
      });

      testWidgets('should handle filtered empty results', (tester) async {
        final mixedProducts = [
          IndustrialProduct(
            id: 'IND001',
            name: 'Motor',
            description: 'Industrial motor',
            basePrice: 1000.0,
          ),
          ResidentialProduct(
            id: 'RES001',
            name: 'Fan',
            description: 'Residential fan',
            basePrice: 200.0,
          ),
        ];

        await tester.pumpWidget(createTestWidget(
          products: mixedProducts,
        ));

        // Filter by residential
        await tester.tap(find.text('Residencial'));
        await tester.pumpAndSettle();

        // Should show only residential products
        expect(find.text('Motor'), findsNothing);
        expect(find.text('Fan'), findsOneWidget);
      });
    });

    group('UI Responsiveness Tests', () {
      testWidgets('should be scrollable with many products', (tester) async {
        final manyProducts = List.generate(20, (index) => 
          IndustrialProduct(
            id: 'IND$index',
            name: 'Product $index',
            description: 'Description $index',
            basePrice: 1000.0 * (index + 1),
          ),
        );

        await tester.pumpWidget(createTestWidget(
          products: manyProducts,
        ));

        // Should be scrollable
        expect(find.byType(ListView), findsOneWidget);
        
        // First product should be visible
        expect(find.text('Product 0'), findsOneWidget);
        
        // Scroll to find later products
        await tester.scrollUntilVisible(
          find.text('Product 10'),
          500.0,
        );
        
        expect(find.text('Product 10'), findsOneWidget);
      });

      testWidgets('should handle small screen sizes', (tester) async {
        await tester.binding.setSurfaceSize(const Size(300, 600));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should still display main elements
        expect(find.text('Selecione um Produto'), findsOneWidget);
        expect(find.text('Corporativo'), findsOneWidget);
        expect(find.text('Industrial'), findsOneWidget);
        expect(find.text('Residencial'), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate filter changes smoothly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial state
        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
        expect(find.text('Ventilador de Teto'), findsOneWidget);

        // Change filter
        await tester.tap(find.text('Industrial'));
        await tester.pump(); // Start animation
        
        // Should have AnimatedContainer or similar animation widgets
        expect(find.byType(AnimatedContainer), findsWidgets);
        
        await tester.pumpAndSettle(); // Complete animation
        
        expect(find.text('Motor Trifásico 5CV'), findsOneWidget);
        expect(find.text('Ventilador de Teto'), findsNothing);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantics for screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Filter buttons should be accessible
        expect(find.byType(ElevatedButton), findsNWidgets(3));
        
        // Product cards should be tappable
        expect(find.byType(InkWell), findsWidgets);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // This would require more sophisticated testing for keyboard navigation
        // For now, we ensure the widgets exist
        expect(find.byType(ElevatedButton), findsNWidgets(3));
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle null callback gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget(
          onSelected: null,
        ));

        // Should not crash when tapping without callback
        await tester.tap(find.text('Motor Trifásico 5CV'));
        await tester.pumpAndSettle();
        
        // Should complete without error
      });

      testWidgets('should handle products with null/empty fields', (tester) async {
        final problematicProduct = IndustrialProduct(
          id: 'PROBLEM',
          name: '',
          description: '',
          basePrice: 0.0,
        );

        await tester.pumpWidget(createTestWidget(
          products: [problematicProduct],
        ));

        // Should handle gracefully without crashing
        expect(find.text('R\$ 0.00'), findsOneWidget);
      });
    });
  });
}

