# Relatório Técnico — Aplicativo Phoenix (Flutter)

**Disciplina:** Desenvolvimento mobile — arquitetura, integração e persistência
**App avaliado:** `apps/mobile` (Flutter/Dart) do projeto Phoenix
**Data:** 22/06/2026

> Este relatório segue a estrutura exigida pela atividade. Ele descreve o estado **real** do código e, ao final, aponta com transparência o que ainda não está implementado, para orientar a evolução.

---

## 1. Introdução do aplicativo

### Problema abordado
Desenvolvedores de jogos Roblox guardam dados de jogadores em **DataStores**. Hoje a maioria gerencia isso com consoles improvisados dentro do jogo ou scripts soltos, sem backup confiável, sem histórico e sem uma forma segura de restaurar dados após corrupção ou exclusão acidental.

### Proposta da solução
**Phoenix** é um app de **gestão de dados como serviço (DMaaS)** para Roblox. Pelo aplicativo o desenvolvedor:
- conecta um jogo via **Universe ID + Open Cloud API Key**;
- acompanha um **dashboard** com métricas de backups, storage e atividade;
- visualiza **snapshots** (backups) e seus DataStores;
- executa **restore** granular para um estado anterior;
- agenda backups automáticos e gerencia plano/configurações.

O app é o cliente de um back-end de microsserviços (NestJS), consumido via HTTP/REST.

---

## 2. Arquitetura MVVM

### Como foi organizada
O app usa organização **feature-first em três camadas** (`data` / `domain` / `presentation`), que mapeia diretamente para os papéis do MVVM:

```
lib/features/<feature>/
  data/          → Model + acesso a dados (DataSource, Repository, *_model.dart)
  domain/        → ViewModel (StateNotifier / Provider que expõe o estado)
  presentation/  → View (pages e widgets)
```

Funcionalidades: `auth`, `games`, `dashboard`, `snapshots`, `datastores`, `audit`, `settings`.

### Divisão de responsabilidades

| Papel MVVM | No código | Exemplo |
|---|---|---|
| **Model** | Modelos imutáveis + repositórios | `GameModel`, `SnapshotModel`, `GamesRepository` |
| **ViewModel** | `StateNotifier` e providers que mantêm e expõem o estado, contendo a lógica de aplicação | `AuthNotifier` (`auth_provider.dart`), `GamesNotifier` (`games_provider.dart`) |
| **View** | `ConsumerWidget`/`ConsumerStatefulWidget` que apenas observam o ViewModel e renderizam | `DashboardPage`, `GamesPage`, `RestoreWizardPage` |

**Exemplo concreto de separação** (`games_provider.dart`):
```dart
class GamesNotifier extends StateNotifier<AsyncValue<List<GameModel>>> {
  final GamesRepository _repository;        // depende do Model/Repository
  GamesNotifier(this._repository, this._ref) : super(const AsyncLoading()) { load(); }

  Future<void> load() async {               // regra de aplicação fica AQUI, no ViewModel
    state = const AsyncLoading();
    try {
      final games = await _repository.getGames();
      state = AsyncData(games);
      _syncSelectedGame(games);             // ex.: seleciona o jogo mais antigo por padrão
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

A **View** correspondente apenas observa e reage aos três estados:
```dart
final gamesAsync = ref.watch(gamesProvider);
gamesAsync.when(
  loading: () => const SkeletonLoader(),
  error:   (e, _) => ErrorView(message: '$e'),
  data:    (games) => GamesList(games: games),
);
```

A interface (View) **não concentra regras de negócio**: o carregamento, a chamada ao repositório e a seleção padrão de jogo vivem no ViewModel; a View só decide *como desenhar* cada estado.

> **Observação honesta de qualidade:** ainda há pequenos resíduos de lógica em widgets de apresentação (ex.: o mapa de tradução de eventos e o cálculo de "tempo atrás" no `dashboard_page.dart`). São formatações de exibição, mas o ideal MVVM seria movê-las para o ViewModel/uma camada de apresentação dedicada.

---

## 3. Padrão de projeto adicional

### Padrão escolhido: **Observer** (reatividade via Riverpod) — apoiado por **Singleton**

### Por que foi escolhido
O app é fortemente orientado a estado assíncrono: dados vêm da rede, mudam de jogo selecionado, e várias telas precisam reagir à mesma fonte (ex.: trocar o jogo no dashboard deve refletir em snapshots, datastores e cards). O padrão **Observer** resolve isso nativamente: as Views se *inscrevem* (`ref.watch`) num ViewModel observável e são notificadas/reconstruídas quando o estado muda — sem acoplamento direto entre telas.

### Onde foi aplicado
- **Observer:** `StateNotifierProvider`/`FutureProvider` do Riverpod. Quando `selectedGameProvider` muda, `snapshotsProvider` (que faz `ref.watch(selectedGameProvider)`) é automaticamente reavaliado e todas as Views inscritas se atualizam. O roteador também observa o estado de auth via um `ValueNotifier` (`authStateListenable`) para redirecionar entre login e área logada.
- **Singleton:** o `ApiClient` é instanciado **uma única vez** e compartilhado por todos os repositórios através do `apiClientProvider` (`core/di/providers.dart`):
  ```dart
  final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
  ```
  Isso garante uma só configuração de Dio/headers/token em todo o app.
- **Factory (complementar):** todos os modelos usam construtores `factory fromJson(...)` para criar instâncias a partir do JSON da API (ex.: `SnapshotModel.fromJson`).

---

## 4. Integração com API

### Endpoints e fluxo de consumo
O cliente HTTP é o **Dio**, encapsulado no `ApiClient` (Singleton), que mantém uma instância por serviço do back-end (IAM, Projects, Discovery, Snapshots, Restore, Audit). Exemplos de endpoints reais consumidos:

| Tela | Método | Endpoint |
|---|---|---|
| Login | `POST` | `/v1/auth/login` (serviço IAM :5001) |
| Lista de jogos | `GET` | `/v1/projects` (Projects :5002) |
| Criar jogo | `POST` | `/v1/projects` |
| Snapshots do jogo | `GET` | `/v1/projects/:id/snapshots` (Snapshots :5004) |
| DataStores | `GET` | `/v1/projects/:id/datastores` (Discovery :5003) |
| Auditoria | `GET` | `/v1/audit` (Audit :5007) |

**Fluxo:** `View → ViewModel (Notifier/Provider) → Repository → DataSource (Dio) → API`. O retorno é desserializado em Model via `fromJson` e devolvido à View já tipado.

### Tratamento de erros/estados
- **Carregamento:** representado por `AsyncLoading` / `state.copyWith(isLoading: true)`; a View mostra skeletons (`shimmer`) ou spinner.
- **Sucesso:** `AsyncData(...)`; a View renderiza os dados.
- **Erro:** capturado em `try/catch`. `DioException` é traduzido em mensagem amigável por um `_parseError` (lê `response.data.message`, trata lista de erros de validação, e cai em "Erro de conexão" para falha de rede). Há **timeouts** configurados no Dio (`connectTimeout` 10s, `receiveTimeout` 30s), cobrindo timeout/queda de conexão.
- **401:** um interceptor detecta token inválido/expirado e direciona o usuário de volta ao login.

Exemplo (`auth_provider.dart`):
```dart
try {
  final response = await _repository.login(email, password);
  state = state.copyWith(isAuthenticated: true, isLoading: false, user: response.user);
} catch (e) {
  state = state.copyWith(isLoading: false, error: e.toString().replaceFirst('Exception: ', ''));
}
```

---

## 5. Persistência local

### Tecnologia adotada
A persistência usa **dois mecanismos complementares**, encapsulados por um `LocalStorageService` (`core/storage/local_storage_service.dart`) que funciona como **Facade** sobre ambos:

- **`flutter_secure_storage`** (cifrado em repouso) — guarda o **token JWT** de sessão, por ser dado sensível.
- **`shared_preferences`** — guarda o **cache de domínio** (lista de jogos + id do jogo selecionado), para exibição imediata no cold start.

### Quais dados são persistidos e por quê

| Dado | Mecanismo | Por quê |
|---|---|---|
| Token JWT | secure_storage | Manter a sessão entre aberturas sem novo login; é credencial sensível |
| Lista de jogos | shared_preferences | Mostrar os jogos imediatamente ao abrir, antes da API responder |
| Id do jogo selecionado | shared_preferences | Reabrir o app já no último jogo escolhido pelo usuário |

### Fluxo de recuperação ao reabrir o app
1. No `main()`, antes de subir a UI: inicializa o `SharedPreferences`, lê o token do `secure_storage` e, se válido, reinjeta-o no `ApiClient` e monta um `AuthState` autenticado (via `bootstrapAuthStateProvider`). O roteador então abre direto no dashboard, sem passar pelo login.
2. O `GamesNotifier`, ao ser criado, **carrega primeiro do cache** (`_loadFromCache`) e exibe a lista na hora; em paralelo, `load()` rebusca da API e atualiza o cache. Em caso de falha de rede, o cache permanece em tela.
3. A seleção de jogo é persistida sempre que muda (default ou manual) e restaurada na próxima abertura.

No **logout**, token e cache são apagados (`deleteToken` + `clearCache`).

Trecho do `main.dart`:
```dart
final prefs = await SharedPreferences.getInstance();
final savedToken = await secureStorage.read(key: 'auth_token');
if (savedToken != null && savedToken.isNotEmpty) {
  final user = UserModel.fromJwt(savedToken);
  if (user != null) {
    apiClient.setAuthToken(savedToken);
    bootstrapAuth = AuthState(isAuthenticated: true, user: user);
  }
}
```

---

## 6. Conclusão

### Principais decisões
- **MVVM com Riverpod:** camadas `data/domain/presentation` com `StateNotifier` como ViewModel observável — separação clara e testável entre dados, lógica e interface.
- **Observer + Singleton:** reatividade do Riverpod para propagar estado entre telas sem acoplamento, e um `ApiClient` único para centralizar a comunicação HTTP.
- **Integração HTTP robusta:** Dio por serviço, com tratamento explícito de carregamento, sucesso, erro e timeout, e desserialização tipada via `fromJson`.

### Limitações e melhorias futuras
1. **MVVM mais estrito:** mover formatações residuais (tradução de eventos, "tempo atrás") das Views para os ViewModels e, opcionalmente, renomear `*Notifier → *ViewModel` para deixar o padrão explícito.
2. **Expiração de token:** a sessão restaurada confia no token salvo; falta validar expiração no boot (hoje um token expirado só é detectado na primeira chamada à API, que retorna 401 e leva ao login).
3. **Testes:** o app ainda não possui testes de widget/unitários dos ViewModels.
4. **Funções dependentes de back-end:** auto-cadastro, recuperação de senha e login Auth0 estão previstos na UI, mas dependem de endpoints ainda não disponíveis no servidor.

---

### Quadro-resumo de conformidade com os requisitos

| Requisito obrigatório | Situação |
|---|---|
| Arquitetura MVVM | ✅ Atendido (mapeado em data/domain/presentation + StateNotifier) |
| Padrão adicional | ✅ Atendido (Observer + Singleton + Factory) |
| Comunicação com API (loading/sucesso/erro) | ✅ Atendido |
| Armazenamento local (persistir + recuperar ao reabrir) | ✅ Atendido (secure_storage p/ token + shared_preferences p/ cache, restaurados no boot) |
| Escopo mínimo (2+ telas, fluxo, interação) | ✅ Atendido com folga |
| README + Relatório técnico | 🟡 README existe; este relatório cobre a estrutura exigida |
