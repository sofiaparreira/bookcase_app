# Bookcase — Backend (API)

API REST em **ASP.NET Core (C#, .NET 10)** que serve o app Flutter Bookcase.
Usa **Entity Framework Core** com **PostgreSQL** (hospedado no Supabase) e
**autenticação via JWT**.

## API publicada

- **Swagger (produção):** https://bookcase-api-g9pa.onrender.com/swagger

## Pré-requisitos (para rodar localmente)

- .NET SDK 10 — confira com `dotnet --version`
- Ferramenta de migrations do EF Core:
  ```bash
  dotnet tool install --global dotnet-ef
  ```

## Configuração (secrets)

Nenhum segredo fica no repositório. Quem for rodar o backend localmente precisa
configurar o próprio `user-secrets` uma vez (dentro de `backend/Bookcase.Api`):

```bash
cd backend/Bookcase.Api

# Conexão com o banco (peça os dados a quem cuida do backend)
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=<host>;Port=5432;Database=postgres;Username=<user>;Password=<senha>;SSL Mode=Require;Trust Server Certificate=true"

# Chave usada para assinar os tokens JWT (qualquer frase longa, 32+ caracteres)
dotnet user-secrets set "Jwt:Key" "<uma-frase-secreta-longa>"
```

> No Supabase, os dados de conexão ficam em **Connect → Session pooler**.
> Em produção (Render), esses valores vão como **variáveis de ambiente**:
> `ConnectionStrings__DefaultConnection` e `Jwt__Key` (com `__` no lugar do `:`).

## Rodar a API

```bash
cd backend
dotnet run --project Bookcase.Api --launch-profile http
```

Documentação interativa: http://localhost:5094/swagger

## Autenticação

A maioria dos endpoints exige um token JWT. O fluxo:

1. **Cadastrar:** `POST /api/auth/register` com `{ name, email, password }`
2. **Logar:** `POST /api/auth/login` com `{ email, password }` → devolve `{ token }`
3. **Usar o token:** envie o header `Authorization: Bearer <token>` nas requisições.

No Swagger, clique no botão **Authorize** (cadeado), cole o token e teste os
endpoints protegidos. Cada usuário só enxerga e altera os próprios dados.

## Endpoints

| Área | Rotas | Protegido? |
|---|---|---|
| Auth | `POST /api/auth/register`, `POST /api/auth/login` | não |
| Livros | `GET/POST /api/book`, `GET/PUT/DELETE /api/book/{id}` | sim |
| Lista de compras | `GET/POST /api/shoppinglist`, `GET/PUT/DELETE /api/shoppinglist/{id}` | sim |
| Metas | `GET/POST /api/readinggoal`, `GET/PUT/DELETE /api/readinggoal/{id}` | sim |

## Banco de dados (migrations)

As tabelas são criadas e atualizadas por migrations do EF Core.

```bash
cd backend/Bookcase.Api

# aplicar as migrations existentes (cria/atualiza as tabelas)
dotnet ef database update

# criar uma nova migration depois de alterar as entidades
dotnet ef migrations add NomeDaMudanca
dotnet ef database update
```

## Deploy (Render)

O deploy é feito pelo **Render** a partir do `Dockerfile` em `backend/Bookcase.Api`.
A cada push na branch acompanhada, o Render reconstrói e publica sozinho. As
variáveis de ambiente (`ConnectionStrings__DefaultConnection` e `Jwt__Key`) são
configuradas no painel do Render.

## Estrutura

```
backend/
├── Bookcase.slnx              solução
└── Bookcase.Api/
    ├── Program.cs             configuração da API (serviços + pipeline)
    ├── Dockerfile             receita de build para o deploy
    ├── Controllers/           endpoints (rotas HTTP)
    ├── Dtos/                  objetos de entrada (RegisterDto, LoginDto)
    ├── Models/                entidades (User, Book, ShoppingListItem, ReadingGoal)
    ├── Data/                  AppDbContext (ponte com o banco)
    └── Migrations/            histórico do schema do banco
```

## Entidades

| Entidade | O que guarda |
|---|---|
| `User` | usuários (login/cadastro) |
| `Book` | livros da estante |
| `ShoppingListItem` | itens da lista de compras |
| `ReadingGoal` | metas de leitura |

Cada entidade (menos `User`) pertence a um usuário através do campo `UserId`.
