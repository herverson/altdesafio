import 'product.dart';
import '../fields/form_field_config.dart';

/// Produto Industrial com campos específicos
class IndustrialProduct extends Product {
  IndustrialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    super.attributes,
  });

  @override
  String get productType => 'industrial';

  @override
  List<FormFieldConfig> getFormFields() {
    return [
      const NumberFieldConfig(
        key: 'quantity',
        label: 'Quantidade',
        isRequired: true,
        order: 1,
        min: 1,
        decimals: 0,
      ),
      const SelectFieldConfig(
        key: 'voltage',
        label: 'Voltagem',
        isRequired: true,
        order: 2,
        options: [
          SelectOption(value: '110', label: '110V'),
          SelectOption(value: '220', label: '220V'),
          SelectOption(value: '380', label: '380V'),
          SelectOption(value: '440', label: '440V'),
        ],
      ),
      const TextFieldConfig(
        key: 'certification',
        label: 'Certificação',
        isRequired: false, // Será dinâmica baseada em regras
        order: 3,
        placeholder: 'Ex: ISO 9001, INMETRO',
      ),
      const SelectFieldConfig(
        key: 'protection_grade',
        label: 'Grau de Proteção',
        isRequired: true,
        order: 4,
        options: [
          SelectOption(value: 'IP54', label: 'IP54'),
          SelectOption(value: 'IP65', label: 'IP65'),
          SelectOption(value: 'IP67', label: 'IP67'),
        ],
      ),
      const NumberFieldConfig(
        key: 'power_consumption',
        label: 'Consumo (kW)',
        isRequired: true,
        order: 5,
        min: 0.1,
        decimals: 2,
      ),
      const NumberFieldConfig(
        key: 'delivery_days',
        label: 'Prazo de Entrega (dias)',
        isRequired: true,
        order: 6,
        min: 1,
        decimals: 0,
      ),
    ];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    final errors = <String>[];

    // Validação específica: Voltagem > 220V exige certificação
    final voltage =
        double.tryParse(formData['voltage']?.toString() ?? '0') ?? 0;
    final certification = formData['certification']?.toString() ?? '';

    if (voltage > 220 && certification.trim().isEmpty) {
      errors.add(
          'Produtos industriais com voltagem superior a 220V exigem certificação');
    }

    // Validação de consumo vs voltagem
    final power =
        double.tryParse(formData['power_consumption']?.toString() ?? '0') ?? 0;
    if (voltage <= 220 && power > 10) {
      errors.add('Consumo muito alto para voltagem de ${voltage}V');
    }

    return errors;
  }

  @override
  double calculateBasePrice(Map<String, dynamic> formData) {
    double price = basePrice;

    // Ajuste por voltagem
    final voltage =
        double.tryParse(formData['voltage']?.toString() ?? '220') ?? 220;
    if (voltage > 220) {
      price *= 1.2; // 20% adicional para alta voltagem
    }

    // Ajuste por grau de proteção
    final protection = formData['protection_grade']?.toString() ?? 'IP54';
    switch (protection) {
      case 'IP65':
        price *= 1.1;
        break;
      case 'IP67':
        price *= 1.25;
        break;
    }

    return price;
  }

  @override
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    int? quantity,
    Map<String, dynamic>? attributes,
    bool? isVipClient,
  }) {
    return IndustrialProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      attributes: attributes ?? this.attributes,
    );
  }
}
