import 'package:flutter/material.dart';
import '../controllers/budget_controller.dart';
import '../services/rules_engine.dart';

class PricingSummary extends StatelessWidget {
  final BudgetSummary? budgetSummary;
  final PricingResult? pricingResult;
  final ValidationResult? validationResult;

  const PricingSummary({
    Key? key,
    required this.budgetSummary,
    required this.pricingResult,
    required this.validationResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (budgetSummary == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPricingDetails(),
          const SizedBox(height: 20),
          _buildAdjustments(),
          const SizedBox(height: 20),
          _buildValidationStatus(),
          const SizedBox(height: 20),
          _buildTotalSummary(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Resumo do Orçamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure o produto para ver os cálculos',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo do Orçamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          budgetSummary!.product.name,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingDetails() {
    final pricing = pricingResult!;
    final quantity = budgetSummary!.quantity;

    return Container(
      padding: const EdgeInsets.all(16),
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
            'R\$ ${pricing.basePrice.toStringAsFixed(2)}',
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
            'R\$ ${pricing.finalPrice.toStringAsFixed(2)}',
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
            '${isDiscount ? '' : '+'}R\$ ${adjustment.amount.abs().toStringAsFixed(2)}',
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
    final pricing = pricingResult!;
    if (pricing.adjustments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Regras Aplicadas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
            '${isDiscount ? '-' : '+'}R\$ ${adjustment.amount.abs().toStringAsFixed(2)}',
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
    final validation = validationResult!;
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
    final summary = budgetSummary!;

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
                'Valor Total:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              Text(
                'R\$ ${summary.totalPrice.toStringAsFixed(2)}',
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
                  'Economia Total:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'R\$ ${summary.totalSavings.toStringAsFixed(2)}',
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
}
