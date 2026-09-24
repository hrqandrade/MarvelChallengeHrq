# Histórico de versões

Este arquivo registra as mudanças relevantes de cada versão publicada.

## 2.0.0 — 2026-09-24

### Arquitetura

- Migração do fluxo principal para MVVM-C, com navegação centralizada e dependências injetadas.
- Separação das telas em View, ViewController e ViewModel.
- Serviços de rede e persistência definidos por protocolos.

### Plataforma

- Interface reconstruída com UIKit programático e Auto Layout.
- Remoção de CocoaPods, Realm, ReachabilitySwift e SDWebImage.
- Rede baseada em URLSession e persistência de favoritos com Codable.
- Carregamento de imagens e Design System distribuídos como pacotes Swift próprios, atualizados para 1.0.1 com licença MIT.

### Experiência

- Interface adaptável a Dynamic Type, Bold Text e Reduce Motion.
- Textos disponíveis em português do Brasil e inglês.
- Modo de demonstração local para builds Debug.
- Assets revisados e controles baseados em SF Symbols.

### Qualidade

- Cobertura automatizada para regras de apresentação, rede, persistência, memória e fluxos principais.
- Verificações de formatação, análise estática, build e testes na integração contínua.
- Simulator iOS 18.5 criado e inicializado explicitamente na CI, com destino selecionado por identificador.
- Archive Release reproduzível e verificação do produto compilado.

### Licenciamento

- Licença MIT para o código próprio e avisos separados sobre direitos de terceiros.
- Substituição do ícone com logo oficial por uma composição geométrica própria e remoção do logo da tela de abertura.

### Escopo da publicação

Código-fonte para estudo e demonstração local em Debug. Sem IPA ou publicação na App Store; o archive é usado somente na validação de compilação.

### Limitações conhecidas

- O modo live exige credenciais próprias da API da Marvel configuradas localmente.
- Sem um serviço intermediário, a chave privada não deve ser usada em uma distribuição pública.
- VoiceOver e Memory Graph em aparelho físico foram adiados por decisão do responsável; não foram validados nesta release.
- A distribuição do modo live depende de conferir os termos e a atribuição da API; a consulta oficial retornou HTTP 403 nesta revisão.
