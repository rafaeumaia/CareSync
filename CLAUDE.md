# CLAUDE.md — Regras Permanentes do Projeto CareSync

Este arquivo define as regras fixas de como este projeto deve ser conduzido. Estas regras têm prioridade sobre qualquer decisão pontual e devem ser respeitadas em todas as fases de implementação, a menos que o usuário autorize explicitamente uma exceção.

## Fonte de verdade

- O projeto Figma Make (`https://www.figma.com/make/RSl21O8igw0fGB387pa6dj/Visual-Identity-and-Navigation`) é a **fonte de verdade visual e funcional** do CareSync. Toda decisão de layout, fluxo de navegação, cores, tipografia, espaçamento e comportamento de UI deve ser validada contra esse projeto (ou contra `PROJECT_SPEC.md`, que documenta o que foi extraído dele).
- **Não alterar o projeto original do Figma.** Ele é somente leitura para fins de referência — nenhuma edição, geração de design ou escrita nele.

## Stack final

- **Frontend final:** Flutter (Android e iOS).
- **Backend final:** Django + Django REST Framework.
- **Banco de dados final:** PostgreSQL.

## Uso do código React do Figma Make

- **Não utilizar o código React do Figma Make como frontend final.** Ele não deve ser portado, copiado ou empacotado como parte do app Flutter.
- O código React **pode ser consultado apenas para entender design, comportamento e lógica** (ex.: quais campos um formulário tem, o que é validado, o que é apenas mock, como um fluxo de navegação funciona). Ele é referência de leitura, não fonte de código.

## Fidelidade visual

- A reprodução em Flutter deve ser **visualmente o mais fiel possível** ao Figma Make: mesmas cores, tipografia, espaçamentos, raios de borda, sombras e iconografia documentados em `PROJECT_SPEC.md`.
- **Corrigir inconsistências técnicas do protótipo sem alterar sua identidade visual.** Exemplos de inconsistências já identificadas: cores hardcoded em vez de tokens de tema (quebra dark mode em algumas telas), botões sem ação (mock), telas sem ponto de entrada na navegação (Configurações e Chat), formulários não controlados. Essas inconsistências devem ser corrigidas na implementação Flutter (ex.: usar tokens de tema consistentemente, dar navegação real a todas as telas, remover/implementar handlers vazios), mas sem mudar a aparência, cores, textos ou identidade visual definidos pelo Figma.

## Escopo de funcionalidades

- **Não inventar funcionalidades que não existam no Figma sem autorização.** Qualquer funcionalidade nova, tela nova, ou fluxo não presente no protótipo deve ser proposta e aprovada antes de ser implementada.

## Arquitetura Flutter

- Utilizar **arquitetura organizada e feature-first** (uma pasta por feature/tela ou domínio, com separação interna de apresentação, estado, domínio e dados).
- **Componentes visuais repetidos devem ser reutilizáveis** (ex.: header padrão, bottom navigation, cards, botões de ação flutuante) — não duplicar UI entre telas.
- **Preparar a camada de dados para consumir futuramente a API Django** — repositórios e contratos de dados devem ser desenhados pensando em uma implementação futura via HTTP/REST, mesmo que a implementação inicial use dados em memória/mock.
- **Não implementar Hive, Drift ou outro banco local como fonte principal dos dados.** Persistência local, se necessária, é secundária (cache/preferências), nunca a fonte principal de verdade dos dados — a fonte principal será a API Django + PostgreSQL.

## Plataformas suportadas

- Android e iOS.
