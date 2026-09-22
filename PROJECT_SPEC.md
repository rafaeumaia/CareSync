# PROJECT_SPEC.md — Especificação do CareSync

Documento gerado a partir da análise do protótipo Figma Make (`Visual Identity and Navigation`, fileKey `RSl21O8igw0fGB387pa6dj`), incluindo leitura do código-fonte React exportado pelo Figma Make (React 18 + Vite + Tailwind v4 + shadcn/radix-ui + lucide-react + recharts + sonner + motion). Este documento é a referência funcional/visual para a implementação em Flutter + Django, conforme as regras de `CLAUDE.md`.

---

## 1. Objetivo do CareSync

CareSync é um aplicativo mobile de **organização do cuidado de idosos/pacientes**, voltado a cuidadores (profissionais, familiares ou responsáveis). O slogan do app é "Cuidar com organização". Seus objetivos centrais, conforme o fluxo de onboarding e as telas do protótipo, são:

- Organizar a rotina de cuidado: consultas médicas, medicações e horários.
- Monitorar indicadores de saúde (pressão, glicemia, temperatura, peso) e alimentação/hidratação.
- Manter um histórico e gerar relatórios (PDF) sobre a saúde do paciente.
- Centralizar dados do perfil do idoso/paciente (condições de saúde, contatos de emergência, observações médicas).
- Conectar cuidadores entre si (chat) para compartilhar informações do dia a dia do paciente.
- Suportar diferentes perfis de usuário no cadastro: Cuidador Profissional, Cuidador Familiar e Responsável.

---

## 2. As 13 telas encontradas

| # | Tela | Arquivo de origem | Screen id | Categoria |
|---|---|---|---|---|
| 1 | Splash | `SplashScreen.tsx` | `splash` | Inicial |
| 2 | Onboarding | `OnboardingScreen.tsx` | `onboarding` | Inicial (3 slides) |
| 3 | Login | `LoginScreen.tsx` | `login` | Autenticação |
| 4 | Cadastro (Signup) | `SignupScreen.tsx` | `signup` | Autenticação (3 etapas) |
| 5 | Dashboard (Início) | `Dashboard.tsx` | `dashboard` | Principal / aba do BottomNav |
| 6 | Consultas (Agenda) | `ConsultasScreen.tsx` | `consultas` | Principal / aba do BottomNav |
| 7 | Medicações | `MedicacoesScreen.tsx` | `medicacoes` | Secundária |
| 8 | Indicadores (Saúde) | `IndicadoresScreen.tsx` | `indicadores` | Principal / aba do BottomNav |
| 9 | Alimentação | `AlimentacaoScreen.tsx` | `alimentacao` | Secundária |
| 10 | Relatórios | `RelatoriosScreen.tsx` | `relatorios` | Principal / aba do BottomNav |
| 11 | Perfil (do idoso) | `PerfilScreen.tsx` | `perfil` | Secundária |
| 12 | Configurações | `ConfiguracoesScreen.tsx` | `configuracoes` | Secundária (**órfã**, ver seção 12) |
| 13 | Chat | `ChatScreen.tsx` | `chat` | Secundária (**órfã**, ver seção 12) |

### Detalhamento por tela

**1. Splash** — Tela de abertura com logo (ícone de coração animado, pulsando) e nome "CareSync". Fundo em gradiente azul (`#2F80ED` → `#56CCF2`). Some automaticamente após 2 segundos.

**2. Onboarding** — 3 slides com ícone, título e descrição, indicador de progresso (dots), botões "Próximo"/"Começar" e "Pular". Conteúdo dos slides:
1. Calendar — "Organize a rotina com facilidade".
2. Heart — "Monitore consultas, medicamentos e saúde".
3. Users — "Conecte-se à família e garanta bem-estar".

**3. Login** — Logo + título + subtítulo, formulário com E-mail e Senha, link "Esqueci minha senha" (sem ação), botão "Entrar", link para "Criar conta".

**4. Cadastro** — Fluxo de 3 etapas:
   - Etapa "tipo": escolha entre Cuidador Profissional, Cuidador Familiar, Responsável (cards clicáveis).
   - Etapa "formulário": Nome completo, E-mail, Telefone, Senha, Confirmar senha, checkbox de aceite dos termos (botão só habilita com checkbox marcado).
   - Etapa "sucesso": modal de confirmação com botão "Ir para o login".

**5. Dashboard** — Header padrão (saudação + notificações + avatar), data do dia, 2 cards de acesso rápido (Próxima consulta / Medicações de hoje), card "Tarefas do Dia" (lista estática com medicação/consulta/indicador do dia), grade de 3 ações rápidas (Indicadores, Alimentação, Relatórios), FAB (+) que leva a Consultas, BottomNav.

**6. Consultas** — Header padrão, abas "Próximas"/"Passadas" (filtradas por data real), cards de consulta (médico, especialidade, data/hora, local, observações), ícones de editar (sem ação) e excluir (funcional), FAB (+) abre dialog para cadastrar nova consulta (médico, especialidade, data, horário, local, observações), estado vazio ilustrado, BottomNav.

**7. Medicações** — Header customizado verde com seta de voltar, lista de medicações (nome, dosagem, frequência, horário, badge "Tomado"), botão "Marcar como tomado" por item, card informativo sobre notificações, FAB (+) abre dialog para adicionar medicação (nome, dosagem, frequência via select, horário), BottomNav.

**8. Indicadores** — Header padrão, grid de 4 cards de indicadores (Pressão Arterial, Glicemia, Temperatura, Peso) com valor atual e cor própria, gráfico de linha de Pressão Arterial (7 dias, sistólica/diastólica) e de Glicemia (7 dias) via biblioteca de gráficos, botão "Gerar Relatório Completo (PDF)", FAB (+) abre dialog de seleção de indicador + valor + data/hora, BottomNav.

**9. Alimentação** — Header customizado verde com seta de voltar, card "Refeições do Dia" (café, almoço, lanche, jantar — com botão "Confirmar refeição"), card de Hidratação (barra de progresso + botões +200ml/+300ml/+500ml), card de Recomendações (lista com emoji), card "Planejamento Semanal" (calendário 7 dias com status completo/parcial/incompleto), FAB (+) abre dialog para adicionar refeição, BottomNav.

**10. Relatórios** — Header padrão, abas "Todos"/"Saúde"/"Alimentação", lista de relatórios (título, categoria com badge colorida, tamanho, data) com botões "Baixar" e "Compartilhar", BottomNav.

**11. Perfil** — Header customizado com gradiente azul, avatar grande, nome e idade, data de nascimento; cards de Endereço, Condições de Saúde, Contatos de Emergência (com link `tel:` funcional para ligar), Observações Médicas; botão "Editar Informações" abre dialog de edição (nome, data de nascimento, endereço, observações), BottomNav.

**12. Configurações** — Header customizado azul com seta de voltar, grupos "Conta" (Alterar senha), "Preferências" (Notificações — toggle, Tema escuro — toggle funcional, Idioma), "Suporte" (Ajuda/FAQ), botão "Sair" com confirmação (AlertDialog), rodapé com versão do app, BottomNav.

**13. Chat** — Header customizado azul com avatar do contato, status "Online", menu de opções (sem ação); lista de mensagens (bolhas azul para usuário, brancas para o outro), campo de digitação com botões de anexo/imagem (sem ação) e botão de enviar. **Sem BottomNav.**

---

## 3. Mapa de navegação

```
splash --(timer automático, 2s)--> onboarding
onboarding --(pular OU concluir 3º slide)--> login

login --(submeter formulário)--> dashboard   [autenticado = true]
login --(link "criar conta")--> signup

signup [etapa tipo] --(selecionar perfil)--> signup [etapa formulário]
signup [etapa formulário] --(voltar)--> signup [etapa tipo]
signup [etapa formulário] --(submeter)--> signup [etapa sucesso, modal]
signup [etapa sucesso] --(ir para login)--> login
signup --(link "já tenho conta")--> login

dashboard <--(BottomNav)--> consultas | indicadores | relatorios
dashboard --(avatar do Header)--> perfil
dashboard --(card "Próxima consulta")--> consultas
dashboard --(card "Medicações")--> medicacoes
dashboard --(FAB +)--> consultas
dashboard --(ação rápida "Indicadores")--> indicadores
dashboard --(ação rápida "Alimentação")--> alimentacao
dashboard --(ação rápida "Relatórios")--> relatorios

Header (presente em dashboard, consultas, indicadores, relatorios)
  --(avatar)--> perfil

Telas com header customizado próprio (medicacoes, alimentacao, perfil, configuracoes)
  --(seta de voltar)--> dashboard

configuracoes --(botão "Sair" + confirmação)--> login  [autenticado = false]
```

**Notas sobre o mapa:**
- O BottomNav tem exatamente 4 itens fixos: Início (`dashboard`), Agenda (`consultas`), Saúde (`indicadores`), Relatórios (`relatorios`). Aparece em todas as telas principais e na maioria das secundárias, exceto `chat`.
- `medicacoes`, `alimentacao`, `perfil`, `configuracoes` usam um header colorido próprio com seta de "voltar para dashboard", em vez do `Header` padrão — ou seja, são navegadas como "sub-telas", não como abas.
- **`configuracoes` e `chat` não possuem nenhum ponto de entrada na UI** — nenhum botão, ícone ou link do protótipo navega para elas. Só são alcançáveis manipulando o estado diretamente (ver seção 12).
- Não existe um mecanismo real de proteção de rota: o estado `isAuthenticated` é setado no login, mas nenhuma tela verifica esse estado antes de ser exibida.

---

## 4. Componentes compartilhados

| Componente | Onde aparece | Descrição |
|---|---|---|
| **Header** (padrão) | dashboard, consultas, indicadores, relatorios | Saudação "Olá, {nome} 👋", ícone de notificações (sino, com badge se houver notificações — decorativo, sem ação), avatar (iniciais do nome) clicável → navega para perfil. |
| **BottomNav** | dashboard, consultas, medicacoes, indicadores, alimentacao, relatorios, perfil, configuracoes | Grid de 4 itens fixos (Início, Agenda, Saúde, Relatórios) com ícone + label, cor azul quando ativo. |
| **Header colorido com voltar** | medicacoes (verde), alimentacao (verde), perfil (gradiente azul), configuracoes (azul), chat (azul) | Bloco de cor sólida/gradiente com cantos inferiores arredondados, seta de voltar + título; padrão repetido mas implementado de forma independente em cada tela (candidato a componentização). |
| **FAB (botão flutuante circular)** | dashboard, consultas, medicacoes, indicadores, alimentacao | Botão circular `+` fixo no canto inferior direito; ação varia por tela (abrir dialog de cadastro, ou navegar, no caso do dashboard). |
| **Card padrão** | quase todas as telas | Fundo branco, sem borda, sombra leve, cantos arredondados (12px). |
| **Dialog / formulário modal** | consultas, medicacoes, indicadores, alimentacao, perfil, signup (sucesso) | Modal centralizado com título, campos de formulário e botão de ação principal. |
| **AlertDialog (confirmação)** | configuracoes (logout) | Modal de confirmação com cancelar/confirmar. |
| **Badge** | dashboard, medicacoes, alimentacao, relatorios | Etiqueta colorida pequena (status "Tomado", categoria de relatório, check de conclusão). |
| **Tabs** | consultas ("Próximas"/"Passadas"), relatorios ("Todos"/"Saúde"/"Alimentação") | Navegação por abas dentro da tela. |
| **Avatar** | Header, perfil, chat | Círculo com iniciais do nome (fallback), sem foto real. |
| **Toast/notificação (sonner)** | medicacoes, indicadores, alimentacao, relatorios, perfil | Notificação temporária de sucesso ao concluir uma ação. |
| **Progress bar** | alimentacao (hidratação) | Barra de progresso linear. |
| **Empty state** | consultas (sem consultas agendadas), medicacoes (sem medicação cadastrada) | Ícone + texto centralizado quando a lista está vazia. |

**Componentes de UI de terceiros presentes no repositório mas NÃO usados em nenhuma das 13 telas** (parte do template shadcn, não fazem parte do design system efetivo do CareSync): accordion, breadcrumb, calendar, carousel, chart (wrapper), command, context-menu, drawer, dropdown-menu, hover-card, input-otp, menubar, navigation-menu, pagination, popover, radio-group, resizable, sheet, sidebar, skeleton, slider, table, toggle, toggle-group, tooltip.

---

## 5. Design system

### 5.1 Cores

Tokens definidos em `globals.css` (tema claro e escuro):

| Token | Claro | Escuro | Uso típico |
|---|---|---|---|
| `background` | `#EAF6FF` | `#121212` | Fundo geral do app |
| `foreground` | `#333333` | `#E0E0E0` | Texto principal |
| `card` | `#FFFFFF` | `#1E1E1E` | Fundo de cards/superfícies |
| `card-foreground` | `#333333` | `#E0E0E0` | Texto sobre card |
| `primary` | `#2F80ED` | `#4A90E2` | Ações principais, links, ícones de destaque, botões primários |
| `primary-foreground` | `#FFFFFF` | `#FFFFFF` | Texto sobre primary |
| `secondary` / `muted` | `#F2F2F2` | `#2A2A2A` | Fundos secundários, itens de lista |
| `secondary-foreground` / `muted-foreground` | `#333333` / `#666666` | `#E0E0E0` / `#A0A0A0` | Texto secundário |
| `accent` | `#56CCF2` | `#56CCF2` | Avatar fallback, gradientes, destaques |
| `destructive` | `#EB5757` | `#EB5757` | Exclusão, alertas de saúde, indicador de notificação |
| `success` | `#27AE60` | `#27AE60` | Medicação tomada, refeição confirmada, ações de sucesso |
| `border` | `rgba(0,0,0,0.1)` | `rgba(255,255,255,0.1)` | Bordas |
| `input-background` | `#F2F2F2` | — | Fundo de campos de formulário |
| `ring` | `#2F80ED` | `#4A90E2` | Foco de campos |

**Cor adicional usada de forma ad hoc (não é token oficial):** `#F2994A` (laranja) — usada para indicador de "Temperatura", refeições pendentes, planejamento semanal parcial. Deve ser tratada como token adicional (`warning`) na implementação Flutter.

⚠️ **Inconsistência identificada:** as telas Login, Signup e Onboarding usam hex hardcoded (ex.: `bg-[#EAF6FF]`, `text-[#2F80ED]`) em vez dos tokens de tema — isso significa que essas telas não respeitam o dark mode no protótipo original. Ver seção 12.

### 5.2 Tipografia

- Fonte: **Inter** (pesos 400, 500, 600, 700), com fallback `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`.
- Tamanho base raiz: 16px.
- Escala de tamanho: `text-base` 16px / `text-lg` 18px / `text-xl` 20px / `text-2xl` 24px.
- Pesos: `font-weight-normal` 400 (corpo de texto, inputs), `font-weight-medium` 500 (labels, botões, headings padrão); vários headings usam `font-semibold` (600) explicitamente sobre o padrão (ex.: títulos de tela, nomes de destaque).
- Hierarquia observada: título de tela ~24px/semibold; título de card/seção ~18–20px/medium; corpo ~16px/normal; textos auxiliares (datas, legendas) ~14px, `muted-foreground`.

### 5.3 Espaçamento

- Container central: `max-width: 900px`, centralizado (`app-container`) — layout pensado para ficar bem também em telas maiores/tablet.
- Padding horizontal de conteúdo: `16px` (mobile) → `24px` (≥768px, breakpoint tablet).
- Espaçamento entre cards/seções: `12px` (mobile) → `16px` (≥768px).
- Espaçamento interno de grids de ações/indicadores: `gap-3` (12px) ou `gap-4` (16px).
- Padding inferior de tela para não sobrepor o BottomNav: `pb-20` (80px).

### 5.4 Border radius

- Raio base do design system: `0.75rem` (12px) — usado em cards (`rounded-xl`).
- Botões: `rounded-md` (raio menor, ~6–8px).
- Avatares, badges de status, botões circulares (FAB): `rounded-full`.
- Headers coloridos de tela (medicacoes, alimentacao, perfil, configuracoes): cantos inferiores `rounded-b-3xl` (24px).
- Bolhas de chat: `rounded-2xl`, com o canto voltado para quem enviou "puxado" (`rounded-br-sm` para o usuário, `rounded-bl-sm` para o outro).

### 5.5 Sombras

- Sombra padrão única, usada de forma consistente em quase todos os elementos elevados (cards, Header, BottomNav): `0px 2px 8px rgba(0, 0, 0, 0.05)`.
- BottomNav usa a mesma sombra invertida (`0px -2px 8px rgba(0,0,0,0.05)`), por estar fixado na parte inferior.
- FAB usa sombra mais acentuada (`shadow-lg`) para reforçar elevação acima do conteúdo.

### 5.6 Ícones

- Biblioteca: **lucide-react** (ícones de linha, consistentes).
- Tamanhos observados: 16px, 20px, 24px (mais comuns), até 28–32px em destaques (ex.: ícone de coração na splash/login) e 64px em estados vazios.
- Cor sempre semântica por domínio: azul (`primary`) para itens gerais/consultas, verde (`success`) para medicação/confirmações, vermelho (`destructive`) para saúde/exclusão, laranja para alimentação/pendências.
- Padrão visual recorrente: ícone dentro de um círculo com fundo na cor do domínio em opacidade baixa (ex.: `bg-[#2F80ED]/10`) — usado em cards, ações rápidas, itens de configuração, mensagens informativas.

---

## 6. Comportamentos gerais observados

- **Formulários:** a maioria usa componentes controlados (`value` + `onChange` para estado local em React), validação apenas via atributos HTML5 (`required`, `type`), sem validação customizada de negócio (ex.: não valida formato de e-mail/telefone, não compara senha/confirmação).
- **Botões primários:** preenchidos na cor do domínio da tela (azul para a maioria, verde para medicações/alimentação), altura padrão 48px (`h-12`) em formulários, com estado `disabled` quando campos obrigatórios não preenchidos (ex.: cadastro de medicação, aceite de termos no cadastro).
- **Menus/abas:** implementadas com `Tabs`, filtragem client-side simples sobre arrays em memória.
- **Feedback de ação:** a maioria das ações de "adicionar"/"confirmar" dispara um toast de sucesso (biblioteca sonner), sem loading state, sem tratamento de erro (não há cenário de erro simulado no protótipo).
- **Dark mode:** existe e é funcional (alternável em Configurações), mas aplicado de forma inconsistente (ver seção 12).

---

## 7. Funcionalidades REAIS no protótipo (lógica implementada, mesmo que só em memória)

- Timer de splash → onboarding (2s).
- Carrossel de onboarding com navegação por slide e "pular".
- Cadastro: fluxo de 3 etapas com estado de wizard real (tipo → formulário → sucesso).
- **Consultas:** adicionar nova consulta (formulário → lista), excluir consulta, filtro real "Próximas"/"Passadas" por comparação de datas.
- **Medicações:** adicionar nova medicação, alternar status "tomado"/"não tomado" com feedback (toast).
- **Alimentação:** alternar refeição como confirmada (toast), somar hidratação por botões de quantidade (capado na meta diária), progresso recalculado dinamicamente.
- **Relatórios:** filtro real por categoria via abas.
- **Perfil:** edição dos campos do perfil reflete no estado imediatamente (embora sem um fluxo formal de "descartar alterações").
- **Contato de emergência:** link `tel:` funcional para ligação direta.
- **Configurações:** alternância de tema claro/escuro realmente propaga para o app inteiro; logout com confirmação realmente desautentica e volta para o login.
- **Chat:** envio de mensagens real (adiciona à lista local, com hora atual), Enter para enviar.

## 8. Funcionalidades que são APENAS MOCK (sem efeito real ou sem persistência)

- **Login:** aceita qualquer e-mail/senha, não autentica de fato; "Esqueci minha senha" sem ação.
- **Cadastro:** não valida senha/confirmação, não envia dados a lugar nenhum; qualquer envio é tratado como sucesso.
- **Dashboard:** lista "Tarefas do Dia" é estática (array fixo), não editável, não reflete dados reais de outras telas.
- **Consultas:** ícone de "editar" sem nenhuma ação (`onClick` ausente).
- **Medicações:** texto promete "notificações automáticas nos horários programados", mas nenhum agendamento é implementado.
- **Indicadores:** gráficos (pressão, glicemia) usam dados 100% estáticos; o dialog "Adicionar Indicador" mostra toast de sucesso mas **não adiciona o valor a lista/gráfico nenhum**; botão "Gerar Relatório Completo (PDF)" apenas mostra um toast, não gera arquivo algum.
- **Alimentação:** "Planejamento Semanal" é um calendário com status fixo, não conectado às refeições reais do dia; dialog "Adicionar Refeição" tem campos não controlados e o envio não insere a refeição na lista (só toast).
- **Relatórios:** lista de relatórios é estática (fixture); botões "Baixar" e "Compartilhar" apenas disparam toast, sem download/compartilhamento real.
- **Configurações:** toggle de "Notificações" é decorativo (estado fixo `true`, sem `onChange`); itens "Alterar senha", "Idioma" e "Ajuda/FAQ" têm handler vazio (`onClick: () => {}`), não abrem nada.
- **Chat:** botões de anexo, imagem e menu de opções (3 pontos) sem ação; conversa é fixture local, sem envio/recepção real; não há indicação de "digitando..." nem entrega real.
- **Header:** ícone de notificações (sino) é puramente decorativo, sem lista de notificações associada.

---

## 9. Problemas encontrados no protótipo

1. **Telas órfãs:** `configuracoes` e `chat` existem no código mas não são alcançáveis por nenhum botão/link da UI atual.
2. **Botões mortos:** editar consulta, "Esqueci minha senha", notificações (sino do Header), anexo/imagem/menu do chat, "Alterar senha"/"Idioma"/"Ajuda-FAQ" em Configurações, toggle de notificações em Configurações.
3. **Inconsistência de tema:** Login, Signup e Onboarding usam cores hardcoded em vez de tokens — não respeitam dark mode.
4. **Padrão de header duplicado e não componentizado:** cada tela com header colorido (medicacoes, alimentacao, perfil, configuracoes) reimplementa o mesmo padrão visual de forma independente, com pequenas variações de cor/gradiente.
5. **FAB com comportamento inconsistente entre telas:** no Dashboard o FAB navega para outra tela (Consultas); nas demais telas ele abre um dialog de cadastro — mesmo componente visual, semânticas diferentes.
6. **Sem tratamento de erro/loading:** nenhuma tela simula estado de carregamento, erro de rede ou validação de negócio além do HTML5 básico.
7. **Falta de persistência:** todo o estado é local ao componente/tela (React `useState`); ao trocar de tela e voltar, alguns dados cadastrados no fluxo permanecem (por estarem no componente pai `App`/tela), mas nada sobrevive a um reload — comportamento esperado de protótipo, mas que reforça a necessidade da camada de API real no Flutter.
8. **Ausência de guarda de rota:** o estado `isAuthenticated` não é verificado por nenhuma tela antes de renderizar.
9. **Formulário de "Adicionar Refeição" com campos não controlados**, inconsistente com os demais formulários do app (que são todos controlados).

---

## 10. Arquitetura Flutter recomendada

Conforme `CLAUDE.md`, arquitetura **feature-first**, organizada por domínio:

```
lib/
  core/
    theme/       — ColorScheme (claro/escuro) a partir dos tokens da seção 5.1,
                   TextTheme (Inter), radius e sombra padrão compartilhados,
                   extensão de cores semânticas extras (ex.: warning).
    router/      — definição de rotas (uma por Screen id da seção 2),
                   shell de navegação para as 4 abas do BottomNav
                   (dashboard, consultas, indicadores, relatorios),
                   rotas "push" para as telas secundárias
                   (medicacoes, alimentacao, perfil, configuracoes, chat) —
                   com entrada visível de verdade para configuracoes e chat
                   (correção do problema #1 da seção 9).
    widgets/     — componentes reutilizáveis: AppHeader (padrão),
                   ColoredScreenHeader (padrão dos headers coloridos com voltar),
                   BottomNavShell, PrimaryFab, AppCard, EmptyState, etc.
  features/
    auth/            (splash, onboarding, login, signup)
    dashboard/
    consultas/
    medicacoes/
    indicadores/
    alimentacao/
    relatorios/
    perfil/
    configuracoes/
    chat/
      presentation/  — telas e widgets específicos da feature
      state/         — gerenciamento de estado (providers/notifiers)
      domain/        — modelos de dados da feature
      data/          — contrato de repositório + implementação
                        (inicialmente em memória/mock, preparada para API)
```

- **Gerenciamento de estado:** recomenda-se Riverpod pela simplicidade e testabilidade dado o volume de telas com listas e formulários CRUD-like.
- **Gráficos:** substituir recharts por uma biblioteca de gráficos Flutter equivalente (ex.: fl_chart) para os gráficos de Pressão Arterial e Glicemia.
- **Notificações locais:** já que o texto do protótipo promete lembretes de medicação (hoje não implementados), prever essa capacidade na camada de domínio desde o início, mesmo que a implementação venha depois.
- **Camada de dados:** repositórios com interface única por domínio (ex.: `ConsultaRepository`, `MedicacaoRepository`), implementação inicial mock/em memória, pronta para ser substituída por uma implementação HTTP consumindo a API Django — sem uso de banco local (Hive/Drift) como fonte principal, conforme `CLAUDE.md`.
- **Plataformas:** configuração de build para Android e iOS desde o início do projeto.

---

## 11. Funcionalidades que precisarão do Django (backend)

Tudo que hoje é mock ou apenas em memória (seção 8) precisará de suporte real no backend:

- **Autenticação e sessão:** cadastro (com tipo de perfil), login com validação real, recuperação de senha ("Esqueci minha senha"), logout, alteração de senha.
- **Consultas:** CRUD completo (criar, listar, editar — hoje ausente no protótipo, mas necessário —, excluir), com filtro por data (passadas/futuras).
- **Medicações:** CRUD completo, marcação de "tomado" com histórico/horário real, agendamento de notificações/lembretes.
- **Indicadores de saúde:** registro de novas medições (pressão, glicemia, temperatura, peso, etc.), histórico real para alimentar os gráficos, geração real de relatório em PDF.
- **Alimentação:** registro real de refeições (com persistência, substituindo o formulário não controlado do protótipo), registro de hidratação, cálculo real do "Planejamento Semanal" a partir das refeições confirmadas.
- **Relatórios:** geração e armazenamento real de relatórios, download e compartilhamento (arquivo real, não apenas toast).
- **Perfil do paciente/idoso:** persistência de dados cadastrais, condições de saúde, contatos de emergência, observações médicas, histórico de edições.
- **Configurações:** persistência de preferências (tema, idioma, notificações) por usuário; fluxo real de "Ajuda/FAQ".
- **Chat:** mensageria real entre cuidadores (envio/recebimento, histórico, múltiplas conversas, indicação de leitura/online), suporte a anexos e imagens.
- **Notificações:** central de notificações real para o sino do Header (hoje decorativo).
- **Multiusuário/perfis:** suporte real aos três tipos de usuário definidos no cadastro (Cuidador Profissional, Cuidador Familiar, Responsável), possivelmente com permissões diferentes e vínculo a um ou mais pacientes/idosos.

## 12. Entidades de dados que provavelmente existirão no backend

Modelagem preliminar (a refinar durante o design da API), inferida das telas e dos dados mockados:

- **User** — id, nome, e-mail, senha (hash), telefone, tipo de usuário (`profissional` | `familiar` | `responsavel`), avatar/iniciais, preferências (tema, idioma, notificações habilitadas), data de criação.
- **Paciente** (idoso cuidado) — id, nome, idade/data de nascimento, endereço, observações médicas, avatar, um ou mais `User` vinculados como cuidadores (relação N:N com papel).
- **CondicaoSaude** — id, paciente (FK), descrição (ex.: "Hipertensão", "Diabetes tipo 2").
- **ContatoEmergencia** — id, paciente (FK), nome, telefone, parentesco/relação.
- **Consulta** — id, paciente (FK), médico, especialidade, data, horário, local, observações, status (futura/realizada/cancelada), criado por (FK User).
- **Medicacao** — id, paciente (FK), nome, dosagem, frequência, horário(s), data de início/fim (opcional), ativo (bool).
- **RegistroMedicacao** — id, medicacao (FK), data/hora prevista, data/hora em que foi tomada (nullable), status (tomado/pendente/atrasado) — histórico diário separado do cadastro da medicação.
- **IndicadorSaude** — id, paciente (FK), tipo (`pressao` | `glicemia` | `temperatura` | `peso` | outro), valor(es) (ex.: sistólica/diastólica para pressão), unidade, data/hora do registro, registrado por (FK User).
- **Refeicao** — id, paciente (FK), tipo (café/almoço/lanche/jantar ou customizado), horário planejado, descrição, status (confirmada/pendente), data.
- **RegistroHidratacao** — id, paciente (FK), quantidade (ml), data/hora.
- **MetaHidratacao** — id, paciente (FK), meta diária (ml).
- **Relatorio** — id, paciente (FK), título, categoria (Geral/Consultas/Medicamentos/Indicadores/Alimentação), arquivo (PDF), tamanho, data de geração, gerado por (FK User).
- **Notificacao** — id, usuário destinatário (FK), título, mensagem, tipo, lida (bool), data de criação — para alimentar o sino do Header e os lembretes de medicação.
- **Conversa** — id, participantes (FK User, N:N), paciente relacionado (FK, opcional).
- **Mensagem** — id, conversa (FK), remetente (FK User), texto, anexo (opcional), data/hora, lida (bool).

---

*Este documento reflete exclusivamente o que foi observado no protótipo Figma Make na data de sua geração. Qualquer funcionalidade adicional deve ser proposta e autorizada antes de ser incorporada ao escopo, conforme `CLAUDE.md`.*
