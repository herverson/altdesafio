import '../models/base/base_model.dart';

/// Interface genérica para repositórios com type safety
abstract class IRepository<T extends BaseModel> {
  /// Buscar todos os itens
  Future<List<T>> findAll();

  /// Buscar por ID
  Future<T?> findById(String id);

  /// Buscar com filtros
  Future<List<T>> findWhere(bool Function(T item) predicate);

  /// Salvar item
  Future<T> save(T item);

  /// Salvar múltiplos itens
  Future<List<T>> saveAll(List<T> items);

  /// Deletar por ID
  Future<bool> deleteById(String id);

  /// Deletar item
  Future<bool> delete(T item);

  /// Contar itens
  Future<int> count();

  /// Verificar se existe
  Future<bool> exists(String id);

  /// Limpar repositório
  Future<void> clear();
}

/// Implementação genérica em memória com type safety
class MemoryRepository<T extends BaseModel> implements IRepository<T> {
  final Map<String, T> _storage = {};

  @override
  Future<List<T>> findAll() async {
    return _storage.values.toList();
  }

  @override
  Future<T?> findById(String id) async {
    return _storage[id];
  }

  @override
  Future<List<T>> findWhere(bool Function(T item) predicate) async {
    return _storage.values.where(predicate).toList();
  }

  @override
  Future<T> save(T item) async {
    _storage[item.id] = item;
    return item;
  }

  @override
  Future<List<T>> saveAll(List<T> items) async {
    for (final item in items) {
      _storage[item.id] = item;
    }
    return items;
  }

  @override
  Future<bool> deleteById(String id) async {
    return _storage.remove(id) != null;
  }

  @override
  Future<bool> delete(T item) async {
    return deleteById(item.id);
  }

  @override
  Future<int> count() async {
    return _storage.length;
  }

  @override
  Future<bool> exists(String id) async {
    return _storage.containsKey(id);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}
