import '../base/base_model.dart';

/// Contexto para execução de regras
class RuleContext {
  final Map<String, dynamic> formData;
  final Map<String, dynamic> calculatedData;
  final Map<String, dynamic> metadata;

  RuleContext({
    required this.formData,
    Map<String, dynamic>? calculatedData,
    Map<String, dynamic>? metadata,
  })  : calculatedData = calculatedData ?? {},
        metadata = metadata ?? {};

  RuleContext copyWith({
    Map<String, dynamic>? formData,
    Map<String, dynamic>? calculatedData,
    Map<String, dynamic>? metadata,
  }) {
    return RuleContext(
      formData: formData ?? Map.from(this.formData),
      calculatedData: calculatedData ?? Map.from(this.calculatedData),
      metadata: metadata ?? Map.from(this.metadata),
    );
  }
}

/// Resultado da execução de uma regra
class RuleResult {
  final bool success;
  final String? message;
  final Map<String, dynamic> changes;
  final List<String> errors;
  final bool shouldStopExecution;

  const RuleResult({
    required this.success,
    this.message,
    this.changes = const {},
    this.errors = const [],
    this.shouldStopExecution = false,
  });

  factory RuleResult.success({
    String? message,
    Map<String, dynamic> changes = const {},
  }) {
    return RuleResult(
      success: true,
      message: message,
      changes: changes,
    );
  }

  factory RuleResult.failure({
    required List<String> errors,
    bool shouldStopExecution = false,
  }) {
    return RuleResult(
      success: false,
      errors: errors,
      shouldStopExecution: shouldStopExecution,
    );
  }
}

/// Classe abstrata base para regras de negócio
abstract class BusinessRule extends BaseModel {
  final String id;
  final String name;
  final String description;
  final int priority;
  final bool isEnabled;
  final List<String> applicableProductTypes;
  final Map<String, dynamic> conditions;

  BusinessRule({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    this.isEnabled = true,
    this.applicableProductTypes = const [],
    this.conditions = const {},
  });

  /// Verifica se a regra é aplicável ao contexto
  bool isApplicable(RuleContext context);

  /// Executa a regra no contexto
  RuleResult execute(RuleContext context);

  /// Tipo da regra para classificação
  String get ruleType;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priority': priority,
        'isEnabled': isEnabled,
        'applicableProductTypes': applicableProductTypes,
        'conditions': conditions,
        'ruleType': ruleType,
      };
}
