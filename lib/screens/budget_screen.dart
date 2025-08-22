import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/budget_controller.dart';
import '../core/design/app_theme.dart';
import '../widgets/product_selector.dart';
import '../widgets/unified_form_summary.dart';
import '../widgets/loading_overlay.dart';

/// Tela principal do sistema de orçamentos
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

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
      duration: const Duration(milliseconds: 500),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'AltForce - Orçamentos Dinâmicos',
          style: AppTheme.headline3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_controller.formController?.selectedProduct != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _controller.clearForm,
              tooltip: 'Limpar formulário',
            ).animate().fadeIn(delay: 300.ms).scale(),
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
      floatingActionButton: _controller.formController?.selectedProduct != null
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: FloatingActionButton.extended(
                onPressed: _controller.canSubmit ? _onSubmitBudget : null,
                backgroundColor: _controller.canSubmit
                    ? AppTheme.successColor
                    : AppTheme.textLightColor,
                foregroundColor: Colors.white,
                elevation: _controller.canSubmit ? 8 : 2,
                icon: _controller.canSubmit
                    ? Icon(Icons.check_circle).animate().scale(duration: 200.ms)
                    : const Icon(Icons.block),
                label: Text(
                  'Gerar orçamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_controller.error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ProductSelector(
            products: _controller.availableProducts,
            selectedProduct: _controller.formController?.selectedProduct,
            onProductSelected: _controller.selectProduct,
          ),
        ),
        Expanded(
          child: _controller.formController?.selectedProduct != null
              ? _buildFormContent()
              : SingleChildScrollView(
                  child: _buildWelcomeState(),
                ),
        ),
      ],
    );
  }

  Widget _buildWelcomeState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.assignment,
                  size: 80,
                  color: AppTheme.textLightColor,
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo ao sistema',
                  style: AppTheme.headline2.copyWith(
                    color: AppTheme.textPrimaryColor,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                const SizedBox(height: 12),
                Text(
                  'Selecione um produto acima para começar',
                  style: AppTheme.body1.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Características do Sistema:',
            style: AppTheme.headline3.copyWith(
              color: AppTheme.textPrimaryColor,
            ),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.dynamic_form,
            title: 'Formulários Dinâmicos',
            description:
                'Campos que se adaptam automaticamente ao tipo de produto',
            delay: 700,
          ),
          _buildFeatureItem(
            icon: Icons.rule,
            title: 'Engine de Regras',
            description: 'Regras de negócio configuráveis e intercambiáveis',
            delay: 800,
          ),
          _buildFeatureItem(
            icon: Icons.calculate,
            title: 'Precificação Inteligente',
            description: 'Cálculos automáticos com descontos e taxas',
            delay: 900,
          ),
          _buildFeatureItem(
            icon: Icons.check_circle,
            title: 'Validação Avançada',
            description: 'Validações contextuais e interdependentes',
            delay: 1000,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.body2.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.3);
  }

  Widget _buildFormContent() {
    if (_controller.formController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: UnifiedFormSummary(
            formController: _controller.formController!,
            onFieldChanged: _controller.updateFormField,
            budgetSummary: _controller.getBudgetSummary(),
            pricingResult: _controller.currentPricing,
            validationResult: _controller.currentValidation,
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor,
            ).animate().shake(duration: 600.ms),
            const SizedBox(height: 20),
            Text(
              'Erro ao carregar sistema',
              style: AppTheme.headline2.copyWith(
                color: AppTheme.errorColor,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              _controller.error!,
              style: AppTheme.body1.copyWith(
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _controller.clearForm();

                _controller.dispose();
                setState(() {
                  _controller = BudgetController();
                  _controller.addListener(_onControllerChanged);
                });
              },
              child: const Text('Tentar Novamente'),
            ).animate().fadeIn(delay: 600.ms).scale(),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmitBudget() async {
    final success = await _controller.submitBudget();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Orçamento gerado com sucesso!'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(_controller.error ?? 'Erro ao gerar orçamento'),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
