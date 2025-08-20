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
    _initialize();
  }

  // Getters
  FormController<Product>? get formController => _formController;
  List<Product> get availableProducts => List.unmodifiable(_availableProducts);
  PricingResult? get currentPricing => _currentPricing;
  ValidationResult? get currentValidation => _currentValidation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canSubmit =>
      _formController?.isValid == true && _currentValidation?.isValid == true;

  /// Inicializar controller
  Future<void> _initialize() async {
    _setLoading(true);
    try {
      // Inicializar serviço de regras
      _rulesService.initialize();

      // Criar form controller
      _formController = FormController<Product>(
        pricingEngine: _rulesService.pricingEngine,
        validationEngine: _rulesService.validationEngine,
        visibilityEngine: _rulesService.visibilityEngine,
      );

      // Configurar listener para mudanças no formulário
      _formController!.addListener(_onFormChanged);

      // Carregar produtos disponíveis
      await _loadProducts();

      _error = null;
    } catch (e) {
      _error = 'Erro ao inicializar: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Carregar produtos do repositório
  Future<void> _loadProducts() async {
    try {
      _availableProducts = await _productRepository.findAll();
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao carregar produtos: $e');
    }
  }

  /// Selecionar produto (dispara recálculos)
  void selectProduct(Product product) {
    if (_formController == null) return;

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

    // Calcular preço com regras aplicadas
    _currentPricing = _formController!.calculatePrice();

    // Validar formulário
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
    if (!canSubmit) return false;

    _setLoading(true);
    try {
      // Simular processamento
      await Future.delayed(const Duration(seconds: 1));

      // Aqui seria feita a persistência do orçamento
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

  const BudgetSummary({
    required this.product,
    required this.formData,
    required this.pricing,
    required this.isValid,
    required this.errors,
  });

  /// Quantidade total
  int get quantity =>
      int.tryParse(formData['quantity']?.toString() ?? '1') ?? 1;

  /// Preço total (quantidade * preço unitário)
  double get totalPrice => pricing.finalPrice * quantity;

  /// Economia total
  double get totalSavings => pricing.savingsAmount * quantity;

  /// Percentual de desconto
  double get discountPercentage {
    if (pricing.basePrice <= 0) return 0;
    return (pricing.savingsAmount / pricing.basePrice) * 100;
  }
}
