/// Mixin para cálculos matemáticos comuns
/// Baseado no altforce_dynamic_budgets
mixin CalculatorMixin {
  /// Calcular porcentagem de um valor base
  double percentOf(double base, double percent) => base * (percent / 100);

  /// Aplicar desconto percentual
  double applyDiscount(double base, double percent) =>
      base - percentOf(base, percent);

  /// Aplicar taxa percentual
  double applySurcharge(double base, double percent) =>
      base + percentOf(base, percent);

  /// Calcular preço com quantidade
  double calculateTotal(double unitPrice, int quantity) => unitPrice * quantity;

  /// Calcular preço unitário a partir do total
  double calculateUnitPrice(double total, int quantity) {
    if (quantity <= 0) throw ArgumentError('Quantity must be greater than 0');
    return total / quantity;
  }

  /// Arredondar para 2 casas decimais
  double roundToTwoDecimals(double value) =>
      double.parse(value.toStringAsFixed(2));

  /// Verificar se valor é positivo
  bool isPositive(num value) => value > 0;

  /// Verificar se valor é zero
  bool isZero(num value) => value == 0;

  /// Calcular diferença percentual entre dois valores
  double percentageDifference(double original, double current) {
    if (original == 0) return 0;
    return ((current - original) / original) * 100;
  }

  /// Calcular média de uma lista de valores
  double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calcular maior valor de uma lista
  double findMaxValue(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Calcular menor valor de uma lista
  double findMinValue(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }
}
