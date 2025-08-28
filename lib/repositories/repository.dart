import '../core/result/result.dart';
import '../models/base/base_model.dart';

/// Interface genérica para repositórios com type safety e Result pattern
abstract class IRepository<T extends BaseModel> {
  /// Buscar todos os itens
  Future<Result<List<T>>> findAll();

  /// Buscar por ID
  Future<Result<T?>> findById(String id);

  /// Buscar com filtros
  Future<Result<List<T>>> findWhere(bool Function(T item) predicate);

  /// Salvar item
  Future<Result<T>> save(T item);

  /// Salvar múltiplos itens
  Future<Result<List<T>>> saveAll(List<T> items);

  /// Deletar por ID
  Future<Result<bool>> deleteById(String id);

  /// Deletar item
  Future<Result<bool>> delete(T item);

  /// Contar itens
  Future<Result<int>> count();

  /// Verificar se existe
  Future<Result<bool>> exists(String id);

  /// Limpar repositório
  Future<Result<void>> clear();

  /// Buscar com paginação
  Future<Result<PaginatedResult<T>>> findPaginated({
    int page = 1,
    int pageSize = 10,
    bool Function(T item)? predicate,
  });

  /// Buscar primeiro item que atende condição
  Future<Result<T?>> findFirst(bool Function(T item) predicate);

  /// Buscar último item que atende condição
  Future<Result<T?>> findLast(bool Function(T item) predicate);

  /// Atualizar item existente
  Future<Result<T>> update(String id, T item);

  /// Verificar se repositório está vazio
  Future<Result<bool>> isEmpty();
}

/// Resultado paginado
class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

/// Implementação genérica em memória com type safety e Result pattern
class MemoryRepository<T extends BaseModel> implements IRepository<T> {
  final Map<String, T> _storage = {};

  @override
  Future<Result<List<T>>> findAll() async {
    try {
      return Result.success(_storage.values.toList());
    } catch (e) {
      return Result.failure('Erro ao buscar todos os itens: $e');
    }
  }

  @override
  Future<Result<T?>> findById(String id) async {
    try {
      if (id.isEmpty) {
        return Result.failure('ID não pode ser vazio');
      }
      return Result.success(_storage[id]);
    } catch (e) {
      return Result.failure('Erro ao buscar item por ID: $e');
    }
  }

  @override
  Future<Result<List<T>>> findWhere(bool Function(T item) predicate) async {
    try {
      final items = _storage.values.where(predicate).toList();
      return Result.success(items);
    } catch (e) {
      return Result.failure('Erro ao buscar itens com filtro: $e');
    }
  }

  @override
  Future<Result<T>> save(T item) async {
    try {
      if (item.id.isEmpty) {
        return Result.failure('ID do item não pode ser vazio');
      }
      _storage[item.id] = item;
      return Result.success(item);
    } catch (e) {
      return Result.failure('Erro ao salvar item: $e');
    }
  }

  @override
  Future<Result<List<T>>> saveAll(List<T> items) async {
    try {
      final invalidItems = items.where((item) => item.id.isEmpty).toList();
      if (invalidItems.isNotEmpty) {
        return Result.failure('${invalidItems.length} itens têm ID vazio');
      }

      for (final item in items) {
        _storage[item.id] = item;
      }
      return Result.success(items);
    } catch (e) {
      return Result.failure('Erro ao salvar múltiplos itens: $e');
    }
  }

  @override
  Future<Result<bool>> deleteById(String id) async {
    try {
      if (id.isEmpty) {
        return Result.failure('ID não pode ser vazio');
      }
      final removed = _storage.remove(id) != null;
      return Result.success(removed);
    } catch (e) {
      return Result.failure('Erro ao deletar item por ID: $e');
    }
  }

  @override
  Future<Result<bool>> delete(T item) async {
    return deleteById(item.id);
  }

  @override
  Future<Result<int>> count() async {
    try {
      return Result.success(_storage.length);
    } catch (e) {
      return Result.failure('Erro ao contar itens: $e');
    }
  }

  @override
  Future<Result<bool>> exists(String id) async {
    try {
      if (id.isEmpty) {
        return Result.failure('ID não pode ser vazio');
      }
      return Result.success(_storage.containsKey(id));
    } catch (e) {
      return Result.failure('Erro ao verificar existência do item: $e');
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      _storage.clear();
      return Result.success(null);
    } catch (e) {
      return Result.failure('Erro ao limpar repositório: $e');
    }
  }

  @override
  Future<Result<PaginatedResult<T>>> findPaginated({
    int page = 1,
    int pageSize = 10,
    bool Function(T item)? predicate,
  }) async {
    try {
      if (page < 1) {
        return Result.failure('Página deve ser maior que 0');
      }
      if (pageSize < 1) {
        return Result.failure('Tamanho da página deve ser maior que 0');
      }

      final allItems = predicate != null
          ? _storage.values.where(predicate).toList()
          : _storage.values.toList();

      final totalItems = allItems.length;
      final totalPages = (totalItems / pageSize).ceil();
      final startIndex = (page - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalItems);

      final items = startIndex < totalItems
          ? allItems.sublist(startIndex, endIndex)
          : <T>[];

      final result = PaginatedResult<T>(
        items: items,
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalItems,
        totalPages: totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure('Erro na busca paginada: $e');
    }
  }

  @override
  Future<Result<T?>> findFirst(bool Function(T item) predicate) async {
    try {
      final items = _storage.values.where(predicate);
      return Result.success(items.isNotEmpty ? items.first : null);
    } catch (e) {
      return Result.failure('Erro ao buscar primeiro item: $e');
    }
  }

  @override
  Future<Result<T?>> findLast(bool Function(T item) predicate) async {
    try {
      final items = _storage.values.where(predicate);
      return Result.success(items.isNotEmpty ? items.last : null);
    } catch (e) {
      return Result.failure('Erro ao buscar último item: $e');
    }
  }

  @override
  Future<Result<T>> update(String id, T item) async {
    try {
      if (id.isEmpty) {
        return Result.failure('ID não pode ser vazio');
      }
      if (!_storage.containsKey(id)) {
        return Result.failure('Item com ID $id não encontrado');
      }
      if (item.id != id) {
        return Result.failure('ID do item não corresponde ao ID fornecido');
      }

      _storage[id] = item;
      return Result.success(item);
    } catch (e) {
      return Result.failure('Erro ao atualizar item: $e');
    }
  }

  @override
  Future<Result<bool>> isEmpty() async {
    try {
      return Result.success(_storage.isEmpty);
    } catch (e) {
      return Result.failure('Erro ao verificar se repositório está vazio: $e');
    }
  }
}
