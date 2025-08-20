import 'package:flutter/material.dart';
import '../models/products/product.dart';

class ProductSelector extends StatefulWidget {
  final List<Product> products;
  final Product? selectedProduct;
  final Function(Product) onProductSelected;

  const ProductSelector({
    Key? key,
    required this.products,
    required this.selectedProduct,
    required this.onProductSelected,
  }) : super(key: key);

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
        const Text(
          'Selecione um Produto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Filtro por tipo
        if (productTypes.length > 1) ...[
          _buildTypeFilter(productTypes),
          const SizedBox(height: 16),
        ],

        // Lista de produtos
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
        children: [
          _buildTypeChip('Todos', null),
          const SizedBox(width: 8),
          ...types.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildTypeChip(_getTypeDisplayName(type), type),
              )),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String? type) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.white,
        fontWeight: FontWeight.w500,
      ),
      checkmarkColor: Colors.blue.shade700,
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Nenhum produto encontrado',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = widget.selectedProduct?.id == product.id;

          return Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index < products.length - 1 ? 12 : 0,
            ),
            child: _buildProductCard(product, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onProductSelected(product),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getProductIcon(product.productType),
                    color: isSelected ? Colors.blue.shade700 : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue.shade700 : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.grey.shade600 : Colors.white70,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeDisplayName(product.productType),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.blue.shade700 : Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ ${product.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.green.shade700 : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
