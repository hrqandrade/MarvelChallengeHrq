# Roadmap técnico

Este arquivo acompanha a modernização do Marvel Challenge até a versão 2.0.0. Ele nasceu para registrar o que já mudou, o que aprendemos no caminho e o que ainda falta antes da release.

## Como estamos trabalhando

- Problemas de crash, perda de dados, concorrência e memória vêm antes de ajustes cosméticos.
- Cada entrega leva seus próprios testes. Não deixamos toda a validação para o final.
- Refatorações preservam o comportamento existente, salvo quando a mudança é intencional e documentada.
- O trabalho parte da `develop` e volta para ela por Pull Request.

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

Consideramos esta fase pronta com o projeto compilando, os testes aprovados e as referências do Xcode organizadas.

### 2. Segurança de runtime e ciclo de vida — concluída

- Corrigir o cálculo recursivo de `itemSize` nos layouts.
- Remover force casts, force unwraps e dependências implicitamente desembrulhadas evitáveis.
- Limpar closures e cancelar imagens em `prepareForReuse`.
- Integrar o loading ao fluxo de estado ou remover o componente enquanto não tiver uso.
- Validar desalocação de Coordinator, ViewControllers, ViewModels e células.

Esta fase foi encerrada sem caminhos conhecidos de crash por cast ou unwrap e com testes básicos de desalocação. A regressão da release ainda inclui uma passagem manual pelo Memory Graph.

### 3. Concorrência, cancelamento e paginação — concluída

- Fazer o serviço de rede devolver uma operação cancelável.
- Cancelar requisições substituídas, recarregadas ou sem consumidor.
- Isolar atualizações de apresentação na main thread com contrato explícito.
- Modelar loading inicial, refresh e paginação como estados diferentes.
- Impedir respostas antigas de sobrescrever estados recentes.
- Controlar última página e impedir requisições infinitas.

Esta fase ficou pronta com paginação previsível, operações canceláveis e testes para reload, falhas, concorrência e fim da lista.

### 4. Persistência robusta — concluída

- Manter um índice de favoritos em memória para evitar leitura de disco durante a renderização.
- Retirar I/O síncrono do caminho crítico da interface.
- Diferenciar arquivo inexistente, conteúdo corrompido e falha de escrita.
- Propagar erros de salvar e remover até o estado de apresentação.
- Validar acesso concorrente e escrita atômica.

Esta fase ficou pronta quando as consultas deixaram de acessar disco na main thread e os erros passaram a chegar até a camada de apresentação.

### 5. Limites arquiteturais e navegação — concluída

- Separar DTOs da API, modelos de domínio e modelos de apresentação.
- Mapear respostas opcionais na fronteira da camada de rede.
- Retirar localização e mensagens de interface dos erros de infraestrutura.
- Introduzir uma fábrica de telas para tornar a injeção obrigatória e testável.
- Fazer o Coordinator controlar apresentação e encerramento de todos os fluxos.
- Remover Storyboards das telas e construí-las programaticamente com Auto Layout.
- Eliminar outlets, actions e identifiers, tornando dependências obrigatórias por inicializador.

Ao final desta fase, a UI deixou de depender dos DTOs da API, a infraestrutura deixou de conhecer textos de interface e a navegação passou a ser testável fora das ViewControllers.

### 6. Estratégia de testes — concluída

- Cobrir estados e transições dos ViewModels.
- Testar o `HeroService` com `URLProtocol`, sem rede real.
- Cobrir paginação, cancelamento, respostas inválidas e códigos HTTP.
- Centralizar a configuração de page size e validar offset e limite nos testes do serviço.
- Definir e testar a política para respostas parcialmente inválidas, sem descarte silencioso de DTOs.
- Cobrir persistência, atualização, ordenação, corrupção e falha de escrita.
- Adicionar testes de navegação, reuso de células e desalocação.
- Cobrir a composição programática e os fluxos principais das telas sem depender de rede real.

Esta fase foi concluída com os principais riscos cobertos e a suíte executável localmente por um único comando. Testes end-to-end de interface continuam como uma evolução futura.

### 7. Componentes do Design System — concluída

- Evoluir tokens para componentes reutilizáveis.
- Padronizar loading, empty state, cards, botões e mensagens de erro.
- Extrair `HeroesCatalogView` e `HeroesDetailsView`, mantendo as ViewControllers focadas em lifecycle e binding.
- Criar tokens semânticos para área mínima de toque, ícones, barras, cards e bordas.
- Adotar Dynamic Type, rótulos de VoiceOver e áreas mínimas de toque nos componentes principais.

Esta fase ficou pronta com as telas principais usando estilos e componentes compartilhados. A revisão completa de contraste e tamanhos extremos de Dynamic Type será repetida na regressão da release.

### 8. Integração contínua e qualidade — concluída

- Executar build e testes em Pull Requests.
- Aplicar SwiftFormat e SwiftLint de forma reproduzível.
- Tornar explícitos os contratos de fila dos serviços e remover dispatches defensivos redundantes.
- Remover métodos vazios e comentários residuais dos templates do Xcode.
- Adicionar regras de contribuição e checklist de revisão.
- Monitorar tempo de build, warnings e estabilidade dos testes.

Esta fase foi concluída com checks obrigatórios de qualidade, build e testes antes do merge na `develop`.

### 9. Ambiente de demonstração — concluída

- Disponibilizar dados representativos para revisão visual sem credenciais da API.
- Ativar dados de demonstração por padrão em builds Debug.
- Permitir integração real em Debug por argumento de lançamento explícito.
- Garantir que serviços e dados de demonstração não sejam compilados em Release.

Esta fase ficou pronta com catálogo, favoritos e detalhes navegáveis usando dados previsíveis. O código de demonstração não faz parte dos builds de Release.

### 10. Estabilidade da suíte e persistência — concluída

- Corrigir o warning de transição de aparência que ainda aparece durante os testes.
- Separar as regras do `FavoritesStore` do acesso físico ao arquivo.
- Manter poucos testes de integração com disco e executar os demais com uma implementação em memória.
- Reduzir a dependência de timeouts longos sem diminuir a carga ou as verificações dos testes.
- Preservar a escrita atômica e atualizar o cache somente depois que os dados forem persistidos.

Esta fase ficou pronta com a navegação testável sem lifecycle artificial, regras de persistência executadas em memória e testes de integração dedicados ao arquivo real.

### 11. Demonstração offline — planejada

- Substituir as imagens remotas do modo demo por assets locais com origem documentada.
- Manter as URLs reais apenas no fluxo de integração com a API.
- Garantir que catálogo, favoritos e detalhes possam ser avaliados sem conexão com a internet.

Esta fase estará pronta quando toda a navegação de demonstração funcionar em modo avião sem placeholders inesperados.

### 12. Estados de erro e feedback — planejada

- Apresentar falhas de catálogo no contexto da tela, com opção de tentar novamente.
- Preservar o conteúdo existente quando refresh, paginação ou favoritos falharem.
- Diferenciar loading inicial, atualização e carregamento da próxima página visualmente.
- Dar retorno claro ao adicionar ou remover um favorito.

Esta fase estará pronta quando cada operação assíncrona tiver estados de carregamento, sucesso e falha perceptíveis sem interromper a navegação desnecessariamente.

### 13. Acessibilidade e adaptação de layout — planejada

- Validar VoiceOver, ordem de leitura, traits e estado dos controles.
- Revisar contraste, Bold Text, Reduce Motion e os maiores tamanhos de Dynamic Type.
- Remover alturas fixas que causem truncamento nos tamanhos de acessibilidade.
- Definir e validar as orientações realmente suportadas no iPhone e no iPad.

Esta fase estará pronta depois de uma passagem manual documentada pelas configurações de acessibilidade e tamanhos de tela suportados.

### 14. Testes dos fluxos principais — planejada

- Criar um target enxuto de UI Tests.
- Cobrir abertura em modo demo, troca de layout, detalhes e favoritos.
- Validar a presença das localizações em inglês e português do Brasil.
- Impedir que chaves de localização apareçam diretamente na interface.

Esta fase estará pronta com os fluxos essenciais cobertos sem rede real e executando de forma estável na CI.

### 15. Assets e acabamento visual — planejada

- Revisar App Icon, logo, favoritos e ilustrações de estado vazio.
- Preferir SF Symbols ou assets vetoriais quando fizer sentido.
- Remover arquivos duplicados ou herdados que não sejam mais usados.
- Conferir consistência visual entre a Launch Screen e a primeira tela.

Esta fase estará pronta com um catálogo de assets pequeno, rastreável e adequado às escalas e aparências suportadas.

### 16. Preparação da release — planejada

- Gerar e validar um archive de Release.
- Confirmar que mocks, argumentos de demonstração e credenciais não estão no binário final.
- Executar regressão funcional, Memory Graph, Leaks, Allocations e revisão de performance durante scroll.
- Revisar warnings, licenças, atribuições e limitações conhecidas.
- Criar o changelog da versão 2.0.0.

Esta fase estará pronta com um archive limpo, reproduzível e acompanhado das evidências da regressão final.

### 17. Release 2.0.0 — planejada

- Abrir Pull Request da `develop` para a `master`.
- Criar a tag e a release 2.0.0.
- Publicar o resumo da modernização e as limitações conhecidas.

A versão 2.0.0 estará pronta quando puder ser reproduzida a partir da `master`, com documentação, tag e regressão final concluídas.

## Quando uma fase está pronta

Antes de marcar uma fase como concluída, conferimos se:

- o código compila sem novos warnings relevantes;
- testes proporcionais ao risco foram adicionados e estão passando;
- memória, concorrência e estados de erro foram considerados na revisão;
- documentação e roadmap refletem a decisão final;
- o Pull Request foi revisado e integrado à `develop`.
