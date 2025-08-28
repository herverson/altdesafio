/// Mixin para formatação de dados
mixin FormatterMixin {
  /// Formatar valor monetário em Real
  String formatCurrency(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  /// Formatar porcentagem
  String formatPercentage(double value) => '${value.toStringAsFixed(1)}%';

  /// Formatar número com separador de milhares
  String formatNumber(num value) {
    final parts = value.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted =
        integerPart.replaceAllMapped(regex, (Match m) => '${m[1]}.');

    return formatted + decimalPart;
  }

  /// Formatar telefone brasileiro
  String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Formatar CPF
  String formatCPF(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    }
    return cpf;
  }

  /// Formatar CNPJ
  String formatCNPJ(String cnpj) {
    final cleaned = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 14) {
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
    }
    return cnpj;
  }

  /// Formatar CEP
  String formatCEP(String cep) {
    final cleaned = cep.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    }
    return cep;
  }

  /// Capitalizar primeira letra de cada palavra
  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Truncar texto com reticências
  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formatar duração em horas e minutos
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Formatar data brasileira
  String formatDateBR(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formatar data e hora brasileira
  String formatDateTimeBR(DateTime dateTime) {
    return '${formatDateBR(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
