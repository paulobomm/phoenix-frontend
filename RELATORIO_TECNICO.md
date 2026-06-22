# Relatório Técnico — Phoenix (DMaaS para Roblox)

**Data:** 22/06/2026
**Escopo:** Backend (`phoenix-2`) + Frontend (`phoenix-frontend`: mobile Flutter + web Next.js)

> Documento único e completo: reúne a descrição técnica do **backend** e do **frontend** e, ao final, a **verificação dos requisitos** exigidos pela atividade acadêmica (MVVM, padrão adicional, integração com API e persistência local).

---

## 1. Visão geral do produto

**Phoenix** é uma plataforma de **Data-Management-as-a-Service (DMaaS)** voltada ao ecossistema Roblox. O desenvolvedor conecta seu jogo via **Universe ID + Open Cloud API Key** e a plataforma:

1. **Proteção automática de dados** — snapshots agendados via Open Cloud, com deduplicação inteligente.
2. **Auto-descoberta** — varre os DataStores do jogo e infere a estrutura dos dados a partir de amostras (setup "no-code").
3. **Recuperação granular** — restaura uma key específica, um DataStore inteiro ou o projeto todo para um estado anterior.
4. **Visualização administrativa** — transforma o JSON cru dos DataStores num dashboard navegável e editável.

O objetivo é substituir os "consoles in-game" e scripts improvisados que a maioria dos estúdios Roblox usa hoje, oferecendo um hub centralizado com backup, auditoria e resiliência.

---

## 2. Arquitetura macro

```
┌──────────────────────┐        ┌──────────────────────┐
│   App Mobile          │        │    App Web            │
│   Flutter + Riverpod  │        │    Next.js + Zustand  │
└──────────┬───────────┘        └──────────┬───────────┘
           │  HTTP /v1 (Bearer JWT)         │  /api/* → rewrite → /v1
           └───────────────┬────────────────┘
                           ▼
        ┌───────────────────────────────────────────┐
        │      7 microsserviços NestJS (REST)        │
        │  iam · projects · discovery · snapshots ·  │
        │       restore · admin-data · audit         │
        └───────────────┬───────────────────────────┘
                        │ eventos de domínio (RabbitMQ direct)
        ┌───────────────┴───────────────────────────┐
        │  Postgres 16 (1 DB por serviço)            │
        │  MinIO / S3 (blobs de snapshot)            │
        └────────────────────────────────────────────┘
```

**Decisão central:** microsserviços por *bounded context*, cada um com banco próprio e comunicação assíncrona via eventos. Os apps cliente falam HTTP direto com cada serviço (não há API gateway).

---

## 3. Backend (`phoenix-2`)

### 3.1 Stack

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Runtime | Node.js 22 | LTS moderno |
| Linguagem | TypeScript 5.7 (strict, decorators) | Tipagem forte + metadados para DI do Nest |
| Framework | NestJS 11 | DI, módulos, guards, Swagger nativo |
| ORM | Drizzle ORM 0.45 + `pg` | SQL-first, migrations versionadas, leve |
| Banco | PostgreSQL 16 (1 por serviço) | Isolamento estrito por contexto |
| Mensageria | RabbitMQ 3 (`amqplib`) | Eventos de domínio duráveis |
| Object storage | AWS S3 SDK + MinIO (dev) | Blobs grandes fora do banco |
| Auth | JWT (`@nestjs/jwt`) + bcryptjs | Stateless, mesmo segredo entre serviços |
| Cripto | AES-256-GCM (`node:crypto`) | API keys do Roblox cifradas em repouso |
| Lint/format | Biome 2 | Substitui ESLint + Prettier num só tool |
| Testes | Jest 30 + ts-jest | Unitários em serviços/cripto/rate-limit |

### 3.2 Os 7 serviços

| Serviço | Porta | Banco | Responsabilidade |
|---|---|---|---|
| **iam** | 5001 | `phoenix_iam` | Usuários, login JWT, permissões. Seed de admin no boot. Emite `iam.user.*`. |
| **projects** | 5002 | `phoenix_projects` | Conexões de jogos Roblox (universeId, **API key cifrada**, status). Emite `project.*`. |
| **discovery** | 5003 | `phoenix_discovery` | Varre DataStores via Open Cloud, infere schema por amostragem. Consome `project.*`; emite `datastore.*`, `schema.*`. |
| **snapshots** | 5004 | `phoenix_snapshots` | Scheduler (cron) + worker. Manifests + blobs deduplicados. Emite `snapshot.*`. |
| **restore** | 5005 | `phoenix_restore` | Jobs de recuperação com *dry-run* + aprovação. Consome `snapshot.*`. |
| **admin-data** | 5006 | `phoenix_admin_data` | Leitura/edição ao vivo do DataStore via Open Cloud. Emite `data.edited`. |
| **audit** | 5007 | `phoenix_audit` | Log append-only; consome todos os eventos e indexa para o dashboard. |

### 3.3 Padrão interno (DDD-lite / hexagonal)

Cada feature dentro de um serviço segue a mesma divisão em camadas:

```
modules/<contexto>/<feature>/
  application/
    dto/         # shapes de request/response (class-validator)
    services/    # casos de uso + *MessagingService + *ConsumerService
  domain/
    models/      # entidades puras (sem Nest/Drizzle)
    repositories/# INTERFACES + token Symbol de DI
  infra/
    controllers/ # HTTP fino, só delega
    database/    # schemas Drizzle (pgTable)
    repositories/# implementação Drizzle da interface
  <feature>.module.ts
```

**Regras que sustentam a manutenibilidade:**
- Controllers nunca tocam o banco — dependem só de application services.
- Application services nunca tocam Drizzle — dependem da **interface** do repositório (injetada por `Symbol`).
- Entidades de domínio são *framework-free*.
- Adicionar um serviço = copiar a pasta, trocar schemas, registrar eventos/permissões no `shared/`.

### 3.4 Pasta `shared/`

Pacote TypeScript (via aliases `@shared/*`) consumido por todos os serviços. Contém o que **deve** ser idêntico entre eles:
- `bootstrap-http-app.ts` — `main.ts` comum: prefixo `/v1`, `ValidationPipe` (whitelist + transform), Swagger em `/docs`, esquema Bearer.
- Infra de banco (`drizzle.service.ts`), mensageria (`RabbitMQService`), auth (guards globais), cripto, cliente Roblox.
- **Contratos de eventos** (`contracts/events/*.enum.ts`) — nomes canônicos de exchange/routing key importados por publisher *e* consumer (nunca strings hardcoded).
- Enum de permissões (`resource:action`).

### 3.5 Comunicação assíncrona (RabbitMQ)

- Exchanges **direct + durable**; mensagens **persistentes** em JSON.
- Convenção: exchange `<contexto>.<recurso>.<verbo>.exchange`, routing key `<recurso>.<verbo>`, fila `<consumer>.<origem>-<recurso>.<verbo>.queue`.
- **Projeções locais:** quando um serviço precisa de dados de outro, ele assina os eventos e mantém uma cópia *read-only* (`upsert` por `external_id`). Nenhum serviço lê o banco de outro.
- **Idempotência:** handlers preferem `upsert`; delete é no-op se a linha já sumiu; não se assume ordem global entre exchanges.

### 3.6 Engenharia dos Snapshots (o coração técnico)

**Scheduler** (`snapshot-scheduler.service.ts`):
- Timer in-process de 60s; a cada minuto lista schedules habilitados, casa a expressão cron (UTC) e cria `SnapshotJob` com status `scheduled`, publicando o evento. Guard "fired this minute" evita disparo duplo.

**Worker** (`snapshot-worker.service.ts`):
- Faz *polling* dos jobs `scheduled`, percorre os DataStores do catálogo local, lê as entries via Open Cloud e, para cada valor:
  1. **Canonicaliza** o JSON (chaves ordenadas recursivamente, sem espaços incidentais) — `{a:1,b:2}` e `{b:2,a:1}` precisam gerar o mesmo hash.
  2. Calcula **SHA-256** → *content address*.
  3. Grava o blob em S3/MinIO **só se o hash ainda não existir** (`blob_index` com `refCount`); caso exista, deduplica.
- Chave do blob: `<projectId>/<hash[:2]>/<hash>` — o prefixo de 2 chars evita *hot partitions* no S3 e o escopo por projeto facilita exclusão.
- Estatísticas por job: datastores visitados, entries lidas, bytes gravados, blobs escritos vs. deduplicados.

> **Por que content-addressing?** Dados de jogador mudam pouco entre backups; armazenar por hash evita pagar storage por dados idênticos repetidos — o requisito de "dedup inteligente" do produto.

### 3.7 Integração Roblox Open Cloud

`RobloxCloudService` (em `shared/`) encapsula a API v2 (`apis.roblox.com/cloud/v2`):
- `listDataStores`, `listEntryKeys`, `getEntry`, `setEntry` (com `matchVersion` para concorrência otimista e `userIds` para rastreio GDPR).
- **Rate limiting** via token bucket por `(universeId, ação)`, ~60 req/min configurável; enfileira em 429.
- **Retry** exponencial em 5xx/rede (máx. 3); 429 faz backoff sem contar tentativa.
- API key buscada sob demanda por um cliente interno protegido por `PHOENIX_SERVICE_TOKEN`; **nunca** trafega em texto puro nem pelo RabbitMQ.

### 3.8 Segurança

- **JWT** com `permissions: string[]` no payload; `JwtAuthGuard` + `PermissionsGuard` globais (`APP_GUARD`).
- Decorators `@Public()`, `@RequirePermissions(...)`, `@CurrentUser()`.
- RBAC granular (`projects:read|write|delete`, `snapshots:create`, `restores:approve`, etc.).
- API keys do Roblox cifradas com **AES-256-GCM** em repouso (`api_key_cipher`).

### 3.9 Infra e deploy

- **Docker Compose** sobe Postgres 16, RabbitMQ 3, MinIO, Adminer e os 7 serviços.
- **`Dockerfile.service`** único, parametrizado por `SERVICE_NAME` (build-arg) — uma imagem por serviço.
- Migrations Drizzle pré-geradas em `services/<svc>/drizzle/`, aplicadas no boot.
- **Observação:** não há workflow de CI no repositório; a validação é via scripts (`validate:all`, `test:all`, `typecheck:all`).

---

## 4. Frontend (`phoenix-frontend`)

Monorepo com dois apps que consomem os mesmos 7 serviços. Cada app mantém **7 clientes HTTP** (um por serviço) — isolamento de baseURL, timeout e tratamento de erro.

### 4.1 App Mobile (Flutter)

**Stack:** Flutter 3 / Dart 3, **Riverpod** (estado), **go_router** (navegação), **dio** (HTTP), `flutter_secure_storage` (token cifrado), `shared_preferences` (cache de domínio), `fl_chart` (gráficos), `shimmer` (skeletons), `auth0_flutter` (OAuth opcional).

**Arquitetura feature-first + camadas** (`data` → `domain` → `presentation`):

```
lib/
  core/      network (7 Dios + auth interceptor), router (shell),
             theme, di, storage (LocalStorageService)
  features/  auth · games · datastores · snapshots · restore ·
             dashboard · audit · settings
  shared/    widgets reutilizáveis
```

**Padrões Riverpod usados:**
- `StateNotifierProvider` — `authProvider`, `gamesProvider` (listas mutáveis com métodos).
- `FutureProvider.autoDispose` — `snapshotsProvider`, `datastoresProvider`, `dashboardStatsProvider` (limpeza automática).
- `FutureProvider.autoDispose.family` — consultas parametrizadas (`snapshotDetailProvider(id)`, `snapshotCountProvider(projectId)`, `projectStorageSummaryProvider`).
- `StateProvider` — `selectedGameProvider` (jogo selecionado, sincronizado automaticamente quando a lista muda).

**Fluxo de dados:** `API → Repository (parse + erro) → Provider (cache/watch) → UI (loading/error/data)`. Models imutáveis com `fromJson` + getters computados (`formattedSize`, `isCompleted`).

**Navegação:** `GoRouter` com `redirect` reativo ao estado de auth e `ShellRoute` que troca **BottomNav (telefone) ↔ Sidebar (≥800px)**.

**Decisões de implementação relevantes** (do trabalho recente):
- O dashboard **agrega métricas reais** dos snapshots (contagem, storage, taxa de sucesso) percorrendo todos os jogos, porque o endpoint de analytics retornava zeros. A taxa de sucesso ignora `pending/running` no denominador.
- Tradução de `eventType` cru (`project.archived` → "Projeto arquivado") na atividade recente.
- Restore e comparação de snapshots passaram a usar **dados reais** do `snapshotsProvider` (antes mockados em Jan/2024).
- Parsing defensivo no `DataStoreModel` (datas nulas não derrubam mais a lista inteira).
- Planos: "Básico" (10 jogos, 5 GB, backups ilimitados até o teto, R$ 9,90/mês) e "Studio".
- **Persistência local:** token JWT em `flutter_secure_storage` + cache de jogos/seleção em `shared_preferences`, com restauração de sessão no boot (ver §8.4).

### 4.2 App Web (Next.js)

**Stack:** Next.js 16 / React 19, **Zustand** (estado), **Axios** (HTTP), **Tailwind CSS v4**. Filosofia mais enxuta que o mobile.

**Estrutura (App Router):**
```
src/app/
  (auth)/login
  dashboard/        layout com sidebar
    page · projects · games/[id] · datastores ·
    snapshots/[id]/restore · restore · historico · audit
  services/  api.ts (7 Axios) + *.service.ts por domínio
  hooks/     useProjects, useSnapshots (useState + useEffect)
  store/     auth.store, project.store (Zustand)
  types/     auth, project, snapshot
```

- **Proxy:** `next.config.ts` reescreve `/api/<svc>/*` → `http://localhost:<porta>/v1/*`, evitando CORS e centralizando os hosts.
- **Auth:** token em `localStorage` + cookie; `middleware.ts` protege rotas redirecionando para `/login`.
- Interceptors Axios injetam Bearer e tratam 401 → logout.

### 4.3 Paridade de features

| Feature | Mobile | Web |
|---|---|---|
| Auth | email/senha + Auth0 | email/senha |
| Projetos/Jogos | CRUD + seletor | CRUD + seletor |
| Snapshots | lista + detalhe + compare + restore | lista + detalhe + restore |
| DataStores | navegação + busca por player + JSON viewer | tipado (parcial) |
| Dashboard | stats + gráficos + insights | stats |
| Auditoria | com filtros | com filtros |
| Settings/Plano | completo | — (só mobile) |

---

## 5. Decisões de arquitetura — racional resumido

| Decisão | Por quê | Trade-off aceito |
|---|---|---|
| Microsserviços por contexto | Escala e deploy independentes; equipe dividida em trilhas | Mais infra/operacional do que um monólito |
| 1 banco por serviço + projeções por evento | Isolamento real; sem acoplamento de schema | Consistência eventual; dados duplicados |
| RabbitMQ direct + contratos no `shared/` | Eventos explícitos e versionáveis | Necessidade de idempotência nos handlers |
| Content-addressing (SHA-256) p/ blobs | Dedup de dados de jogador entre backups | Custo de CPU para canonicalizar + hashear |
| Blobs no S3, manifests no Postgres | Banco enxuto; storage barato para grandes volumes | Duas fontes de verdade a coordenar |
| AES-256-GCM nas API keys | Credencial sensível do cliente | Gestão da chave de cifra entre serviços |
| Sem API gateway | Simplicidade; cada serviço com Swagger | Cliente conhece 7 baseURLs |
| Mobile Riverpod / Web Zustand | Cada plataforma com a ferramenta idiomática | Dois modelos de estado a manter |
| 7 clientes HTTP no cliente | Isolar timeouts/erros por serviço | Mais boilerplate de setup |

---

## 6. Pontos fortes e oportunidades

**Fortes**
- Separação de responsabilidades muito disciplinada (camadas + contratos compartilhados).
- Deduplicação por content-addressing é uma escolha sólida para o domínio (dados de jogador são altamente repetitivos).
- Resiliência na integração Roblox (rate limit + retry + concorrência otimista).
- Segurança de credenciais bem tratada (cifra em repouso + token de serviço interno).

**Oportunidades**
- **CI/CD:** não há pipeline no repositório — automatizar `validate:all`/`test:all`/build de imagens.
- **DLQ:** mensagens hoje são descartadas em falha permanente; uma dead-letter queue daria rastreabilidade.
- **Testes de integração:** a cobertura é unitária; faltam testes ponta-a-ponta com Docker.
- **Endpoint de analytics:** retornava zeros e o mobile teve de agregar no cliente — vale consolidar no serviço.
- **Paridade web:** Settings/Plano e visualização de DataStores ainda são só do mobile.

---

# Parte II — Verificação dos Requisitos (atividade acadêmica)

> Esta parte avalia o **app mobile** (`apps/mobile`) contra a estrutura exigida pela atividade. Descreve o estado **real** do código e, ao final, aponta com transparência o que ainda pode evoluir.

## 7. Introdução do aplicativo

**Problema:** Desenvolvedores de jogos Roblox guardam dados de jogadores em **DataStores**, hoje gerenciados por consoles improvisados ou scripts soltos — sem backup confiável, sem histórico e sem forma segura de restaurar dados após corrupção ou exclusão acidental.

**Solução:** **Phoenix** é um app de **gestão de dados como serviço (DMaaS)** para Roblox. Pelo aplicativo o desenvolvedor conecta um jogo (Universe ID + Open Cloud API Key), acompanha um **dashboard** de métricas, visualiza **snapshots** e seus DataStores, executa **restore** granular, agenda backups automáticos e gerencia plano/configurações. O app é o cliente do back-end de microsserviços descrito na Parte I, consumido via HTTP/REST.

## 8. Atendimento aos requisitos

### 8.1 Arquitetura MVVM

Organização **feature-first em três camadas** (`data` / `domain` / `presentation`) que mapeia diretamente para os papéis do MVVM:

| Papel MVVM | No código | Exemplo |
|---|---|---|
| **Model** | Modelos imutáveis + repositórios | `GameModel`, `SnapshotModel`, `GamesRepository` |
| **ViewModel** | `StateNotifier`/providers que mantêm e expõem o estado, com a lógica de aplicação | `AuthNotifier` (`auth_provider.dart`), `GamesNotifier` (`games_provider.dart`) |
| **View** | `ConsumerWidget`/`ConsumerStatefulWidget` que apenas observam e renderizam | `DashboardPage`, `GamesPage`, `RestoreWizardPage` |

A View **não concentra regras de negócio**: carregamento, chamada ao repositório, cache e seleção padrão de jogo vivem no ViewModel (`GamesNotifier`); a View só decide *como desenhar* cada estado (`loading/error/data`).

### 8.2 Padrão de projeto adicional: **Observer** (+ Singleton, Factory, Facade)

- **Observer (principal):** reatividade do Riverpod. As Views se inscrevem (`ref.watch`) num ViewModel observável e são reconstruídas quando o estado muda. Quando `selectedGameProvider` muda, `snapshotsProvider` (que faz `ref.watch`) é reavaliado e todas as Views inscritas se atualizam — sem acoplamento entre telas.
- **Singleton:** `ApiClient` instanciado uma única vez e compartilhado por todos os repositórios via `apiClientProvider`.
- **Factory:** todos os models usam `factory fromJson(...)` para desserializar o JSON da API.
- **Facade:** `LocalStorageService` abstrai `flutter_secure_storage` + `shared_preferences` atrás de uma interface única.

### 8.3 Integração com API (loading / sucesso / erro)

Cliente HTTP **Dio**, encapsulado no `ApiClient` (Singleton), com uma instância por serviço do back-end. Fluxo: `View → ViewModel → Repository → DataSource (Dio) → API`, retorno desserializado em Model via `fromJson`.

| Estado | Representação | Na View |
|---|---|---|
| Carregamento | `AsyncLoading` / `isLoading` | skeleton (`shimmer`) ou spinner |
| Sucesso | `AsyncData(...)` | renderiza os dados |
| Erro | `try/catch` + `_parseError` | mensagem amigável (validação, timeout, rede) |

Timeouts configurados no Dio (`connectTimeout` 10s, `receiveTimeout` 30s). Um interceptor detecta **401** (token inválido/expirado) e redireciona ao login.

### 8.4 Persistência local (persistir + recuperar ao reabrir)

Dois mecanismos complementares atrás do `LocalStorageService` (Facade):

| Dado | Mecanismo | Por quê |
|---|---|---|
| Token JWT | `flutter_secure_storage` (cifrado) | Manter a sessão entre aberturas; credencial sensível |
| Lista de jogos | `shared_preferences` | Exibir os jogos imediatamente no cold start, antes da API |
| Id do jogo selecionado | `shared_preferences` | Reabrir o app já no último jogo escolhido |

**Fluxo de recuperação no boot:**
1. `main()` lê o token do `secure_storage`, decodifica o JWT (`UserModel.fromJwt`), reinjeta no `ApiClient` e monta um `AuthState` autenticado (via `bootstrapAuthStateProvider`). O roteador abre direto no dashboard, sem passar pelo login.
2. O `GamesNotifier` carrega primeiro do cache (`_loadFromCache`) e exibe na hora; em paralelo, `load()` rebusca da API e atualiza o cache. Em falha de rede, o cache permanece em tela.
3. A seleção de jogo é persistida sempre que muda e restaurada na próxima abertura.
4. No **logout**, token e cache são apagados (`deleteToken` + `clearCache`).

```dart
final savedToken = await secureStorage.read(key: 'auth_token');
if (savedToken != null && savedToken.isNotEmpty) {
  final user = UserModel.fromJwt(savedToken);
  if (user != null) {
    apiClient.setAuthToken(savedToken);
    bootstrapAuth = AuthState(isAuthenticated: true, user: user);
  }
}
```

## 9. Quadro-resumo de conformidade

| Requisito obrigatório | Situação |
|---|---|
| Arquitetura MVVM | ✅ Atendido (data/domain/presentation + StateNotifier) |
| Padrão adicional | ✅ Atendido (Observer + Singleton + Factory + Facade) |
| Comunicação com API (loading/sucesso/erro) | ✅ Atendido |
| Armazenamento local (persistir + recuperar ao reabrir) | ✅ Atendido (secure_storage p/ token + shared_preferences p/ cache, restaurados no boot) |
| Escopo mínimo (2+ telas, fluxo, interação) | ✅ Atendido com folga |
| README + Relatório técnico | ✅ README atualizado + este relatório |

## 10. Limitações e melhorias futuras

1. **MVVM mais estrito:** mover formatações residuais (tradução de eventos, "tempo atrás") das Views para os ViewModels e, opcionalmente, renomear `*Notifier → *ViewModel`.
2. **Expiração de token:** a sessão restaurada confia no token salvo; falta validar expiração no boot (hoje um token expirado só é detectado na primeira chamada à API, que retorna 401 e leva ao login).
3. **Testes:** o app ainda não possui testes de widget/unitários dos ViewModels.
4. **Funções dependentes de back-end:** auto-cadastro, recuperação de senha e login Auth0 estão previstos na UI, mas dependem de endpoints ainda não disponíveis no servidor.

---

*Relatório gerado a partir da leitura direta do código e da documentação em `phoenix-2/.docs/` e do mapeamento dos apps em `phoenix-frontend/apps/`.*
