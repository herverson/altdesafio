/// Pattern Result para tratamento robusto de erros
abstract class Result<T> {
  const Result();

  /// Criar resultado de sucesso
  factory Result.success(T data) = Success<T>;

  /// Criar resultado de erro
  factory Result.failure(String error, {String? code, dynamic details}) =
      Failure<T>;

  /// Verificar se é sucesso
  bool get isSuccess => this is Success<T>;

  /// Verificar se é erro
  bool get isFailure => this is Failure<T>;

  /// Obter dados (null se erro)
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Obter erro (null se sucesso)
  String? get error => isFailure ? (this as Failure<T>).error : null;

  /// Transformar resultado
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Result.success(transform((this as Success<T>).data));
      } catch (e) {
        return Result.failure('Error transforming result: $e');
      }
    }
    return Result.failure((this as Failure<T>).error);
  }

  /// Executar ação se sucesso
  Result<T> onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Executar ação se erro
  Result<T> onFailure(void Function(String error) action) {
    if (isFailure) {
      action((this as Failure<T>).error);
    }
    return this;
  }
}

/// Resultado de sucesso
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Resultado de erro
class Failure<T> extends Result<T> {
  final String error;
  final String? code;
  final dynamic details;

  const Failure(this.error, {this.code, this.details});

  @override
  String toString() => 'Failure($error${code != null ? ' [$code]' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          code == other.code;

  @override
  int get hashCode => Object.hash(error, code);
}
