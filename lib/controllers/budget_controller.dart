import 'package:flutter/foundation.dart';
import '../models/products/product.dart';
import '../repositories/product_repository.dart';
import '../services/rules_service.dart';
import '../services/rules_engine.dart';
import 'form_controller.dart';

/// Controller principal que coordena estados interdependentes
class BudgetController extends ChangeNotifier {
  final ProductRepository _productRepository;
  final RulesService _rulesService;

  FormController<Product>? _formController;
  List<Product> _availableProducts = [];
  PricingResult? _currentPricing;
  ValidationResult? _currentValidation;
  bool _isLoading = false;
  String? _error;

  BudgetController({
    ProductRepository? productRepository,
    RulesService? rulesService,
  })  : _productRepository = productRepository ?? ProductRepository(),
        _rulesService = rulesService ?? RulesService() {
    _loadProductsSync();
  }

  FormController<Product>? get formController => _formController;
  List<Product> get availableProducts => List.unmodifiable(_availableProducts);
  PricingResult? get currentPricing => _currentPricing;
  ValidationResult? get currentValidation => _currentValidation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canSubmit =>
      _formController?.isValid == true && _currentValidation?.isValid == true;

  /// Inicializar controller de forma síncrona (para testes)
  void _initializeSync() {
    try {
      _rulesService.initialize();

      _formController = FormController<Product>(
        pricingEngine: _rulesService.pricingEngine,
        validationEngine: _rulesService.validationEngine,
        visibilityEngine: _rulesService.visibilityEngine,
      );

      _formController!.addListener(_onFormChanged);

      _error = null;

      assert(_formController != null, 'Form controller should be created');
    } catch (e) {
      _error = 'Erro ao inicializar: $e';
    }
  }

  /// Carregar produtos do repositório (versão síncrona para testes)
  void _loadProductsSync() {
    try {
      _productRepository.findAll().then((products) {
        _availableProducts = products;
        notifyListeners();
      });
    } catch (e) {}
  }

  /// Selecionar produto (dispara recálculos)
  void selectProduct(Product product) {
    if (_formController == null) {
      _initializeSync();
    }

    _formController!.selectProduct(product);
    _recalculateAll();
  }

  /// Atualizar campo do formulário (dispara recálculos)
  void updateFormField(String key, dynamic value) {
    if (_formController == null) return;

    _formController!.updateField(key, value);
    _recalculateAll();
  }

  /// Listener para mudanças no formulário
  void _onFormChanged() {
    _recalculateAll();
  }

  /// Recalcular preços e validações (estados interdependentes)
  void _recalculateAll() {
    if (_formController?.selectedProduct == null) {
      _currentPricing = null;
      _currentValidation = null;
      notifyListeners();
      return;
    }

    _currentPricing = _formController!.calculatePrice();

    _formController!.validateAndSubmit();
    _currentValidation = ValidationResult(
      isValid: !_formController!.hasErrors,
      errors: _formController!.errors.values.toList(),
      messages: [],
    );

    notifyListeners();
  }

  /// Filtrar produtos por tipo
  List<Product> getProductsByType(String? productType) {
    if (productType == null || productType.isEmpty) {
      return _availableProducts;
    }
    return _availableProducts
        .where((product) => product.productType == productType)
        .toList();
  }

  /// Submeter orçamento
  Future<bool> submitBudget() async {
    if (!canSubmit) {
      _error = 'Formulário inválido - não é possível submeter';
      return false;
    }

    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('Orçamento submetido com sucesso!');
      debugPrint('Produto: ${_formController!.selectedProduct!.name}');
      debugPrint('Dados: ${_formController!.formData}');
      debugPrint(
          'Preço final: R\$ ${_currentPricing!.finalPrice.toStringAsFixed(2)}');

      return true;
    } catch (e) {
      _error = 'Erro ao submeter orçamento: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpar formulário
  void clearForm() {
    _formController?.clear();
    _formController = null;
    _currentPricing = null;
    _currentValidation = null;
    _error = null;
    notifyListeners();
  }

  /// Obter resumo do orçamento
  BudgetSummary? getBudgetSummary() {
    if (_formController?.selectedProduct == null || _currentPricing == null) {
      return null;
    }

    return BudgetSummary(
      product: _formController!.selectedProduct!,
      formData: _formController!.formData,
      pricing: _currentPricing!,
      isValid: canSubmit,
      errors: _formController!.errors.values.toList(),
    );
  }

  /// Definir estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _formController?.removeListener(_onFormChanged);
    _formController?.dispose();
    super.dispose();
  }
}

/// Resumo do orçamento
class BudgetSummary {
  final Product product;
  final Map<String, dynamic> formData;
  final PricingResult pricing;
  final bool isValid;
  final List<String> errors;
  final int? quantity;

  const BudgetSummary({
    required this.product,
    required this.formData,
    required this.pricing,
    required this.isValid,
    required this.errors,
    this.quantity,
  });

  /// Quantidade total
  int get quantityValue =>
      quantity ?? int.tryParse(formData['quantity']?.toString() ?? '1') ?? 1;

  /// Preço total (quantidade * preço unitário)
  double get totalPrice => pricing.finalPrice * quantityValue;

  /// Economia total
  double get totalSavings => pricing.savingsAmount * quantityValue;

  /// Percentual de desconto
  double get discountPercentage {
    if (pricing.basePrice <= 0) return 0;
    return (pricing.savingsAmount / pricing.basePrice) * 100;
  }
}
