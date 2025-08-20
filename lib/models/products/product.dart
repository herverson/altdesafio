import '../base/base_model.dart';
import '../fields/form_field_config.dart';

/// Classe abstrata base para produtos com polimorfismo
abstract class Product extends BaseModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final Map<String, dynamic> attributes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.attributes = const {},
  });

  /// Configuração de campos específicos para cada tipo de produto
  List<FormFieldConfig> getFormFields();

  /// Validações específicas do produto
  List<String> validate(Map<String, dynamic> formData);

  /// Cálculo de preço base específico do produto
  double calculateBasePrice(Map<String, dynamic> formData);

  /// Tipo do produto para engine de regras
  String get productType;

  /// Cópia com modificações
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    Map<String, dynamic>? attributes,
  });

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'basePrice': basePrice,
        'attributes': attributes,
        'productType': productType,
      };
}
