# Marvel Challenge

Aplicativo iOS para consultar personagens da Marvel, ver detalhes e manter uma lista local de favoritos.

Versão atual: **2.0.0**

## Contexto

Este projeto foi criado originalmente em 2017 como um desafio técnico. A implementação refletia as práticas e ferramentas disponíveis naquele período e, posteriormente, recebeu pequenos ajustes de compatibilidade.

Em 2026, o projeto começou a ser modernizado para servir como exemplo de uma aplicação UIKit com arquitetura MVVM-C, dependências explícitas e código testável. A atualização é incremental para preservar o histórico e tornar cada decisão arquitetural revisável.

## Requisitos

- Xcode 16.4 ou superior
- iOS 13.0 ou superior
- Swift 5
- Conta de desenvolvedor no [Marvel Developer Portal](https://developer.marvel.com/)

O projeto não utiliza CocoaPods. Dependências próprias são distribuídas por Swift Package Manager.

## Configuração

As credenciais da API não são versionadas. O repositório contém apenas o contrato em `Config/Secrets.xcconfig.example`; `Config/Secrets.xcconfig` está no `.gitignore`.

Para executar pelo Xcode, no scheme `MarvelChallenge`, em **Run > Arguments > Environment Variables**, adicione:

- `MARVEL_PUBLIC_KEY`
- `MARVEL_PRIVATE_KEY`

Quem clonar o projeto deve usar suas próprias credenciais. Chaves que já tenham sido publicadas no histórico do repositório devem ser revogadas e substituídas.

Esta configuração é adequada para demonstração e desenvolvimento local. Um aplicativo distribuído não deve carregar a chave privada da Marvel no binário; em produção, a autenticação deve ficar em um serviço intermediário.

Abra `MarvelChallenge.xcodeproj`, selecione um simulador e execute o app.

## Arquitetura

O fluxo principal usa MVVM-C:

```text
SceneDelegate
    └── AppCoordinator
        ├── HeroesCatalogViewController
        │   └── HeroesCatalogViewModel
        └── HeroesDetailsViewController
            └── HeroesDetailsViewModel

ViewModels
    ├── HeroServicing
    │   └── HeroService (URLSession)
    └── FavoritesStoring
        └── FavoritesStore (Codable + arquivo local)
```

- **Coordinator:** cria o fluxo, injeta dependências e controla a navegação.
- **View:** renderiza estado e encaminha ações do usuário.
- **ViewModel:** concentra estado e regras de apresentação sem depender de UIKit.
- **Services/Stores:** implementam infraestrutura atrás de protocolos, permitindo mocks nos testes.

O carregamento de imagens é fornecido pelo pacote próprio [`MarvelImageLoader`](https://github.com/hrqandrade/MarvelImageLoader), integrado por Swift Package Manager e construído com `URLSession` e `NSCache`.

## Design System e localização

Os estilos visuais são fornecidos pelo pacote próprio [`MarvelDesignSystem`](https://github.com/hrqandrade/MarvelDesignSystem), integrado por Swift Package Manager. Cores semânticas, tipografia, espaçamentos, raios e sombras ficam centralizados no pacote para reduzir valores visuais dispersos pelas telas.

Os textos de interface ficam no String Catalog `Localizable.xcstrings`, com traduções em inglês e português do Brasil. O arquivo `Localizable.swift` oferece uma interface organizada por contexto para evitar chaves e textos literais nas classes de apresentação.

## Estratégia de branches

- `master`: versão estável.
- `develop`: integração das próximas entregas.
- `feat/{nome-da-feature}`: desenvolvimento de cada funcionalidade ou melhoria.

Toda feature parte da `develop` e retorna por Pull Request para a `develop`. A `master` recebe apenas entregas estabilizadas por Pull Request vindo da `develop`.

Exemplo:

```bash
git switch develop
git pull
git switch -c feat/image-loader-spm
```

## Testes

Os testes cobrem o estado do ViewModel com serviço simulado e a persistência de favoritos. Para executá-los:

```bash
xcodebuild test \
  -project MarvelChallenge.xcodeproj \
  -scheme MarvelChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Próximas evoluções

- Separar as pastas por feature e camada no projeto Xcode.
- Ampliar testes de paginação, falhas de rede e navegação.
- Adicionar CI para build e testes em Pull Requests.
- Evoluir o Design System com componentes reutilizáveis de interface.
