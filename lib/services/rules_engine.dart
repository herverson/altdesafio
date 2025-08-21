import '../models/rules/business_rule.dart';
import '../models/rules/pricing_rule.dart';
import '../models/rules/validation_rule.dart';
import '../models/rules/visibility_rule.dart';
import '../models/fields/form_field_config.dart';

/// Engine de regras genérica com processamento polimórfico
class RulesEngine<T extends BusinessRule> {
  final List<T> _rules = [];

  /// Número de regras na engine
  int get ruleCount => _rules.length;

  /// Adicionar regra
  void addRule(T rule) {
    _rules.add(rule);
    _sortRulesByPriority();
  }

  /// Adicionar múltiplas regras
  void addRules(List<T> rules) {
    _rules.addAll(rules);
    _sortRulesByPriority();
  }

  /// Remover regra
  bool removeRule(String ruleId) {
    final initialLength = _rules.length;
    _rules.removeWhere((rule) => rule.id == ruleId);
    return _rules.length < initialLength;
  }

  /// Limpar todas as regras
  void clear() {
    _rules.clear();
  }

  /// Obter regras por tipo
  List<T> getRulesByType(String ruleType) {
    return _rules.where((rule) => rule.ruleType == ruleType).toList();
  }

  /// Ordenar regras por prioridade (maior prioridade primeiro)
  void _sortRulesByPriority() {
    _rules.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Executar todas as regras aplicáveis
  EngineExecutionResult execute(RuleContext context) {
    final results = <String, RuleResult>{};
    final errors = <String>[];
    final messages = <String>[];
    final allChanges = <String, dynamic>{};

    for (final rule in _rules) {
      if (!rule.isApplicable(context)) continue;

      try {
        final result = rule.execute(context);
        results[rule.id] = result;

        if (result.success) {
          if (result.message != null) {
            messages.add(result.message!);
          }
          allChanges.addAll(result.changes);

          // Atualizar contexto com mudanças
          context.calculatedData.addAll(result.changes);
        } else {
          errors.addAll(result.errors);
          if (result.shouldStopExecution) break;
        }
      } catch (e) {
        errors.add('Erro ao executar regra ${rule.name}: $e');
      }
    }

    return EngineExecutionResult(
      success: errors.isEmpty,
      results: results,
      errors: errors,
      messages: messages,
      changes: allChanges,
      context: context,
    );
  }
}

/// Resultado da execução da engine
class EngineExecutionResult {
  final bool success;
  final Map<String, RuleResult> results;
  final List<String> errors;
  final List<String> messages;
  final Map<String, dynamic> changes;
  final RuleContext context;

  const EngineExecutionResult({
    required this.success,
    required this.results,
    required this.errors,
    required this.messages,
    required this.changes,
    required this.context,
  });
}

/// Engine especializada para regras de preço
class PricingEngine extends RulesEngine<PricingRule> {
  /// Calcular preço final aplicando todas as regras
  PricingResult calculateFinalPrice(
    double basePrice,
    RuleContext context,
  ) {
    // Adicionar preço base ao contexto
    context.calculatedData['basePrice'] = basePrice;

    final result = execute(context);

    double finalPrice = basePrice;
    final adjustments = <PriceAdjustment>[];

    // Processar ajustes de preço
    for (final entry in result.results.entries) {
      final ruleResult = entry.value;
      if (ruleResult.success) {
        final volumeDiscount =
            ruleResult.changes['volumeDiscountAmount'] as double?;
        final urgencyFee = ruleResult.changes['urgencyFeeAmount'] as double?;
        final vipDiscount = ruleResult.changes['vipDiscountAmount'] as double?;

        if (volumeDiscount != null) {
          finalPrice += volumeDiscount;
          adjustments.add(PriceAdjustment(
            type: 'Volume Discount',
            amount: volumeDiscount,
            percentage:
                ruleResult.changes['volumeDiscountPercentage'] as double?,
          ));
        }

        if (urgencyFee != null) {
          finalPrice += urgencyFee;
          adjustments.add(PriceAdjustment(
            type: 'Urgency Fee',
            amount: urgencyFee,
            percentage: ruleResult.changes['urgencyFeePercentage'] as double?,
          ));
        }

        if (vipDiscount != null) {
          finalPrice += vipDiscount;
          adjustments.add(PriceAdjustment(
            type: 'VIP Discount',
            amount: vipDiscount,
            percentage: ruleResult.changes['vipDiscountPercentage'] as double?,
          ));
        }
      }
    }

    return PricingResult(
      basePrice: basePrice,
      finalPrice: finalPrice,
      adjustments: adjustments,
      errors: result.errors,
      messages: result.messages,
    );
  }
}

/// Engine especializada para regras de validação
class ValidationEngine extends RulesEngine<ValidationRule> {
  /// Validar todos os campos
  ValidationResult validateAll(RuleContext context) {
    final result = execute(context);
    return ValidationResult(
      isValid: result.success,
      errors: result.errors,
      messages: result.messages,
    );
  }
}

/// Engine especializada para regras de visibilidade
class VisibilityEngine extends RulesEngine<VisibilityRule> {
  /// Aplicar regras de visibilidade aos campos
  List<FormFieldConfig> applyVisibilityRules(
    List<FormFieldConfig> fields,
    RuleContext context,
  ) {
    final modifiedFields = <String, FormFieldConfig>{};

    for (final rule in _rules) {
      if (rule.isApplicable(context)) {
        final changes = rule.applyVisibilityChanges(fields, context);
        modifiedFields.addAll(changes);
      }
    }

    // Aplicar modificações ou retornar campos originais
    return fields.map((field) {
      return modifiedFields[field.key] ?? field;
    }).toList();
  }
}

/// Resultado de precificação
class PricingResult {
  final double basePrice;
  final double finalPrice;
  final List<PriceAdjustment> adjustments;
  final List<String> errors;
  final List<String> messages;

  const PricingResult({
    required this.basePrice,
    required this.finalPrice,
    required this.adjustments,
    required this.errors,
    required this.messages,
  });

  double get totalAdjustment => finalPrice - basePrice;

  double get savingsAmount {
    final savings = adjustments
        .where((adj) => adj.amount < 0)
        .fold(0.0, (sum, adj) => sum + adj.amount.abs());
    return savings;
  }
}

/// Ajuste individual de preço
class PriceAdjustment {
  final String type;
  final double amount;
  final double? percentage;

  const PriceAdjustment({
    required this.type,
    required this.amount,
    this.percentage,
  });

  bool get isDiscount => amount < 0;
  bool get isFee => amount > 0;
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> messages;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.messages,
  });
}
