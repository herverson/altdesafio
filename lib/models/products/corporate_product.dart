import 'product.dart';
import '../fields/form_field_config.dart';

/// Produto Corporativo com campos específicos
class CorporateProduct extends Product {
  CorporateProduct({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    super.attributes,
  });

  @override
  String get productType => 'corporate';

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
        key: 'contract_type',
        label: 'Tipo de contrato',
        isRequired: true,
        order: 2,
        options: [
          SelectOption(value: 'standard', label: 'Padrão'),
          SelectOption(value: 'premium', label: 'Premium'),
          SelectOption(value: 'enterprise', label: 'Enterprise'),
        ],
      ),
      const SelectFieldConfig(
        key: 'support_level',
        label: 'Nível de suporte',
        isRequired: true,
        order: 3,
        options: [
          SelectOption(value: 'basic', label: 'Básico (8h/dia)'),
          SelectOption(value: 'extended', label: 'Estendido (12h/dia)'),
          SelectOption(value: '24x7', label: '24x7'),
        ],
      ),
      const NumberFieldConfig(
        key: 'sla_hours',
        label: 'SLA (horas)',
        isRequired: true,
        order: 4,
        min: 1,
        max: 72,
        decimals: 0,
      ),
      const SelectFieldConfig(
        key: 'deployment_type',
        label: 'Tipo de implantação',
        isRequired: true,
        order: 5,
        options: [
          SelectOption(value: 'cloud', label: 'Cloud'),
          SelectOption(value: 'on_premise', label: 'On-Premise'),
          SelectOption(value: 'hybrid', label: 'Híbrido'),
        ],
      ),
      const SelectFieldConfig(
        key: 'compliance_level',
        label: 'Nível de compliance',
        isRequired: true,
        order: 6,
        options: [
          SelectOption(value: 'basic', label: 'Básico'),
          SelectOption(value: 'gdpr', label: 'GDPR'),
          SelectOption(value: 'sox', label: 'SOX'),
          SelectOption(value: 'hipaa', label: 'HIPAA'),
        ],
      ),
      const NumberFieldConfig(
        key: 'delivery_days',
        label: 'Prazo de entrega (dias)',
        isRequired: true,
        order: 7,
        min: 1,
        decimals: 0,
      ),
    ];
  }

  @override
  List<String> validate(Map<String, dynamic> formData) {
    final errors = <String>[];

    // Validação específica: Enterprise requer suporte 24x7
    final contractType = formData['contract_type']?.toString() ?? '';
    final supportLevel = formData['support_level']?.toString() ?? '';

    if (contractType == 'enterprise' && supportLevel != '24x7') {
      errors.add('Contratos enterprise exigem suporte 24x7');
    }

    // Validação SLA vs Support Level
    final slaHours =
        int.tryParse(formData['sla_hours']?.toString() ?? '24') ?? 24;
    if (supportLevel == 'basic' && slaHours < 8) {
      errors.add('Suporte básico não suporta SLA menor que 8 horas');
    }

    // Validação compliance vs deployment
    final compliance = formData['compliance_level']?.toString() ?? '';
    final deployment = formData['deployment_type']?.toString() ?? '';

    if ((compliance == 'sox' || compliance == 'hipaa') &&
        deployment == 'cloud') {
      errors
          .add('Compliance SOX/HIPAA requer implantação On-Premise ou Híbrida');
    }

    return errors;
  }

  @override
  double calculateBasePrice(Map<String, dynamic> formData) {
    double price = basePrice;

    // Ajuste por tipo de contrato
    final contractType = formData['contract_type']?.toString() ?? 'standard';
    switch (contractType) {
      case 'premium':
        price *= 1.5;
        break;
      case 'enterprise':
        price *= 2.5;
        break;
    }

    // Ajuste por nível de suporte
    final supportLevel = formData['support_level']?.toString() ?? 'basic';
    switch (supportLevel) {
      case 'extended':
        price *= 1.3;
        break;
      case '24x7':
        price *= 1.8;
        break;
    }

    // Ajuste por SLA
    final slaHours =
        int.tryParse(formData['sla_hours']?.toString() ?? '24') ?? 24;
    if (slaHours <= 4) {
      price *= 2.0;
    } else if (slaHours <= 8) {
      price *= 1.5;
    }

    // Ajuste por compliance
    final compliance = formData['compliance_level']?.toString() ?? 'basic';
    switch (compliance) {
      case 'gdpr':
        price *= 1.2;
        break;
      case 'sox':
        price *= 1.4;
        break;
      case 'hipaa':
        price *= 1.6;
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
    return CorporateProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      attributes: attributes ?? this.attributes,
    );
  }
}
