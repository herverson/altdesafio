import 'package:flutter/foundation.dart';
import '../models/products/product.dart';
import '../models/fields/form_field_config.dart';
import '../models/rules/business_rule.dart';
import '../services/rules_engine.dart';

/// Controller genérico para formulários dinâmicos
class FormController<T extends Product> extends ChangeNotifier {
  T? _selectedProduct;
  final Map<String, dynamic> _formData = {};
  final Map<String, String> _errors = {};
  List<FormFieldConfig> _fields = [];

  final PricingEngine _pricingEngine;
  final ValidationEngine _validationEngine;
  final VisibilityEngine _visibilityEngine;

  FormController({
    required PricingEngine pricingEngine,
    required ValidationEngine validationEngine,
    required VisibilityEngine visibilityEngine,
  })  : _pricingEngine = pricingEngine,
        _validationEngine = validationEngine,
        _visibilityEngine = visibilityEngine;

  // Getters
  T? get selectedProduct => _selectedProduct;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);
  Map<String, String> get errors => Map.unmodifiable(_errors);
  List<FormFieldConfig> get fields => List.unmodifiable(_fields);
  bool get hasErrors => _errors.isNotEmpty;
  bool get isValid => !hasErrors && _selectedProduct != null;

  /// Selecionar produto e reconfigurar formulário
  void selectProduct(T product) {
    if (_selectedProduct?.id == product.id) return;

    _selectedProduct = product;
    _clearFormData();
    _rebuildForm();
    notifyListeners();
  }

  /// Atualizar valor de campo
  void updateField(String key, dynamic value) {
    if (_formData[key] == value) return;

    _formData[key] = value;
    _errors.remove(key); // Limpar erro do campo

    // Recalcular formulário com novas regras
    _rebuildForm();
    _validateForm();
    notifyListeners();
  }

  /// Limpar dados do formulário
  void _clearFormData() {
    _formData.clear();
    _errors.clear();
  }

  /// Reconstruir formulário com base no produto e regras
  void _rebuildForm() {
    if (_selectedProduct == null) {
      _fields = [];
      return;
    }

    // Obter campos base do produto
    final baseFields = _selectedProduct!.getFormFields();

    // Criar contexto para regras
    final context = RuleContext(
      formData: Map.from(_formData),
      metadata: {
        'productType': _selectedProduct!.productType,
        'productId': _selectedProduct!.id,
      },
    );

    // Aplicar regras de visibilidade
    _fields = _visibilityEngine.applyVisibilityRules(baseFields, context);

    // Ordenar campos por ordem
    _fields.sort((a, b) => a.order.compareTo(b.order));
  }

  /// Validar formulário completo
  void _validateForm() {
    _errors.clear();

    if (_selectedProduct == null) return;

    // Validações dos campos
    for (final field in _fields) {
      if (!field.isVisible) continue;

      final value = _formData[field.key];
      final error = field.validate(value);
      if (error != null) {
        _errors[field.key] = error;
      }
    }

    // Validações do produto
    final productErrors = _selectedProduct!.validate(_formData);
    for (int i = 0; i < productErrors.length; i++) {
      _errors['product_$i'] = productErrors[i];
    }

    // Validações das regras de negócio
    final context = RuleContext(
      formData: Map.from(_formData),
      metadata: {
        'productType': _selectedProduct!.productType,
        'productId': _selectedProduct!.id,
      },
    );

    final validationResult = _validationEngine.validateAll(context);
    for (int i = 0; i < validationResult.errors.length; i++) {
      _errors['rule_$i'] = validationResult.errors[i];
    }
  }

  /// Calcular preço com regras aplicadas
  PricingResult calculatePrice() {
    if (_selectedProduct == null) {
      return const PricingResult(
        basePrice: 0,
        finalPrice: 0,
        adjustments: [],
        errors: ['Nenhum produto selecionado'],
        messages: [],
      );
    }

    final basePrice = _selectedProduct!.calculateBasePrice(_formData);
    final context = RuleContext(
      formData: Map.from(_formData),
      metadata: {
        'productType': _selectedProduct!.productType,
        'productId': _selectedProduct!.id,
        'customerId': 'customer_001', // Simulação de cliente VIP
      },
    );

    return _pricingEngine.calculateFinalPrice(basePrice, context);
  }

  /// Validar formulário e retornar resultado
  bool validateAndSubmit() {
    _validateForm();
    return isValid;
  }

  /// Limpar formulário
  void clear() {
    _selectedProduct = null;
    _clearFormData();
    _fields = [];
    notifyListeners();
  }

  /// Obter valor formatado de um campo
  String getFormattedValue(String key) {
    final value = _formData[key];
    if (value == null) return '';

    final field = _fields.firstWhere(
      (f) => f.key == key,
      orElse: () => const TextFieldConfig(
        key: '',
        label: '',
        isRequired: false,
        order: 0,
      ),
    );

    if (field is NumberFieldConfig) {
      final numValue = double.tryParse(value.toString());
      if (numValue != null) {
        return numValue.toStringAsFixed(field.decimals ?? 2);
      }
    }

    return value.toString();
  }

  /// Verificar se campo é obrigatório
  bool isFieldRequired(String key) {
    return _fields
        .where((f) => f.key == key && f.isVisible)
        .any((f) => f.isRequired);
  }

  /// Verificar se campo é visível
  bool isFieldVisible(String key) {
    return _fields.any((f) => f.key == key && f.isVisible);
  }
}
