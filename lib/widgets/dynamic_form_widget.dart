import 'package:flutter/material.dart';
import '../controllers/form_controller.dart';
import '../models/products/product.dart';
import 'dynamic_form_field.dart';

class DynamicFormWidget extends StatefulWidget {
  final FormController<Product> formController;
  final Function(String, dynamic) onFieldChanged;

  const DynamicFormWidget({
    super.key,
    required this.formController,
    required this.onFieldChanged,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.formController.addListener(_onFormControllerChanged);

    if (widget.formController.selectedProduct != null) {
      _animationController.forward();
    }
  }

  void _onFormControllerChanged() {
    if (widget.formController.selectedProduct != null) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.formController,
      builder: (context, child) {
        if (widget.formController.selectedProduct == null) {
          return _buildEmptyState();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: _buildForm(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dynamic_form,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Formulário Dinâmico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione um produto para ver os campos específicos',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final product = widget.formController.selectedProduct!;
    final fields = widget.formController.fields;
    final errors = widget.formController.errors;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(product),
            const SizedBox(height: 24),
            if (fields.isNotEmpty) ...[
              _buildSectionTitle('Configuração do Produto'),
              const SizedBox(height: 16),
              ...fields.where((field) => field.isVisible).map((field) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: DynamicFormField(
                    config: field,
                    value: widget.formController.formData[field.key],
                    onChanged: (value) =>
                        widget.onFieldChanged(field.key, value),
                    errorText: errors[field.key],
                  ),
                );
              }),
            ] else ...[
              _buildNoFieldsMessage(),
            ],
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildErrorSection(errors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _getProductIcon(product.productType),
            color: Colors.blue.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeDisplayName(product.productType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Base: R\$ ${product.basePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNoFieldsMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhum campo configurado para este produto.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(Map<String, String> errors) {
    final displayErrors = errors.entries
        .where((entry) => !entry.key.startsWith('field_'))
        .toList();

    if (displayErrors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Problemas encontrados:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...displayErrors.map((entry) => Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text(
                  '• ${entry.value}',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 14,
                  ),
                ),
              )),
        ],
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

  @override
  void dispose() {
    widget.formController.removeListener(_onFormControllerChanged);
    _animationController.dispose();
    super.dispose();
  }
}
