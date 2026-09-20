# Bookcase — Backend (API)

API REST em **ASP.NET Core (C#, .NET 10)** que serve o app Flutter Bookcase.
Usa **Entity Framework Core** com **PostgreSQL** (hospedado no Supabase).

## Pré-requisitos

- .NET SDK 10 — confira com `dotnet --version`
- Ferramenta de migrations do EF Core:
  ```bash
  dotnet tool install --global dotnet-ef
  ```

## Configuração da connection string

A connection string **não fica no repositório** (por segurança). Quem for rodar o
backend precisa configurar o próprio `user-secrets` uma vez:

```bash
cd backend/Bookcase.Api
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=<host>;Port=5432;Database=postgres;Username=<user>;Password=<senha>;SSL Mode=Require;Trust Server Certificate=true"
```

> Peça os dados do banco (host, user, senha) a quem cuida do backend. No Supabase
> eles ficam em **Connect → Session pooler**.

## Rodar a API

```bash
cd backend
dotnet run --project Bookcase.Api --launch-profile http
```

Depois abra a documentação interativa: http://localhost:5094/swagger

## Banco de dados (migrations)

As tabelas são criadas e atualizadas por migrations do EF Core.

Aplicar as migrations existentes (cria/atualiza as tabelas no banco):

```bash
cd backend/Bookcase.Api
dotnet ef database update
```

Criar uma nova migration depois de alterar as entidades:

```bash
dotnet ef migrations add NomeDaMudanca
dotnet ef database update
```

## Estrutura

```
backend/
├── Bookcase.slnx              solução
└── Bookcase.Api/
    ├── Program.cs             configuração da API (serviços + pipeline)
    ├── Controllers/           endpoints (rotas HTTP)
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
