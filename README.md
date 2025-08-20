# AltForce - Sistema de Orçamentos Dinâmicos

Sistema de orçamentos com formulários dinâmicos, engine de regras configuráveis e arquitetura OOP avançada desenvolvido em Flutter.

## 🏗️ Arquitetura

### Estrutura do Projeto

```
lib/
├── models/
│   ├── base/
│   │   └── base_model.dart          # Modelo base abstrato
│   ├── products/
│   │   ├── product.dart             # Classe abstrata Product
│   │   ├── industrial_product.dart  # Especialização industrial
│   │   ├── residential_product.dart # Especialização residencial
│   │   └── corporate_product.dart   # Especialização corporativa
│   ├── rules/
│   │   ├── business_rule.dart       # Classe abstrata BusinessRule
│   │   ├── pricing_rule.dart        # Regras de precificação
│   │   ├── validation_rule.dart     # Regras de validação
│   │   └── visibility_rule.dart     # Regras de visibilidade
│   └── fields/
│       └── form_field_config.dart   # Configuração de campos dinâmicos
├── repositories/
│   ├── repository.dart              # Interface genérica IRepository<T>
│   └── product_repository.dart      # Repository específico para produtos
├── services/
│   ├── rules_engine.dart            # Engine de regras genérica
│   └── rules_service.dart           # Serviço de inicialização de regras
├── controllers/
│   ├── form_controller.dart         # Controller genérico para formulários
│   └── budget_controller.dart       # Controller principal
├── widgets/
│   ├── dynamic_form_field.dart      # Factory para campos dinâmicos
│   ├── dynamic_form_widget.dart     # Widget de formulário dinâmico
│   ├── product_selector.dart        # Seletor de produtos
│   ├── pricing_summary.dart         # Resumo de preços
│   └── loading_overlay.dart         # Overlay de carregamento
└── screens/
    └── budget_screen.dart           # Tela principal
```

## 🎯 Características Implementadas

### ✅ Arquitetura OOP + Genéricos + DRY

- **Hierarquias Polimórficas**: `Product` → `IndustrialProduct` | `ResidentialProduct` | `CorporateProduct`
- **Genéricos Type-Safe**: `IRepository<T extends BaseModel>`, `FormController<T extends Product>`
- **Strategy Pattern**: `PricingRule`, `ValidationRule`, `VisibilityRule`
- **Template Method**: Classes base abstratas com algoritmos reutilizáveis
- **Composition**: `RulesEngine` = `ConditionEvaluator` + `ActionExecutor` + `PriorityManager`

### ✅ Formulário Dinâmico Inteligente

- **Reconstrução Automática**: Campos se adaptam ao tipo de produto selecionado
- **Factory Pattern**: `DynamicFormFieldFactory` para widgets dinâmicos
- **Validação Contextual**: Regras aplicadas em tempo real

### ✅ Engine de Regras de Negócio

**Regras de Preço Implementadas:**
- Desconto por volume (≥50 unidades = 15%)
- Taxa de urgência (<7 dias = +20%)
- Desconto VIP (10% para clientes especiais)

**Regras de Validação:**
- Certificação obrigatória (Industrial + voltagem >220V)
- Quantidade mínima
- Validação de prazo de entrega

**Regras de Visibilidade:**
- Campos específicos por tipo de produto
- Certificação obrigatória baseada em voltagem
- Suporte 24x7 obrigatório para contratos Enterprise

### ✅ Estados Interdependentes

- **Reatividade**: Produto muda → recalcular preços + aplicar regras + reconfigurar formulário
- **Coordenação**: Quantidade muda → reaplicar regras de desconto + validações
- **Performance**: Evita rebuilds desnecessários

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.6.0 ou superior
- Dart SDK 3.6.0 ou superior

### Instalação

1. Clone o repositório:
```bash
git clone <repo-url>
cd altdesafaio
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute a aplicação:
```bash
flutter run
```

## 📱 Fluxos de Teste

### Fluxo Principal

1. **Produto Industrial** → Campos específicos aparecem → Voltagem >220V → Certificação obrigatória
2. **Quantidade 100** → Desconto volume aplicado → Cliente VIP → Desconto adicional
3. **Trocar para Residencial** → Formulário reconstrói → Regras continuam funcionando

### Cenários de Teste

- **Polimorfismo**: Lista mista de produtos processada via interface `Product`
- **Genéricos**: Repository aceita apenas tipos corretos (erro compilação com tipo inválido)
- **DRY**: Validações similares não duplicadas, cálculos centralizados
- **Composition**: Componentes compostos, não herdados

## 🧪 Demonstração das Regras

### Produtos Disponíveis

**Industrial:**
- Motor Trifásico 5CV (R$ 2.500,00)
- Compressor Industrial 50HP (R$ 15.000,00)

**Residencial:**
- Ventilador de Teto (R$ 350,00)
- Ar Condicionado Split 12000 BTUs (R$ 1.200,00)

**Corporativo:**
- Sistema ERP Corporativo (R$ 50.000,00)
- Plataforma de BI Analytics (R$ 25.000,00)

### Exemplo de Cálculo

**Cenário**: Motor Trifásico, 380V, 100 unidades, entrega em 5 dias, cliente VIP

```
Preço Base: R$ 2.500,00
+ Alta voltagem (380V): +20% = R$ 3.000,00
+ Taxa urgência (5 dias): +20% = R$ 3.600,00
- Desconto volume (100 unid): -15% = R$ 3.060,00
- Desconto adicional (100+): -5% = R$ 2.907,00
- Desconto VIP: -10% = R$ 2.616,30

Preço Final: R$ 2.616,30 por unidade
Total (100x): R$ 261.630,00
```

## 🔧 Padrões de Design Utilizados

- **Strategy Pattern**: Engine de regras intercambiáveis
- **Factory Pattern**: Criação de widgets dinâmicos
- **Repository Pattern**: Acesso a dados type-safe
- **Observer Pattern**: Controllers reativos
- **Template Method**: Algoritmos reutilizáveis
- **Composition over Inheritance**: Componentização

## 📊 Benefícios da Arquitetura

- **Escalabilidade**: Fácil adição de novos tipos de produtos e regras
- **Manutenibilidade**: Código organizado e bem estruturado
- **Reutilização**: Componentes genéricos aplicáveis a diferentes cenários
- **Testabilidade**: Arquitetura facilita testes unitários e de integração
- **Performance**: Otimizações para evitar rebuilds desnecessários

## 🎨 Interface

- **Design Responsivo**: Adaptável a diferentes tamanhos de tela
- **UX Fluida**: Transições suaves e feedback adequado
- **Visual Moderno**: Material Design 3
- **Acessibilidade**: Componentes acessíveis

## 📝 Próximos Passos

- [ ] Persistência de dados (SQLite/Hive)
- [ ] Testes unitários e de integração
- [ ] Geração de PDFs dos orçamentos
- [ ] Histórico de orçamentos
- [ ] Configuração avançada de regras via interface
- [ ] API REST para sincronização
- [ ] Modo offline

---

**Desenvolvido por**: AltForce Challenge
**Framework**: Flutter 3.6.0
**Linguagem**: Dart 3.6.0