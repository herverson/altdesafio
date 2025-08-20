import 'package:flutter/material.dart';
import '../controllers/budget_controller.dart';

import '../widgets/product_selector.dart';
import '../widgets/dynamic_form_widget.dart';
import '../widgets/pricing_summary.dart';
import '../widgets/loading_overlay.dart';

/// Tela principal do sistema de orçamentos
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  late final BudgetController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = BudgetController();
    _controller.addListener(_onControllerChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'AltForce - Orçamentos Dinâmicos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_controller.formController?.selectedProduct != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _controller.clearForm,
              tooltip: 'Limpar formulário',
            ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(),
          ),
          if (_controller.isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Header com seletor de produto
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ProductSelector(
            products: _controller.availableProducts,
            selectedProduct: _controller.formController?.selectedProduct,
            onProductSelected: _controller.selectProduct,
          ),
        ),

        // Conteúdo principal
        Expanded(
          child: _controller.formController?.selectedProduct != null
              ? _buildFormContent()
              : _buildWelcomeState(),
        ),
      ],
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Bem-vindo ao Sistema de Orçamentos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selecione um produto acima para começar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 40),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Características do Sistema:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.dynamic_form,
            title: 'Formulários Dinâmicos',
            description:
                'Campos que se adaptam automaticamente ao tipo de produto',
          ),
          _buildFeatureItem(
            icon: Icons.rule,
            title: 'Engine de Regras',
            description: 'Regras de negócio configuráveis e intercambiáveis',
          ),
          _buildFeatureItem(
            icon: Icons.calculate,
            title: 'Precificação Inteligente',
            description: 'Cálculos automáticos com descontos e taxas',
          ),
          _buildFeatureItem(
            icon: Icons.check_circle,
            title: 'Validação Avançada',
            description: 'Validações contextuais e interdependentes',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formulário dinâmico
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: DynamicFormWidget(
              formController: _controller.formController!,
              onFieldChanged: _controller.updateFormField,
            ),
          ),
        ),

        // Resumo lateral
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Resumo de preços
              Expanded(
                child: PricingSummary(
                  budgetSummary: _controller.getBudgetSummary(),
                  pricingResult: _controller.currentPricing,
                  validationResult: _controller.currentValidation,
                ),
              ),

              // Botão de submit
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _controller.canSubmit ? _onSubmitBudget : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Gerar Orçamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Erro ao carregar sistema',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _controller.error!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              _controller.clearForm();
              // Recriar controller
              _controller.dispose();
              setState(() {
                _controller = BudgetController();
                _controller.addListener(_onControllerChanged);
              });
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmitBudget() async {
    final success = await _controller.submitBudget();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Orçamento gerado com sucesso!'),
            backgroundColor: Colors.green.shade600,
            action: SnackBarAction(
              label: 'Novo',
              textColor: Colors.white,
              onPressed: _controller.clearForm,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.error ?? 'Erro ao gerar orçamento'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
