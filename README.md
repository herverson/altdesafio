# AltForce - Sistema de Orçamentos Dinâmicos

Sistema de orçamentos com formulários dinâmicos, engine de regras configuráveis e arquitetura OOP avançada desenvolvido em Flutter.

## 🏗️ Arquitetura

### Estrutura do Projeto

```
lib/
├── core/
│   ├── design/
│   │   └── app_theme.dart           # Sistema de design e temas
│   ├── mixins/
│   │   ├── calculator_mixin.dart    # Funcionalidades de cálculo
│   │   ├── formatter_mixin.dart     # Formatação de dados
│   │   └── validator_mixin.dart     # Validações comuns
│   └── result/
│       └── result.dart              # Pattern para tratamento de erros
├── models/
│   ├── base/
│   │   └── base_model.dart          # Modelo base abstrato
│   ├── products/
│   │   ├── product.dart             # Classe abstrata Product (com mixins)
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
│   ├── repository.dart              # Interface genérica IRepository<T> com Result Pattern
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
│   ├── unified_form_summary.dart    # Formulário unificado
│   ├── product_card.dart            # Card de produto
│   ├── loading_overlay.dart         # Overlay de carregamento
│   └── bottom_navigation.dart       # Navegação inferior
├── screens/
│   └── budget_screen.dart           # Tela principal
└── main.dart                        # Ponto de entrada da aplicação
```

## 🎯 Características Implementadas

### ✅ Arquitetura OOP + Genéricos + DRY + Mixins

- **Hierarquias Polimórficas**: `Product` → `IndustrialProduct` | `ResidentialProduct` | `CorporateProduct`
- **Genéricos Type-Safe**: `IRepository<T extends BaseModel>`, `FormController<T extends Product>`
- **Mixins Funcionais**: `CalculatorMixin`, `FormatterMixin`, `ValidatorMixin` integrados nos produtos
- **Result Pattern**: Tratamento robusto de erros com `Result<T>`
- **Strategy Pattern**: `PricingRule`, `ValidationRule`, `VisibilityRule`
- **Template Method**: Classes base abstratas com algoritmos reutilizáveis
- **Composition**: `RulesEngine` = `ConditionEvaluator` + `ActionExecutor`

### ✅ Funcionalidades dos Mixins

**CalculatorMixin:**
- Cálculos de porcentagem e descontos
- Operações matemáticas reutilizáveis
- Validações numéricas

**FormatterMixin:**
- Formatação de moeda (`formatCurrency`)
- Formatação de porcentagens
- Formatação de dados brasileiros (CPF, CNPJ, telefone)

**ValidatorMixin:**
- Validações comuns (`isPositive`, `isValidString`)
- Validações específicas (`needsCertification`)
- Validações de documentos brasileiros

### ✅ Result Pattern

- **Tratamento de Erros**: Operações retornam `Result<T>` ao invés de `throw`
- **Composabilidade**: Métodos `.onSuccess()` e `.onFailure()`
- **Type Safety**: Erros tratados em tempo de compilação
- **Usado em**: Repository, Controller

### ✅ Formulário Dinâmico Inteligente

- **Reconstrução Automática**: Campos se adaptam ao tipo de produto selecionado
- **Factory Pattern**: `DynamicFormFieldFactory` para widgets dinâmicos
- **Validação Contextual**: Regras aplicadas em tempo real
- **Mixins Integrados**: Produtos usam métodos de formatação e validação

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

- Flutter SDK 3.8.1 ou superior
- Dart SDK 3.8.1 ou superior

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

### Testes

Execute os testes unitários:
```bash
flutter test
```

## 📱 Fluxos de Teste

### Fluxo Principal

1. **Produto Industrial** → Campos específicos aparecem → Voltagem >220V → Certificação obrigatória
2. **Quantidade 100** → Desconto volume aplicado → Cliente VIP → Desconto adicional
3. **Trocar para Residencial** → Formulário reconstrói → Regras continuam funcionando

### Demonstração dos Mixins

**Formatação:**
```dart
product.formattedPrice        // "R$ 2.616,30"
product.formattedBasePrice    // "R$ 2.500,00"
```

**Validação:**
```dart
product.isValid              // true/false
product.isPositive(price)     // true/false
product.needsCertification(voltage, cert) // true/false
```

**Cálculos:**
```dart
product.totalPrice           // basePrice * quantity
product.calculateTotal(price, qty) // cálculo direto
```

### Cenários de Teste

- **Polimorfismo**: Lista mista de produtos processada via interface `Product`
- **Genéricos**: Repository aceita apenas tipos corretos (erro compilação com tipo inválido)
- **DRY**: Validações similares não duplicadas, cálculos centralizados via mixins
- **Result Pattern**: Operações retornam `Result<T>` para tratamento de erros
- **Mixins**: Funcionalidades transversais reutilizadas em todos os produtos

## 🧪 Demonstração das Regras

### Produtos Disponíveis

**Industrial:**
- Motor Trifásico 5CV (R$ 2.500,00)
- Compressor Industrial 50HP (R$ 15.000,00)
- Sistema de Automação PLC (R$ 8.000,00)
- Painel Elétrico 400A (R$ 12.000,00)

**Residencial:**
- Ventilador de Teto (R$ 350,00)
- Ar Condicionado Split 12000 BTUs (R$ 1.200,00)
- Sistema de Iluminação LED (R$ 800,00)
- Interfone Digital (R$ 450,00)

**Corporativo:**
- Sistema ERP Corporativo (R$ 50.000,00)
- Plataforma de BI Analytics (R$ 25.000,00)
- Sistema de CRM Avançado (R$ 18.000,00)
- Plataforma de E-commerce (R$ 35.000,00)

### Exemplo de Cálculo com Mixins

**Cenário**: Motor Trifásico, 100 unidades, cliente VIP

```dart
// Usando mixins integrados no produto
final product = IndustrialProduct(...);

// Formatação automática
print(product.formattedPrice);        // "R$ 250.000,00"
print(product.formattedBasePrice);    // "R$ 2.500,00"

// Validação integrada
print(product.isValid);               // true

// Cálculos automáticos
print(product.totalPrice);            // 250000.0
```

## 🔧 Padrões de Design Utilizados

- **Strategy Pattern**: Engine de regras intercambiáveis
- **Factory Pattern**: Criação de widgets dinâmicos
- **Repository Pattern**: Acesso a dados type-safe com Result Pattern
- **Observer Pattern**: Controllers reativos
- **Template Method**: Algoritmos reutilizáveis
- **Composition over Inheritance**: Componentização + Mixins
- **Result Pattern**: Tratamento robusto de erros
- **Mixin Pattern**: Funcionalidades transversais reutilizáveis

## 📊 Benefícios da Arquitetura

- **Escalabilidade**: Fácil adição de novos tipos de produtos e regras
- **Manutenibilidade**: Código organizado, limpo e bem estruturado
- **Reutilização**: Mixins e componentes genéricos aplicáveis a diferentes cenários
- **Robustez**: Result Pattern para tratamento consistente de erros
- **Testabilidade**: Arquitetura facilita testes unitários e de integração
- **Performance**: Otimizações para evitar rebuilds desnecessários
- **DRY**: Funcionalidades comuns centralizadas em mixins

## 🎨 Interface

- **Design Responsivo**: Adaptável a diferentes tamanhos de tela
- **UX Fluida**: Transições suaves e feedback adequado
- **Visual Moderno**: Material Design 3
- **Acessibilidade**: Componentes acessíveis
- **Formatação Consistente**: Mixins garantem formatação uniforme

## 🧹 Otimizações Aplicadas

### Limpeza de Código
- ✅ Removidos 10 arquivos não utilizados (~800 linhas)
- ✅ Estrutura simplificada e organizada
- ✅ Foco apenas no código necessário

### Melhorias Implementadas
- ✅ **Mixins**: Funcionalidades transversais reutilizáveis
- ✅ **Result Pattern**: Tratamento robusto de erros
- ✅ **Arquitetura Limpa**: Código organizado e manutenível

## 🔍 Status do Projeto

| Componente | Status | Observações |
|------------|--------|-------------|
| Mixins | ✅ Funcionais | Integrados nos produtos |
| Result Pattern | ✅ Funcionais | Usado no repository/controller |
| Repository | ✅ Funcionais | Com Result Pattern |
| Engine de Regras | ✅ Funcionais | Completa e testada |
| Formulário Dinâmico | ✅ Funcionais | Responsivo e validado |
| Testes | ⚠️ Parciais | Alguns precisam atualização |

---

**Desenvolvido por**: Herverson de Sousa  
**Framework**: Flutter 3.8.1  
**Linguagem**: Dart 3.8.1  
**Última Atualização**: Dezembro 2024