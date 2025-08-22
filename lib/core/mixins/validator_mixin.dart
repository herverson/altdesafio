/// Mixin para validações comuns
/// Baseado no altforce_dynamic_budgets com melhorias
mixin ValidatorMixin {
  /// Verificar se valor é positivo
  bool isPositive(num value) => value > 0;

  /// Verificar se string não está vazia
  bool isNonEmpty(String value) => value.trim().isNotEmpty;

  /// Verificar se string é válida (não nula e não vazia)
  bool isValidString(String? value) => value != null && isNonEmpty(value);

  /// Verificar se precisa de certificação (regra de negócio)
  bool needsCertification(int voltage, String? certification) {
    return voltage > 220 &&
        (certification == null || !isNonEmpty(certification));
  }

  /// Validar email
  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validar CPF
  bool isValidCPF(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cleaned)) return false;

    // Validar primeiro dígito
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleaned[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;
    if (firstDigit != int.parse(cleaned[9])) return false;

    // Validar segundo dígito
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleaned[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    return secondDigit == int.parse(cleaned[10]);
  }

  /// Validar CNPJ
  bool isValidCNPJ(String cnpj) {
    final cleaned = cnpj.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 14) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cleaned)) return false;

    // Validar primeiro dígito
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cleaned[i]) * weights1[i];
    }
    int firstDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);
    if (firstDigit != int.parse(cleaned[12])) return false;

    // Validar segundo dígito
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cleaned[i]) * weights2[i];
    }
    int secondDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);

    return secondDigit == int.parse(cleaned[13]);
  }

  /// Validar telefone brasileiro
  bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 10 || cleaned.length == 11;
  }

  /// Validar CEP brasileiro
  bool isValidCEP(String cep) {
    final cleaned = cep.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length == 8;
  }

  /// Validar senha forte
  bool isStrongPassword(String password) {
    if (password.length < 8) return false;

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialCharacters =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUppercase && hasLowercase && hasNumbers && hasSpecialCharacters;
  }

  /// Validar idade mínima
  bool isMinimumAge(DateTime birthDate, int minimumAge) {
    final today = DateTime.now();
    final age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      return age - 1 >= minimumAge;
    }

    return age >= minimumAge;
  }

  /// Validar range numérico
  bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// Validar comprimento mínimo de string
  bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Validar comprimento máximo de string
  bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  /// Validar se string contém apenas números
  bool isNumeric(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  /// Validar se string contém apenas letras
  bool isAlphabetic(String value) {
    return RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value);
  }

  /// Validar se string é alfanumérica
  bool isAlphanumeric(String value) {
    return RegExp(r'^[a-zA-Z0-9À-ÿ\s]+$').hasMatch(value);
  }
}
