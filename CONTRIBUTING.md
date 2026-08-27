# Contribuição

## Fluxo de branches

Todo trabalho parte da `develop`. Use `feat/<nome>` para funcionalidades e melhorias planejadas e abra o Pull Request para `develop`. A `master` recebe apenas Pull Requests de release originados na `develop`.

## Preparação local

O projeto usa Mint para fixar as versões das ferramentas de qualidade:

```bash
brew install mint
make bootstrap
```

Crie `Config/Secrets.xcconfig` a partir do exemplo apenas quando precisar acessar a API. Credenciais locais não devem ser versionadas.

## Antes do Pull Request

Execute a mesma validação utilizada pela integração contínua:

```bash
make quality
make build
make test
```

O Pull Request deve explicar contexto, decisões e forma de validação. Alterações de comportamento precisam de testes proporcionais ao risco e atualização da documentação relacionada.

## Critérios de revisão

- dependências entram por inicializador e respeitam os limites entre camadas;
- callbacks e estado de apresentação observam seus contratos de fila;
- closures assíncronas e delegates não introduzem ciclos de retenção;
- erros são observáveis e opcionais são tratados na fronteira adequada;
- textos, cores, tipografia, dimensões e espaçamentos reutilizáveis usam os recursos compartilhados;
- componentes interativos preservam Dynamic Type, VoiceOver e área mínima de toque;
- a alteração não adiciona warnings, credenciais ou artefatos gerados localmente.
