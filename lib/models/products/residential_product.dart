import 'product.dart';
import '../fields/form_field_config.dart';

/// Produto Residencial com campos específicos
class ResidentialProduct extends Product {
  ResidentialProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    super.attributes,
  });

  @override
  String get productType => 'residential';

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
        key: 'color',
        label: 'Cor',
        isRequired: true,
        order: 2,
        options: [
          SelectOption(value: 'white', label: 'Branco'),
          SelectOption(value: 'black', label: 'Preto'),
          SelectOption(value: 'silver', label: 'Prata'),
          SelectOption(value: 'gold', label: 'Dourado'),
        ],
      ),
      const SelectFieldConfig(
        key: 'warranty_years',
        label: 'Garantia',
        isRequired: true,
        order: 3,
        options: [
          SelectOption(value: '1', label: '1 ano'),
          SelectOption(value: '2', label: '2 anos'),
          SelectOption(value: '3', label: '3 anos'),
          SelectOption(value: '5', label: '5 anos'),
        ],
      ),
      const SelectFieldConfig(
        key: 'installation_type',
        label: 'Tipo de Instalação',
        isRequired: true,
        order: 4,
        options: [
          SelectOption(value: 'wall', label: 'Parede'),
          SelectOption(value: 'ceiling', label: 'Teto'),
          SelectOption(value: 'floor', label: 'Piso'),
          SelectOption(value: 'countertop', label: 'Bancada'),
        ],
      ),
      const SelectFieldConfig(
        key: 'energy_efficiency',
        label: 'Eficiência Energética',
        isRequired: true,
        order: 5,
        options: [
          SelectOption(value: 'A', label: 'A (Mais Eficiente)'),
          SelectOption(value: 'B', label: 'B'),
          SelectOption(value: 'C', label: 'C'),
          SelectOption(value: 'D', label: 'D'),
        ],
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

    // Validação específica: Instalação no teto com garantia > 3 anos
    final installation = formData['installation_type']?.toString() ?? '';
    final warranty =
        int.tryParse(formData['warranty_years']?.toString() ?? '1') ?? 1;

    if (installation == 'ceiling' && warranty > 3) {
      errors.add('Instalação no teto suporta garantia máxima de 3 anos');
    }

    // Validação de eficiência vs garantia
    final efficiency = formData['energy_efficiency']?.toString() ?? 'D';
    if (efficiency == 'D' && warranty > 2) {
      errors.add('Produtos com eficiência D têm garantia máxima de 2 anos');
    }

    return errors;
  }

  @override
  double calculateBasePrice(Map<String, dynamic> formData) {
    double price = basePrice;

    // Ajuste por cor
    final color = formData['color']?.toString() ?? 'white';
    switch (color) {
      case 'gold':
        price *= 1.3;
        break;
      case 'silver':
        price *= 1.15;
        break;
      case 'black':
        price *= 1.1;
        break;
    }

    // Ajuste por garantia
    final warranty =
        int.tryParse(formData['warranty_years']?.toString() ?? '1') ?? 1;
    price *= (1 + (warranty - 1) * 0.1); // 10% por ano adicional

    // Ajuste por eficiência energética
    final efficiency = formData['energy_efficiency']?.toString() ?? 'D';
    switch (efficiency) {
      case 'A':
        price *= 1.2;
        break;
      case 'B':
        price *= 1.1;
        break;
      case 'C':
        price *= 1.05;
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
    Map<String, dynamic>? attributes,
  }) {
    return ResidentialProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      attributes: attributes ?? this.attributes,
    );
  }
}
