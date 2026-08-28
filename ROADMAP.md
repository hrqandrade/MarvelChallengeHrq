# Roadmap técnico

Este roadmap organiza a evolução do Marvel Challenge até a versão 2.0.0. O planejamento combina entregas de produto, redução de risco e melhoria contínua da base de código.

## Como o roadmap evolui

- Descobertas técnicas entram no planejamento com impacto, prioridade e critério de conclusão.
- Riscos de crash, perda de dados, concorrência e retenção têm precedência sobre melhorias cosméticas.
- Testes fazem parte de cada entrega; não são uma etapa deixada apenas para o final.
- Refatorações devem preservar comportamento ou declarar explicitamente a mudança esperada.
- Cada fase parte da `develop` e retorna por Pull Request com validação reproduzível.

## Fases

### 0. Fundação da modernização — concluída

- Migrar a arquitetura principal de MVC para MVVM-C.
- Remover CocoaPods e adotar APIs nativas quando suficientes.
- Extrair o carregamento de imagens para o `MarvelImageLoader` via SPM.
- Criar o `MarvelDesignSystem` com tokens semânticos.
- Centralizar textos no String Catalog `Localizable`.
- Retirar credenciais do código versionado.
- Definir a versão 2.0.0 e o fluxo de branches.

### 1. Organização por feature e camada — concluída

- Alinhar pastas físicas e grupos do Xcode.
- Aproximar View e ViewModel dentro de cada feature.
- Separar `Application`, `Core`, `Features` e `Shared`.
- Remover arquivos e referências antigas sem uso.

Critério de conclusão: projeto compilando, testes atuais aprovados e nenhuma referência quebrada após as movimentações.

### 2. Segurança de runtime e ciclo de vida — concluída

- Corrigir o cálculo recursivo de `itemSize` nos layouts.
- Remover force casts, force unwraps e dependências implicitamente desembrulhadas evitáveis.
- Limpar closures e cancelar imagens em `prepareForReuse`.
- Integrar o loading ao fluxo de estado ou remover o componente enquanto não tiver uso.
- Validar desalocação de Coordinator, ViewControllers, ViewModels e células.

Critério de conclusão: ausência de caminhos conhecidos de crash por cast/unwrap e testes básicos de desalocação. A análise manual no Memory Graph faz parte da regressão da release.

### 3. Concorrência, cancelamento e paginação — concluída

- Fazer o serviço de rede devolver uma operação cancelável.
- Cancelar requisições substituídas, recarregadas ou sem consumidor.
- Isolar atualizações de apresentação na main thread com contrato explícito.
- Modelar loading inicial, refresh e paginação como estados diferentes.
- Impedir respostas antigas de sobrescrever estados recentes.
- Controlar última página e impedir requisições infinitas.

Critério de conclusão: paginação determinística, operações canceláveis e testes cobrindo concorrência, reload, falha e fim da lista.

### 4. Persistência robusta — concluída

- Manter um índice de favoritos em memória para evitar leitura de disco durante a renderização.
- Retirar I/O síncrono do caminho crítico da interface.
- Diferenciar arquivo inexistente, conteúdo corrompido e falha de escrita.
- Propagar erros de salvar e remover até o estado de apresentação.
- Validar acesso concorrente e escrita atômica.

Critério de conclusão: consultas sem I/O na main thread, erros observáveis pela UI e testes de persistência e concorrência.

### 5. Limites arquiteturais e navegação — concluída

- Separar DTOs da API, modelos de domínio e modelos de apresentação.
- Mapear respostas opcionais na fronteira da camada de rede.
- Retirar localização e mensagens de interface dos erros de infraestrutura.
- Introduzir uma fábrica de telas para tornar a injeção obrigatória e testável.
- Fazer o Coordinator controlar apresentação e encerramento de todos os fluxos.
- Remover Storyboards das telas e construí-las programaticamente com Auto Layout.
- Eliminar outlets, actions e identifiers, tornando dependências obrigatórias por inicializador.

Critério de conclusão: UI sem dependência direta de DTOs, infraestrutura sem dependência de localização e navegação testável fora das ViewControllers.

### 6. Estratégia de testes — concluída

- Cobrir estados e transições dos ViewModels.
- Testar o `HeroService` com `URLProtocol`, sem rede real.
- Cobrir paginação, cancelamento, respostas inválidas e códigos HTTP.
- Centralizar a configuração de page size e validar offset e limite nos testes do serviço.
- Definir e testar a política para respostas parcialmente inválidas, sem descarte silencioso de DTOs.
- Cobrir persistência, atualização, ordenação, corrupção e falha de escrita.
- Adicionar testes de navegação, reuso de células e desalocação.
- Definir uma base pequena de testes de interface para os fluxos críticos.

Critério de conclusão: riscos principais cobertos por testes determinísticos e suíte executável localmente por um único comando.

### 7. Componentes do Design System — concluída

- Evoluir tokens para componentes reutilizáveis.
- Padronizar loading, empty state, cards, botões e mensagens de erro.
- Extrair `HeroesCatalogView` e `HeroesDetailsView`, mantendo as ViewControllers focadas em lifecycle e binding.
- Criar tokens semânticos para área mínima de toque, ícones, barras, cards e bordas.
- Validar Dynamic Type, contraste, VoiceOver e tamanhos de toque.

Critério de conclusão: telas principais compostas por estilos e componentes compartilhados, com validação básica de acessibilidade.

### 8. Integração contínua e qualidade — em andamento

- Executar build e testes em Pull Requests.
- Aplicar SwiftFormat e SwiftLint de forma reproduzível.
- Tornar explícitos os contratos de fila dos serviços e remover dispatches defensivos redundantes.
- Remover métodos vazios e comentários residuais dos templates do Xcode.
- Adicionar regras de contribuição e checklist de revisão.
- Monitorar tempo de build, warnings e estabilidade dos testes.

Critério de conclusão: nenhuma alteração entra na `develop` sem validação automatizada da base.

### 8.1. Ambiente de demonstração — em andamento

- Disponibilizar dados representativos para revisão visual sem credenciais da API.
- Ativar o modo de demonstração apenas por argumento de lançamento em builds Debug.
- Preservar a composição real como comportamento padrão de desenvolvimento.
- Garantir que serviços e dados de demonstração não sejam compilados em Release.

Critério de conclusão: catálogo, favoritos e detalhes navegáveis com dados determinísticos, sem alterar o comportamento do aplicativo distribuído.

### 9. Release 2.0.0 — planejada

- Executar regressão funcional e revisão de memória e performance.
- Atualizar changelog e documentação de execução.
- Abrir Pull Request da `develop` para a `master`.
- Criar a tag e a release 2.0.0.

Critério de conclusão: release reproduzível, documentada e gerada a partir da `master` validada.

## Definition of Done

Uma etapa é considerada concluída quando:

- o código compila sem novos warnings relevantes;
- testes proporcionais ao risco foram adicionados e estão passando;
- memória, concorrência e estados de erro foram considerados na revisão;
- documentação e roadmap refletem a decisão final;
- o Pull Request foi revisado e integrado à `develop`.
