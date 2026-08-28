# Marvel Challenge

Aplicativo iOS para consultar personagens da Marvel, ver detalhes e manter uma lista local de favoritos. Mais do que uma demonstração de interface, este repositório registra a evolução de um projeto legado para uma base moderna, modular e testável.

Versão atual: **2.0.0**

## A história do projeto

Este projeto nasceu em 2019 como um desafio técnico. Naquele momento, o objetivo era entregar as funcionalidades principais: consumir a API da Marvel, listar personagens, apresentar detalhes e persistir favoritos. A solução cumpria esse papel usando MVC, delegates e bibliotecas populares do ecossistema iOS da época.

Com o passar dos anos, o código passou a representar também uma fotografia daquele período: responsabilidades concentradas nas telas, navegação acoplada às ViewControllers, credenciais no código e dependências externas para persistência, conectividade e imagens.

Em 2026, decidi revisitar o desafio com uma proposta diferente: não apagar o passado, mas usá-lo para demonstrar evolução técnica. A versão 2.0.0 moderniza o projeto em etapas pequenas e revisáveis, preservando o histórico do Git para que cada decisão possa ser acompanhada.

O resultado é um estudo prático sobre manutenção de software: partir de uma aplicação funcional, identificar os acoplamentos que limitam sua evolução e construir uma arquitetura mais clara sem reescrever tudo de uma vez.

## Da versão original à 2.0.0

| Aspecto | Versão original | Versão 2.0.0 |
| --- | --- | --- |
| Arquitetura | MVC com lógica e navegação próximas das telas | MVVM-C com responsabilidades separadas |
| Criação do fluxo | ViewControllers instanciavam e controlavam dependências | Coordinator monta o fluxo e injeta dependências |
| Construção das telas | Storyboard, outlets, actions e identifiers | UIKit programático, Auto Layout e inicializadores obrigatórios |
| Comunicação | Delegates concretos entre managers e telas | Estados observáveis e serviços definidos por protocolos |
| Rede | Manager acoplado e validação por `ReachabilitySwift` | `URLSession`, erros tipados e tratamento de resposta HTTP |
| Favoritos | `RealmSwift` e imagem persistida em Base64 | `Codable` e armazenamento local atrás de protocolo |
| Imagens | `SDWebImage` | [`MarvelImageLoader`](https://github.com/hrqandrade/MarvelImageLoader) próprio, via SPM |
| Estilos | Cores, fontes e medidas distribuídas pelas telas | [`MarvelDesignSystem`](https://github.com/hrqandrade/MarvelDesignSystem) com tokens semânticos |
| Textos | Strings literais nas classes e interfaces | String Catalog com inglês e português do Brasil |
| Credenciais | Chaves armazenadas no código-fonte | Configuração local fora do versionamento |
| Dependências | CocoaPods | Swift Package Manager apenas para módulos próprios |
| Testabilidade | Dependência de managers concretos e do ambiente | Protocolos, injeção de dependência e testes com doubles |

### Princípios da modernização

- **Evolução incremental:** cada etapa parte da `develop` e retorna por Pull Request.
- **Dependências justificadas:** recursos simples usam APIs nativas; módulos reutilizáveis viram pacotes próprios.
- **Código orientado a contratos:** serviços e persistência ficam atrás de protocolos.
- **UI consistente:** estilos e textos deixam de ser decisões isoladas de cada tela.
- **Histórico preservado:** a implementação original continua acessível nos commits antigos para permitir a comparação.

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
- **Views:** encapsulam hierarquia, Auto Layout e renderização, mantendo as ViewControllers focadas em lifecycle e binding.
- **Shared Design System:** reúne header, cards, loading, empty state e métricas semânticas reutilizadas pelas features.

### Organização do código

```text
MarvelChallenge
├── Application
│   ├── AppCoordinator
│   ├── AppDelegate
│   └── SceneDelegate
├── Core
│   ├── Extensions
│   ├── Localization
│   ├── Networking
│   │   └── Models
│   └── Persistence
├── Features
│   ├── HeroesCatalog
│   │   ├── View
│   │   │   ├── Cells
│   │   │   └── Layouts
│   │   └── ViewModel
│   └── HeroesDetails
│       ├── View
│       │   └── Cells
│       └── ViewModel
```

Cada feature mantém sua View e seu ViewModel próximos. Infraestruturas compartilhadas ficam em `Core` e o ciclo de vida do aplicativo fica em `Application`. Um diretório `Shared` será introduzido quando houver componentes de interface efetivamente reutilizados por mais de uma feature.

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

Os testes cobrem estados e concorrência do ViewModel, contratos HTTP do `HeroService` com `URLProtocol`, cancelamento e paginação, política de payload inválido, cache e persistência atômica de favoritos, reuso de células, composição programática, navegação e desalocação dos principais fluxos. Para executá-los:

```bash
xcodebuild test \
  -project MarvelChallenge.xcodeproj \
  -scheme MarvelChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Qualidade e integração contínua

As versões de SwiftFormat e SwiftLint são fixadas no `Mintfile`. Após instalar o [Mint](https://github.com/yonaskolb/Mint), a validação local pode ser reproduzida com os mesmos comandos executados pela integração contínua:

```bash
make bootstrap
make quality
make build
make test
```

Pull Requests para `develop` e `master` executam formatação, análise estática, build e os testes automatizados. O processo de contribuição e os critérios de revisão estão documentados em [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Modo de demonstração

Builds `Debug` iniciam com personagens e favoritos em memória. Esse modo facilita a revisão visual do catálogo, das duas opções de layout, dos favoritos e da tela de detalhes sem depender de credenciais da API.

Para validar a integração real durante o desenvolvimento, edite o Scheme no Xcode, abra `Run > Arguments` e adicione `-useLiveData` em `Arguments Passed On Launch`. Builds `Release` sempre usam as dependências reais e não compilam o suporte aos dados de demonstração.

## Roadmap

A evolução técnica até a release 2.0.0 está organizada no [`ROADMAP.md`](ROADMAP.md). O planejamento inclui segurança de runtime, ciclo de vida e memória, cancelamento, paginação, persistência, limites arquiteturais, testes, componentes do Design System e integração contínua.

O roadmap é tratado como um documento vivo: descobertas técnicas são priorizadas pelo risco e incorporadas às próximas entregas com critérios claros de conclusão.
