# Phoenix Frontend

Frontend do projeto **Phoenix** — plataforma de gerenciamento de DataStores Roblox.

Este repositório contém dois apps:
- `apps/web` — painel web (Next.js 14)
- `apps/mobile` — app mobile (Flutter)

---

## Pré-requisitos

### Backend (phoenix-2)
Antes de rodar o frontend, o backend precisa estar no ar. Certifique-se de ter:
- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/) instalados
- Repositório `phoenix-data-management/phoenix-2` clonado

### Frontend Web
- [Node.js](https://nodejs.org/) 18+
- npm 9+

### Frontend Mobile
- [Flutter](https://flutter.dev/docs/get-started/install) SDK (stable)
- Android Studio com um AVD configurado (ou dispositivo físico)
- Java 17+

---

## 1. Subindo o Backend

```bash
# Clone o repositório do backend
git clone https://github.com/phoenix-data-management/phoenix-2.git
cd phoenix-2

# Suba todos os serviços via Docker Compose
npm run start:all
```

Aguarde até ver todos os containers como `Started` ou `Running`. Os serviços ficam expostos nas portas:

| Serviço     | Porta |
|-------------|-------|
| IAM         | 5001  |
| Projects    | 5002  |
| Discovery   | 5003  |
| Snapshots   | 5004  |
| Restore     | 5005  |
| Admin-Data  | 5006  |
| Audit       | 5007  |
| RabbitMQ    | 5672  |
| PostgreSQL  | 5432  |
| MinIO       | 9000  |

Para verificar se os containers estão saudáveis:
```bash
docker ps
```

Para ver os logs de um serviço específico:
```bash
docker logs phoenix-2-discovery-1 -f
```

---

## 2. Configurando a API Key do Roblox

O serviço de Discovery precisa de uma API Key do Roblox com as permissões corretas para listar DataStores.

1. Acesse [create.roblox.com](https://create.roblox.com) → **All Tools** → **API Keys**
2. Crie uma nova API Key
3. Em **Permissions**, adicione:
   - **DataStore API** → marque `universe-datastores.control:list`
   - **DataStore API** → marque `universe-datastores.objects:list,create,read,update,delete`
4. Em **Accepted IP Addresses**, adicione `0.0.0.0/0` (ou o IP da sua máquina)
5. Salve e copie a chave gerada (começa com `rbxp_...`)

Essa chave será usada ao cadastrar um jogo no app.

---

## 3. Rodando o Frontend Web

```bash
# Acesse a pasta do app web
cd apps/web

# Instale as dependências
npm install

# Rode em modo de desenvolvimento
npm run dev
```

Abra [http://localhost:3000](http://localhost:3000) no navegador.

### Como funciona o proxy
O Next.js redireciona as chamadas `/api/*` para os microserviços via `next.config.ts`:
```
/api/iam/*        → localhost:5001/v1/*
/api/projects/*   → localhost:5002/v1/*
/api/discovery/*  → localhost:5003/v1/*
/api/snapshots/*  → localhost:5004/v1/*
/api/restore/*    → localhost:5005/v1/*
/api/audit/*      → localhost:5007/v1/*
/api/admin-data/* → localhost:5006/v1/*
```

---

## 4. Rodando o Frontend Mobile

### 4.1 Instalar dependências

```bash
cd apps/mobile
flutter pub get
```

### 4.2 Verificar dispositivos disponíveis

```bash
flutter devices
```

### 4.3 Iniciar o emulador (se não estiver aberto)

```bash
# Listar emuladores disponíveis
flutter emulators

# Iniciar um emulador
flutter emulators --launch <emulator_id>
# Exemplo:
flutter emulators --launch Pixel_8_API_36
```

### 4.4 Rodar o app

```bash
# Rodar no emulador/dispositivo conectado
flutter run -d <device_id>

# Exemplo com emulador Android:
flutter run -d emulator-5554
```

### 4.5 Configuração de host para o emulador

O app mobile se conecta ao backend usando:
- **Emulador Android** → `10.0.2.2` (alias para `localhost` do computador) ✅ já configurado
- **Dispositivo físico** → substitua `10.0.2.2` pelo IP da sua máquina na rede local

Para alterar o host, edite o arquivo:
```
apps/mobile/lib/core/constants/api_constants.dart
```

```dart
static const String _host = '10.0.2.2'; // emulador
// static const String _host = '192.168.1.100'; // dispositivo físico
```

### 4.6 Comandos úteis durante o desenvolvimento

Com o app rodando no terminal:
- `r` — Hot reload (recarrega o código sem perder estado)
- `R` — Hot restart (reinicia o app)
- `q` — Encerrar o app
- `d` — Desconectar sem fechar o app

---

## 5. Primeiro Acesso

1. Abra o app (web ou mobile)
2. Faça login com as credenciais do backend
3. Vá em **Meus Jogos** → **Adicionar Jogo**
4. Preencha:
   - **Nome do Jogo**
   - **Universe ID** (encontrado na URL do Creator Hub)
   - **Place ID**
   - **API Key** gerada no passo 2
5. Após cadastrar, aguarde ~30 segundos para o Discovery service escanear os DataStores automaticamente
6. Acesse a aba **DataStores** para ver os dados do seu jogo

### Disparar discovery manual (via terminal)

Caso os DataStores não apareçam automaticamente:

```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:5001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"seu@email.com","password":"suasenha"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")

# Listar projetos para pegar o ID
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:5002/v1/projects | python3 -m json.tool

# Disparar discovery run
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  http://localhost:5003/v1/projects/<PROJECT_ID>/discovery-runs | python3 -m json.tool
```

---

## 6. Estrutura do Projeto

```
phoenix-frontend/
├── apps/
│   ├── web/                    # Next.js 14 (App Router)
│   │   ├── src/
│   │   │   ├── app/            # Páginas (dashboard, restore, histórico...)
│   │   │   └── services/       # Clientes HTTP (api.ts)
│   │   └── next.config.ts      # Rewrites para os microserviços
│   └── mobile/                 # Flutter
│       └── lib/
│           ├── core/
│           │   ├── constants/  # URLs das APIs
│           │   ├── network/    # Clientes Dio por serviço
│           │   ├── router/     # go_router (rotas + shell)
│           │   └── theme/      # Design system (cores Phoenix)
│           └── features/       # Módulos por funcionalidade
│               ├── auth/
│               ├── games/
│               ├── datastores/
│               ├── snapshots/
│               ├── audit/
│               ├── dashboard/
│               └── settings/
└── README.md
```

---

## 7. Tecnologias

### Web
- [Next.js 14](https://nextjs.org/) com App Router
- [TypeScript](https://www.typescriptlang.org/)
- [Axios](https://axios-http.com/) para requisições HTTP
- Tailwind CSS

### Mobile
- [Flutter](https://flutter.dev/) (Dart)
- [Riverpod](https://riverpod.dev/) para gerenciamento de estado
- [go_router](https://pub.dev/packages/go_router) para navegação
- [Dio](https://pub.dev/packages/dio) para requisições HTTP
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) para armazenar o JWT

### Backend (phoenix-2)
- [NestJS](https://nestjs.com/) microserviços
- [PostgreSQL](https://www.postgresql.org/) + [Drizzle ORM](https://orm.drizzle.team/)
- [RabbitMQ](https://www.rabbitmq.com/) para eventos entre serviços
- [MinIO](https://min.io/) para armazenamento de objetos
- [Docker Compose](https://docs.docker.com/compose/) para orquestração
