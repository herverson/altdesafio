import '../../core/mixins/calculator_mixin.dart';
import '../../core/mixins/formatter_mixin.dart';
import '../../core/mixins/validator_mixin.dart';
import '../base/base_model.dart';
import '../fields/form_field_config.dart';

/// Classe abstrata base para produtos com polimorfismo e mixins
/// Melhorado baseado no altforce_dynamic_budgets
abstract class Product extends BaseModel
    with CalculatorMixin, FormatterMixin, ValidatorMixin {
  @override
  final String id;
  @override
  final String name;
  final String description;
  final double basePrice;
  final int quantity;
  final Map<String, dynamic> attributes;
  final bool isVipClient;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.quantity = 1,
    this.attributes = const {},
    this.isVipClient = false,
  });

  /// Configuração de campos específicos para cada tipo de produto
  List<FormFieldConfig> getFormFields();

  /// Validações específicas do produto
  List<String> validate(Map<String, dynamic> formData);

  /// Cálculo de preço base específico do produto
  double calculateBasePrice(Map<String, dynamic> formData);

  /// Tipo do produto para engine de regras
  String get productType;

  /// Preço total calculado
  double get totalPrice => calculateTotal(basePrice, quantity);

  /// Preço formatado
  String get formattedPrice => formatCurrency(totalPrice);

  /// Preço base formatado
  String get formattedBasePrice => formatCurrency(basePrice);

  /// Validar se produto é válido
  bool get isValid =>
      isValidString(id) &&
      isValidString(name) &&
      isPositive(basePrice) &&
      isPositive(quantity);

  /// Obter atributo tipado
  T? getAttribute<T>(String key) => attributes[key] as T?;

  /// Definir atributo
  void setAttribute<T>(String key, T value) {
    // Note: Isso cria uma nova instância, pois attributes é final
    // Em uma implementação real, você criaria um copyWith
  }

  /// Verificar se tem atributo
  bool hasAttribute(String key) => attributes.containsKey(key);

  /// Cópia com modificações
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    int? quantity,
    Map<String, dynamic>? attributes,
    bool? isVipClient,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'basePrice': basePrice,
        'quantity': quantity,
        'attributes': attributes,
        'productType': productType,
        'isVipClient': isVipClient,
        'totalPrice': totalPrice,
        'formattedPrice': formattedPrice,
        'isValid': isValid,
      };
}
