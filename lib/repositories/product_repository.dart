import '../models/products/product.dart';
import '../models/products/industrial_product.dart';
import '../models/products/residential_product.dart';
import '../models/products/corporate_product.dart';
import 'repository.dart';

/// Repository específico para produtos com dados de exemplo
class ProductRepository extends MemoryRepository<Product> {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal() {
    _initializeData();
  }

  void _initializeData() {
    // Produtos Industriais
    save(IndustrialProduct(
      id: 'ind_001',
      name: 'Motor Trifásico 5CV',
      description: 'Motor elétrico trifásico para uso industrial',
      basePrice: 2500.00,
    ));

    save(IndustrialProduct(
      id: 'ind_002',
      name: 'Compressor Industrial 50HP',
      description: 'Compressor de ar para aplicações industriais',
      basePrice: 15000.00,
    ));

    // Produtos Residenciais
    save(ResidentialProduct(
      id: 'res_001',
      name: 'Ventilador de Teto',
      description: 'Ventilador de teto com controle remoto',
      basePrice: 350.00,
    ));

    save(ResidentialProduct(
      id: 'res_002',
      name: 'Ar Condicionado Split 12000 BTUs',
      description: 'Ar condicionado split para ambientes residenciais',
      basePrice: 1200.00,
    ));

    // Produtos Corporativos
    save(CorporateProduct(
      id: 'corp_001',
      name: 'Sistema ERP Corporativo',
      description: 'Sistema integrado de gestão empresarial',
      basePrice: 50000.00,
    ));

    save(CorporateProduct(
      id: 'corp_002',
      name: 'Plataforma de BI Analytics',
      description: 'Solução de Business Intelligence e Analytics',
      basePrice: 25000.00,
    ));
  }

  /// Buscar produtos por tipo
  Future<List<Product>> findByType(String productType) async {
    return findWhere((product) => product.productType == productType);
  }

  /// Buscar produtos na faixa de preço
  Future<List<Product>> findByPriceRange(double min, double max) async {
    return findWhere(
        (product) => product.basePrice >= min && product.basePrice <= max);
  }

  /// Alias para findAll (para compatibilidade com testes)
  Future<List<Product>> getAll() async {
    return findAll();
  }
}
