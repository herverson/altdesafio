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
        const SizedBox(height: 8),
        
        // Mensagem de boas-vindas
        const Text(
          'Escolha um produto para começar o orçamento',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
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
        children: types.map((type) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedType = _selectedType == type ? null : type;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedType == type ? Colors.white : Colors.white.withOpacity(0.25),
              foregroundColor: _selectedType == type ? Colors.blue.shade700 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(_getTypeDisplayName(type)),
          ),
        )).toList(),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Nenhum produto encontrado',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSelected = widget.selectedProduct?.id == product.id;

          return Container(
            width: 200,
            margin: EdgeInsets.only(
              right: index < products.length - 1 ? 8 : 0,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getProductIcon(product.productType),
                color: isSelected ? Colors.blue.shade700 : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.blue.shade700 : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'R\$ ${product.basePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.green.shade700 : Colors.white70,
                      ),
                    ),
                  ],
                ),
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
