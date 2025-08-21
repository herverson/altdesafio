import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/products/product.dart';
import '../core/design/app_theme.dart';

class ProductSelector extends StatefulWidget {
  final List<Product> products;
  final Product? selectedProduct;
  final Function(Product) onProductSelected;

  const ProductSelector({
    super.key,
    required this.products,
    required this.selectedProduct,
    required this.onProductSelected,
  });

  @override
  State<ProductSelector> createState() => _ProductSelectorState();
}

class _ProductSelectorState extends State<ProductSelector> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final productTypes = _getProductTypes();
    final filteredProducts = _getFilteredProducts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione um Produto',
          style: AppTheme.headline3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'Escolha um produto para começar o orçamento',
          style: AppTheme.body2.copyWith(
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        if (productTypes.length > 1) ...[
          _buildTypeFilter(productTypes),
          const SizedBox(height: 16),
        ],
        _buildProductList(filteredProducts),
      ],
    );
  }

  List<String> _getProductTypes() {
    return widget.products.map((p) => p.productType).toSet().toList()..sort();
  }

  List<Product> _getFilteredProducts() {
    if (_selectedType == null) {
      return widget.products;
    }
    return widget.products
        .where((p) => p.productType == _selectedType)
        .toList();
  }

  Widget _buildTypeFilter(List<String> types) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = _selectedType == type ? null : type;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == type
                    ? Colors.white
                    : Colors.white.withOpacity(0.25),
                foregroundColor: _selectedType == type
                    ? AppTheme.primaryColor
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: _selectedType == type ? 4 : 0,
              ),
              child: Text(_getTypeDisplayName(type)),
            )
                .animate()
                .fadeIn(
                  delay: (100 * index).ms,
                  duration: 400.ms,
                )
                .slideY(begin: 0.3),
          );
        }).toList(),
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'industrial':
        return 'Industrial';
      case 'residential':
        return 'Residencial';
      case 'corporate':
        return 'Corporativo';
      default:
        return type;
    }
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_off,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Nenhum produto encontrado',
              style: AppTheme.body1.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms);
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = widget.selectedProduct?.id == product.id;

          return Container(
            width: 160,
            margin: EdgeInsets.only(
              right: index < products.length - 1 ? 8 : 0,
            ),
            child: _buildProductCard(product, isSelected, index),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isSelected, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onProductSelected(product),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getProductColor(product.productType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getProductIcon(product.productType),
                  color: isSelected
                      ? _getProductColor(product.productType)
                      : Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.textPrimaryColor
                            : Colors.white,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$ ',
                        decimalDigits: 2,
                      ).format(product.basePrice),
                      style: AppTheme.body2.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? AppTheme.successColor : Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 16,
                ).animate().scale(duration: 200.ms),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: (150 * index).ms,
          duration: 500.ms,
        )
        .slideY(begin: 0.3, curve: Curves.easeOutBack);
  }

  IconData _getProductIcon(String productType) {
    switch (productType) {
      case 'industrial':
        return Icons.precision_manufacturing;
      case 'residential':
        return Icons.home;
      case 'corporate':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  Color _getProductColor(String productType) {
    switch (productType) {
      case 'industrial':
        return AppTheme.accentColor;
      case 'residential':
        return AppTheme.secondaryColor;
      case 'corporate':
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}
