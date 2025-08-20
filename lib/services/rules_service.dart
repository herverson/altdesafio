import '../models/rules/pricing_rule.dart';
import '../models/rules/validation_rule.dart';
import '../models/rules/visibility_rule.dart';
import 'rules_engine.dart';

/// Serviço para inicialização e gestão das regras de negócio
class RulesService {
  static final RulesService _instance = RulesService._internal();
  factory RulesService() => _instance;
  RulesService._internal();

  late final PricingEngine _pricingEngine;
  late final ValidationEngine _validationEngine;
  late final VisibilityEngine _visibilityEngine;

  PricingEngine get pricingEngine => _pricingEngine;
  ValidationEngine get validationEngine => _validationEngine;
  VisibilityEngine get visibilityEngine => _visibilityEngine;

  /// Inicializar todas as engines com regras padrão
  void initialize() {
    _pricingEngine = PricingEngine();
    _validationEngine = ValidationEngine();
    _visibilityEngine = VisibilityEngine();

    _initializePricingRules();
    _initializeValidationRules();
    _initializeVisibilityRules();
  }

  void _initializePricingRules() {
    // Regra de desconto por volume (≥50 unidades = 15%)
    _pricingEngine.addRule(VolumeDiscountRule(
      id: 'volume_discount_50',
      name: 'Desconto por Volume 50+',
      description: 'Desconto de 15% para pedidos com 50 ou mais unidades',
      priority: 100,
      minimumQuantity: 50,
      discountPercentage: 15.0,
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));

    // Regra de taxa de urgência (<7 dias = +20%)
    _pricingEngine.addRule(UrgencyFeeRule(
      id: 'urgency_fee_7',
      name: 'Taxa de Urgência 7 dias',
      description: 'Taxa de 20% para entregas em menos de 7 dias',
      priority: 90,
      maxDeliveryDays: 7,
      feePercentage: 20.0,
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));

    // Regra de desconto VIP
    _pricingEngine.addRule(VipDiscountRule(
      id: 'vip_discount',
      name: 'Desconto Cliente VIP',
      description: 'Desconto especial de 10% para clientes VIP',
      priority: 80,
      discountPercentage: 10.0,
      vipCustomers: ['customer_001', 'customer_vip_001'],
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));

    // Desconto adicional para grandes volumes
    _pricingEngine.addRule(VolumeDiscountRule(
      id: 'volume_discount_100',
      name: 'Desconto por Volume 100+',
      description:
          'Desconto adicional de 5% para pedidos com 100 ou mais unidades',
      priority: 95,
      minimumQuantity: 100,
      discountPercentage: 5.0,
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));
  }

  void _initializeValidationRules() {
    // Certificação obrigatória para produtos industriais com voltagem >220V
    _validationEngine.addRule(CertificationRequiredRule(
      id: 'certification_required_industrial',
      name: 'Certificação Obrigatória Industrial',
      description:
          'Produtos industriais com voltagem >220V exigem certificação',
      priority: 100,
      voltageThreshold: 220.0,
      applicableProductTypes: ['industrial'],
    ));

    // Quantidade mínima
    _validationEngine.addRule(MinimumQuantityRule(
      id: 'minimum_quantity',
      name: 'Quantidade Mínima',
      description: 'Quantidade mínima de 1 unidade',
      priority: 90,
      minimumQuantity: 1,
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));

    // Validação de prazo de entrega
    _validationEngine.addRule(DeliveryTimeValidationRule(
      id: 'delivery_time_validation',
      name: 'Validação Prazo de Entrega',
      description: 'Prazo de entrega deve estar entre 1 e 365 dias',
      priority: 85,
      minDeliveryDays: 1,
      maxDeliveryDays: 365,
      applicableProductTypes: ['industrial', 'residential', 'corporate'],
    ));
  }

  void _initializeVisibilityRules() {
    // Regra de certificação obrigatória baseada em voltagem
    _visibilityEngine.addRule(ConditionalVisibilityRule(
      id: 'certification_required_visibility',
      name: 'Certificação Obrigatória por Voltagem',
      description: 'Torna certificação obrigatória quando voltagem > 220V',
      priority: 100,
      triggerField: 'voltage',
      triggerValue: '>220',
      fieldVisibilityChanges: {},
      fieldRequiredChanges: {'certification': true},
      applicableProductTypes: ['industrial'],
    ));

    // Campos específicos por tipo de produto
    _visibilityEngine.addRule(ProductTypeVisibilityRule(
      id: 'product_type_fields',
      name: 'Campos por Tipo de Produto',
      description: 'Configura campos visíveis baseado no tipo de produto',
      priority: 90,
      productTypeFields: {
        'industrial': [
          'quantity',
          'voltage',
          'certification',
          'protection_grade',
          'power_consumption',
          'delivery_days',
        ],
        'residential': [
          'quantity',
          'color',
          'warranty_years',
          'installation_type',
          'energy_efficiency',
          'delivery_days',
        ],
        'corporate': [
          'quantity',
          'contract_type',
          'support_level',
          'sla_hours',
          'deployment_type',
          'compliance_level',
          'delivery_days',
        ],
      },
    ));

    // Regra condicional para suporte 24x7 em contratos Enterprise
    _visibilityEngine.addRule(ConditionalVisibilityRule(
      id: 'enterprise_support_required',
      name: 'Suporte 24x7 para Enterprise',
      description: 'Força suporte 24x7 para contratos Enterprise',
      priority: 95,
      triggerField: 'contract_type',
      triggerValue: 'enterprise',
      fieldVisibilityChanges: {},
      fieldRequiredChanges: {'support_level': true},
      applicableProductTypes: ['corporate'],
    ));
  }

  /// Adicionar regra customizada
  void addCustomPricingRule(PricingRule rule) {
    _pricingEngine.addRule(rule);
  }

  void addCustomValidationRule(ValidationRule rule) {
    _validationEngine.addRule(rule);
  }

  void addCustomVisibilityRule(VisibilityRule rule) {
    _visibilityEngine.addRule(rule);
  }

  /// Remover regras
  bool removePricingRule(String ruleId) {
    return _pricingEngine.removeRule(ruleId);
  }

  bool removeValidationRule(String ruleId) {
    return _validationEngine.removeRule(ruleId);
  }

  bool removeVisibilityRule(String ruleId) {
    return _visibilityEngine.removeRule(ruleId);
  }

  /// Listar regras ativas
  List<PricingRule> getActivePricingRules() {
    return _pricingEngine.getRulesByType('pricing');
  }

  List<ValidationRule> getActiveValidationRules() {
    return _validationEngine.getRulesByType('validation');
  }

  List<VisibilityRule> getActiveVisibilityRules() {
    return _visibilityEngine.getRulesByType('visibility');
  }
}
