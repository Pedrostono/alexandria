// lib/utils/validators.dart

/// Classe com utilitários reutilizáveis de validação de formulários
class Validators {
  /// Valida campo obrigatório
  static String? required(String? value, [String message = 'Campo obrigatório.']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Valida comprimento mínimo de texto
  static String? minLength(String? value, int minLen, [String? message]) {
    final req = required(value);
    if (req != null) return req;
    if (value!.trim().length < minLen) {
      return message ?? 'Deve conter no mínimo $minLen caracteres.';
    }
    return null;
  }

  /// Valida formato de e-mail
  static String? email(String? value) {
    final req = required(value, 'Informe o e-mail.');
    if (req != null) return req;
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  /// Valida senha de pelo menos 6 caracteres
  static String? password(String? value) {
    final req = required(value, 'Informe a senha.');
    if (req != null) return req;
    if (value!.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  /// Valida confirmação de senha
  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'Confirme a senha.');
    if (req != null) return req;
    if (value != password) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Valida inteiros estritamente positivos (> 0)
  static String? positiveInt(String? value, [String message = 'Informe um número válido maior que 0.']) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório.';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return message;
    }
    return null;
  }

  /// Valida página atual (0 até totalPages)
  static String? currentPage(String? value, int totalPages) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório.';
    }
    final current = int.tryParse(value.trim());
    if (current == null || current < 0) {
      return 'Página inválida.';
    }
    if (current > totalPages) {
      return 'A página atual não pode ultrapassar o total ($totalPages).';
    }
    return null;
  }

  /// Valida nota de avaliação (1 a 5 estrelas)
  static String? rating(int? value) {
    if (value == null || value < 1 || value > 5) {
      return 'Selecione uma avaliação de 1 a 5 estrelas.';
    }
    return null;
  }
}
