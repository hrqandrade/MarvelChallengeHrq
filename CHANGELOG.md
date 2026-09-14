# Histórico de versões

Este arquivo registra as mudanças relevantes de cada versão publicada.

## 2.0.0 — em preparação

### Arquitetura

- Migração do fluxo principal para MVVM-C, com navegação centralizada e dependências injetadas.
- Separação das telas em View, ViewController e ViewModel.
- Serviços de rede e persistência definidos por protocolos.

### Plataforma

- Interface reconstruída com UIKit programático e Auto Layout.
- Remoção de CocoaPods, Realm, ReachabilitySwift e SDWebImage.
- Rede baseada em URLSession e persistência de favoritos com Codable.
- Carregamento de imagens e Design System distribuídos como pacotes Swift próprios.

### Experiência

- Interface adaptável a Dynamic Type, Bold Text e Reduce Motion.
- Textos disponíveis em português do Brasil e inglês.
- Modo de demonstração local para builds Debug.
- Assets revisados e controles baseados em SF Symbols.

### Qualidade

- Cobertura automatizada para regras de apresentação, rede, persistência, memória e fluxos principais.
- Verificações de formatação, análise estática, build e testes na integração contínua.
- Archive Release reproduzível e verificação do produto compilado.

### Limitações conhecidas

- O modo live exige credenciais próprias da API da Marvel configuradas localmente.
- Sem um serviço intermediário, a chave privada não deve ser usada em uma distribuição pública.
- A validação final de VoiceOver e o profiling da release dependem de execução em aparelho físico.
