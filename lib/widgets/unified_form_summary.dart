import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/form_controller.dart';
import '../controllers/budget_controller.dart';
import '../services/rules_engine.dart';
import '../models/products/product.dart';
import 'dynamic_form_field.dart';

class UnifiedFormSummary extends StatefulWidget {
  final FormController<Product> formController;
  final Function(String, dynamic) onFieldChanged;
  final BudgetSummary? budgetSummary;
  final PricingResult? pricingResult;
  final ValidationResult? validationResult;

  const UnifiedFormSummary({
    super.key,
    required this.formController,
    required this.onFieldChanged,
    required this.budgetSummary,
    required this.pricingResult,
    required this.validationResult,
  });

  @override
  State<UnifiedFormSummary> createState() => _UnifiedFormSummaryState();
}

class _UnifiedFormSummaryState extends State<UnifiedFormSummary>
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
          child: _buildUnifiedList(),
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
              'Configuração e Resumo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione um produto para ver os campos e cálculos',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedList() {
    final product = widget.formController.selectedProduct!;
    final fields = widget.formController.fields;
    final errors = widget.formController.errors;

    List<Widget> listItems = [];

    listItems.add(_buildProductHeader(product));

    if (fields.isNotEmpty) {
      listItems
          .add(_buildSectionHeader('Configuração do Produto', Icons.settings));

      for (var field in fields.where((field) => field.isVisible)) {
        listItems.add(_buildFormFieldItem(field, errors));
      }
    } else {
      listItems.add(_buildNoFieldsMessage());
    }

    if (widget.budgetSummary != null) {
      listItems
          .add(_buildSectionHeader('Resumo do Orçamento', Icons.calculate));
      listItems.add(_buildPricingDetails());

      if (widget.pricingResult != null &&
          widget.pricingResult!.adjustments.isNotEmpty) {
        listItems.add(_buildAdjustments());
      }

      if (widget.validationResult != null) {
        listItems.add(_buildValidationStatus());
      }

      listItems.add(_buildTotalSummary());
    } else {
      listItems
          .add(_buildSectionHeader('Resumo do Orçamento', Icons.calculate));
      listItems.add(_buildEmptyPricingState());
    }

    if (errors.isNotEmpty) {
      final displayErrors = errors.entries
          .where((entry) => !entry.key.startsWith('field_'))
          .toList();
      if (displayErrors.isNotEmpty) {
        listItems.add(_buildErrorSection(displayErrors));
      }
    }

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
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: listItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) => listItems[index],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                      'Base: ${NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$ ',
                        decimalDigits: 2,
                      ).format(product.basePrice)}',
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldItem(dynamic field, Map<String, String> errors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: DynamicFormField(
        config: field,
        value: widget.formController.formData[field.key],
        onChanged: (value) => widget.onFieldChanged(field.key, value),
        errorText: errors[field.key],
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

  Widget _buildEmptyPricingState() {
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
            Icons.calculate,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Configure o produto para ver os cálculos de preço.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetails() {
    if (widget.pricingResult == null || widget.budgetSummary == null) {
      return const SizedBox.shrink();
    }

    final pricing = widget.pricingResult!;
    final quantity = widget.budgetSummary!.quantity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes de Preço',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Preço Base (unid.)',
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$ ',
              decimalDigits: 2,
            ).format(pricing.basePrice),
          ),
          _buildPriceRow(
            'Quantidade',
            '${quantity}x',
          ),
          if (pricing.adjustments.isNotEmpty) ...[
            const Divider(height: 20),
            Text(
              'Ajustes Aplicados:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...pricing.adjustments.map((adj) => _buildAdjustmentRow(adj)),
          ],
          const Divider(height: 20),
          _buildPriceRow(
            'Preço Final (unid.)',
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$ ',
              decimalDigits: 2,
            ).format(pricing.finalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow(PriceAdjustment adjustment) {
    final isDiscount = adjustment.isDiscount;
    final color = isDiscount ? Colors.green : Colors.orange;
    final icon = isDiscount ? Icons.trending_down : Icons.trending_up;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              adjustment.type,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            '${isDiscount ? '' : '+'}${NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$ ',
              decimalDigits: 2,
            ).format(adjustment.amount.abs())}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustments() {
    if (widget.pricingResult == null ||
        widget.pricingResult!.adjustments.isEmpty) {
      return const SizedBox.shrink();
    }

    final pricing = widget.pricingResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Regras Aplicadas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ...pricing.adjustments.map((adj) => _buildAdjustmentCard(adj)),
      ],
    );
  }

  Widget _buildAdjustmentCard(PriceAdjustment adjustment) {
    final isDiscount = adjustment.isDiscount;
    final color = isDiscount ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isDiscount ? Icons.discount : Icons.add_circle,
            color: color.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adjustment.type,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color.shade700,
                    fontSize: 14,
                  ),
                ),
                if (adjustment.percentage != null)
                  Text(
                    '${adjustment.percentage!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${isDiscount ? '-' : '+'}${NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$ ',
              decimalDigits: 2,
            ).format(adjustment.amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    if (widget.validationResult == null) return const SizedBox.shrink();

    final validation = widget.validationResult!;
    final isValid = validation.isValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? 'Orçamento Válido' : 'Problemas Encontrados',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          if (!isValid && validation.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...validation.errors.take(3).map((error) => Padding(
                  padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Text(
                    '• $error',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                )),
            if (validation.errors.length > 3)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  '... e mais ${validation.errors.length - 3} problema(s)',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalSummary() {
    if (widget.budgetSummary == null) return const SizedBox.shrink();

    final summary = widget.budgetSummary!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total do Orçamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor total:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$ ',
                  decimalDigits: 2,
                ).format(summary.totalPrice),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (summary.totalSavings > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Economia total:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$ ',
                    decimalDigits: 2,
                  ).format(summary.totalSavings),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightGreenAccent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorSection(List<MapEntry<String, String>> displayErrors) {
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
