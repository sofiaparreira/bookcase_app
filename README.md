# Estante

Aplicativo Flutter desenvolvido para a entrega final da A3 da disciplina **Desenvolvimento para Ambientes Móveis**.

## 1. Identificação do projeto

- **Nome do aplicativo:** Estante
- **Squad:** Clube do Livro
- **Repositório:** https://github.com/sofiaparreira/bookcase_app

### Integrantes

| Integrante | Matrícula 
|---|---|
| Arthur Cândido | 72400072 | 
| Cauã de Moraes Furtado | 72401052 | 
| Maria Luiza Bertolino Matos | 72401346 | 
| João Vitor Kadus Carvalho | 72401311 | 
| Sofia Parreira Passos | 72500115 |

contato: 72500115@aluno.faculdadecotemig.br


## 2. Sobre o projeto

O **Estante** é um aplicativo para leitores que desejam organizar sua vida literária em um único lugar. O usuário pode criar uma conta, pesquisar livros, adicioná-los à estante e classificá-los como **Quero ler**, **Lendo** ou **Lido**. Durante a leitura, é possível registrar o progresso por páginas ou porcentagem e finalizar o livro com uma avaliação. O aplicativo também permite criar metas de leitura, organizar uma lista de compras e acompanhar métricas e a sequência de dias com atividade de leitura. Os dados são sincronizados com uma API REST própria e a pesquisa de livros utiliza a Google Books API.

### Público-alvo

Leitores, estudantes e pessoas que desejam desenvolver ou acompanhar o hábito de leitura, organizar livros e planejar futuras compras.

### Telas principais

1. **Login e cadastro:** autenticação e criação de usuário.
2. **Início:** resumo de livros lidos, páginas lidas, leitura atual, meta ativa e lista de compras.
3. **Minha Estante:** livros separados entre Lendo, Quero ler e Lidos, com busca e atualização de progresso.
4. **Buscar:** pesquisa de livros por título ou autor usando a Google Books API.
5. **Detalhes do livro:** informações, sinopse, avaliação geral e ações para estante e lista de compras.
6. **Metas:** criação e acompanhamento de metas de leitura.
7. **Compras:** livros que o usuário deseja comprar e itens já adquiridos.
8. **Perfil e configurações:** dados do usuário, edição de perfil, alteração de senha, informações do app e saída da conta.

### Fluxo de navegação

- Ao abrir o aplicativo, a sessão salva é restaurada. Sem uma sessão válida, o usuário é direcionado ao login.
- O login permite abrir o cadastro e, após a autenticação, substitui a tela atual pelo aplicativo principal.
- A navegação principal contém as abas **Início**, **Estante**, **Buscar**, **Metas**, **Compras** e **Perfil**.
- A busca abre a página de detalhes do livro com `Navigator.push`.
- Metas, configurações, cadastro e busca de itens para compra também usam `Navigator.push` e retornam com `Navigator.pop`.
- Na estante, o usuário pode iniciar uma leitura, atualizar o progresso e concluir o livro. Ao chegar a 100%, o fluxo de finalização e avaliação é aberto automaticamente.

## 3. Requisitos atendidos

| Nº | Requisito da A3 | Situação | Onde está implementado |
|---:|---|---|---|
| 1 | Pelo menos quatro telas com `Navigator.push` e `Navigator.pop` | Atendido | Cadastro, detalhes do livro, formulários e detalhes de metas, busca para lista de compras e configurações. Exemplos em `lib/features/auth/login_page.dart`, `lib/features/search_books/search_books_page.dart`, `lib/features/goals/metas_screen.dart`, `lib/features/shopping_list/shopping_list_page.dart` e `lib/features/settings_page/settings_page.dart`. |
| 2 | API REST com `http` e `async/await` | Atendido | O pacote `http` está no `pubspec.yaml`. As chamadas estão em `lib/features/auth/auth_service.dart`, `lib/shared/service/book_service.dart`, `lib/shared/service/google_books_service.dart`, `lib/features/goals/goals_service.dart` e `lib/features/shopping_list/shopping_list_service.dart`. |
| 3 | Loading e erro visíveis na interface | Atendido | Indicadores de carregamento, estados vazios, botão de nova tentativa e alertas padronizados aparecem em busca, estante, metas e compras. Ver `lib/shared/widgets/alerts/app_alert.dart`. |
| 4 | Formulário com `Form` e `validator` | Atendido | Login, cadastro, metas, compras, edição do perfil e alteração de senha usam `GlobalKey<FormState>` e validadores. |
| 5 | Lista dinâmica com `ListView.builder` | Atendido | As listas são dinâmicas e construídas sob demanda com `itemCount` e `itemBuilder`, mas utilizam principalmente `ListView.separated`, uma variação do mesmo padrão. |
| 6 | Persistência com `SharedPreferences` | Atendido | Sessão, token, e-mail, progresso local e sequência de leitura são persistidos em `lib/features/auth/auth_service.dart`, `lib/features/my_bookshelf/bookshelf_store.dart` e `lib/features/streak/streak_store.dart`. |
| 7 | Provider e separação entre telas, HTTP e preferências | Atendido | O projeto separa telas, serviços HTTP e persistência e usa `ChangeNotifier`, `ValueNotifier` e `ListenableBuilder`. |
| 8 | Aplicativo abre e percorre o fluxo sem crashar | Atendido |


## 4. API e dados remotos

O aplicativo utiliza duas fontes de dados remotos:

1. Uma API REST própria em ASP.NET Core para autenticação e dados do usuário.
2. A API pública Google Books para pesquisa e metadados de livros.

### API própria

- **URL base usada pelo aplicativo:** `https://bookcase-api-g9pa.onrender.com`
- **Swagger:** https://bookcase-api-g9pa.onrender.com/swagger
- **Hospedagem:** Render
- **Banco de dados:** PostgreSQL hospedado no Supabase
- **Autenticação:** JWT
- **Código do backend:** `backend/Bookcase.Api`

A URL base está definida em `lib/core/config/api_config.dart`.

### Endpoints

| Método | Rota | Autenticação | Finalidade |
|---|---|---:|---|
| `POST` | `/api/auth/register` | Não | Cadastrar usuário |
| `POST` | `/api/auth/login` | Não | Autenticar e obter JWT |
| `GET` | `/api/auth/me` | Sim | Buscar perfil atual |
| `PUT` | `/api/auth/me` | Sim | Atualizar perfil |
| `PUT` | `/api/auth/password` | Sim | Alterar senha |
| `GET` | `/api/book` | Sim | Listar livros da estante |
| `GET` | `/api/book?status={status}` | Sim | Filtrar livros por status |
| `GET` | `/api/book/{id}` | Sim | Buscar um livro da estante |
| `POST` | `/api/book` | Sim | Adicionar livro à estante |
| `PUT` | `/api/book/{id}` | Sim | Atualizar status, progresso e avaliação |
| `DELETE` | `/api/book/{id}` | Sim | Remover livro da estante |
| `GET` | `/api/shoppinglist` | Sim | Listar itens de compra |
| `GET` | `/api/shoppinglist/{id}` | Sim | Buscar um item de compra |
| `POST` | `/api/shoppinglist` | Sim | Criar item de compra |
| `PUT` | `/api/shoppinglist/{id}` | Sim | Atualizar item de compra |
| `DELETE` | `/api/shoppinglist/{id}` | Sim | Excluir item de compra |
| `GET` | `/api/readinggoal` | Sim | Listar metas |
| `GET` | `/api/readinggoal/{id}` | Sim | Buscar uma meta |
| `POST` | `/api/readinggoal` | Sim | Criar meta |
| `PUT` | `/api/readinggoal/{id}` | Sim | Atualizar meta |
| `PATCH` | `/api/readinggoal/{id}/progress` | Sim | Atualizar progresso da meta |
| `DELETE` | `/api/readinggoal/{id}` | Sim | Excluir meta |

As rotas protegidas recebem o cabeçalho:

```http
Authorization: Bearer <token>
```

### Conta de teste

Disponível apenas na API publicada no Render:

email: teste1@gmail.com
senha: 12345678

### Google Books API

A busca de livros consulta diretamente:

```text
GET https://www.googleapis.com/books/v1/volumes
GET https://www.googleapis.com/books/v1/volumes/{id}
```

O serviço responsável está em `lib/shared/service/google_books_service.dart`. A chave utilizada pelo cliente não é reproduzida nesta documentação. Ela deve permanecer protegida por restrições de API, aplicativo e cotas no Google Cloud.

### Observação sobre o Supabase

O banco PostgreSQL do backend está hospedado no Supabase. O fluxo principal de cadastro, login e acesso aos dados usa a API ASP.NET Core e o JWT próprio, e não o Supabase Auth.

## 5. Como rodar o aplicativo

### Pré-requisitos

- Flutter **3.47** ou superior.
- Dart **3.13.2** ou superior (`sdk: ^3.13.2` no `pubspec.yaml`).
- Git.
- Android Studio, emulador Android, navegador ou outro dispositivo compatível com Flutter.
- Acesso à internet para a API própria e a Google Books API.

### Clonar e instalar

```bash
git clone https://github.com/sofiaparreira/bookcase_app.git
cd bookcase_app
flutter pub get
```


### Executar


Execute no dispositivo desejado:

```bash
flutter run
```

Ou informe o dispositivo explicitamente:

```bash
flutter run -d <id-do-dispositivo>
```


O aplicativo já está configurado para usar a API publicada no Render. Portanto, não é necessário subir o backend local para o uso normal.



## 6. Backend local

O backend é uma API REST em **ASP.NET Core, C# e .NET 10**, com Entity Framework Core, PostgreSQL, autenticação JWT e documentação Swagger. O código está em `backend/Bookcase.Api`.

Rodar o backend localmente é opcional: o aplicativo já usa a API publicada no Render. Os passos abaixo servem para quem quiser executar tudo na própria máquina.

### Pré-requisitos

- .NET SDK 10. Verifique com `dotnet --version` (deve começar com `10.`).
- Um banco PostgreSQL. A forma mais simples é usar o Docker (opção A abaixo).
- Docker Desktop, caso use a opção A.

Os comandos abaixo funcionam no PowerShell, no Prompt de Comando e no terminal do Linux/macOS.

### 1. Subir um banco PostgreSQL

**Opção A — PostgreSQL local com Docker (recomendado):**

```bash
docker run --name bookcase-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:17
```

Connection string correspondente:

```text
Host=localhost;Port=5432;Database=bookcase;Username=postgres;Password=postgres
```

O banco `bookcase` é criado automaticamente no passo 4.

**Opção B — banco no Supabase:** crie um projeto no Supabase e copie os dados em **Connect → Session pooler**. Nesse caso, a connection string precisa de SSL:

```text
Host=<host>;Port=5432;Database=postgres;Username=<usuario>;Password=<senha>;SSL Mode=Require;Trust Server Certificate=true
```

O banco de produção do projeto não é compartilhado. Por isso, o banco local começa vazio e a conta de teste da seção 4 não existe nele: crie uma conta nova pela tela de cadastro do app ou pelo Swagger.

### 2. Instalar dependências e ferramentas

A partir da raiz do repositório:

```bash
cd backend/Bookcase.Api
dotnet restore
dotnet tool restore
```

O `dotnet tool restore` instala o `dotnet-ef` na versão definida em `backend/Bookcase.Api/dotnet-tools.json`.

### 3. Configurar os secrets

Os dados sensíveis não ficam no repositório. Ainda dentro de `backend/Bookcase.Api`, configure-os com `user-secrets`:

```bash
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=bookcase;Username=postgres;Password=postgres"
```

```bash
dotnet user-secrets set "Jwt:Key" "uma-chave-local-qualquer-com-mais-de-32-caracteres"
```

A chave JWT precisa ter **pelo menos 32 caracteres**, pois os tokens são assinados com HMAC-SHA256. Com uma chave menor, o login falha.

### 4. Criar as tabelas

Ainda dentro de `backend/Bookcase.Api`:

```bash
dotnet ef database update
```

Esse comando cria o banco (se ainda não existir) e aplica as migrations de `backend/Bookcase.Api/Migrations`.

### 5. Subir a API

A partir da raiz do repositório:

```bash
cd backend
dotnet run --project Bookcase.Api --launch-profile http
```

Endereços locais:

- API: `http://localhost:5094`
- Swagger: `http://localhost:5094/swagger`

Abra o Swagger no navegador para confirmar que a API está no ar. Para parar, pressione `Ctrl+C` no terminal em que ela estiver rodando.

### 6. Apontar o Flutter para a API local

Altere temporariamente a `baseUrl` em `lib/core/config/api_config.dart`, de acordo com onde o app vai rodar:

| Onde o app roda | `baseUrl` |
|---|---|
| Flutter Web ou desktop (Windows, macOS, Linux) na mesma máquina | `http://localhost:5094` |
| Emulador Android | `http://10.0.2.2:5094` |
| Celular físico na mesma rede Wi-Fi | `http://<ip-do-computador>:5094` |

Exemplo para o emulador Android:

```dart
static const String baseUrl = 'http://10.0.2.2:5094';
```

No emulador Android, `localhost` aponta para o próprio emulador. O endereço `10.0.2.2` redireciona para o computador.

Para usar um celular físico, a API precisa aceitar conexões da rede. Suba-a com:

```bash
dotnet run --project Bookcase.Api --launch-profile http --urls http://0.0.0.0:5094
```

Depois, libere a porta `5094` no firewall e use o IP local do computador (no Windows, `ipconfig`; no Linux/macOS, `ip addr` ou `ifconfig`).

Depois dos testes, volte a `baseUrl` para `https://bookcase-api-g9pa.onrender.com`.

A busca de livros continua usando a Google Books API diretamente, então ela precisa de internet mesmo com o backend local.

### Produção

No Render, os secrets são configurados como variáveis de ambiente:

```text
ConnectionStrings__DefaultConnection
Jwt__Key
```

O deploy usa o arquivo `backend/Bookcase.Api/Dockerfile`.

Mais detalhes estão em `backend/README.md`.

## 7. Estrutura do código

```text
bookcase_app/
├── android/                         configuração Android
├── backend/
│   ├── Bookcase.slnx                solução .NET
│   └── Bookcase.Api/
│       ├── Controllers/             endpoints REST
│       ├── Data/                    contexto do Entity Framework
│       ├── Dtos/                    objetos de entrada e saída
│       ├── Migrations/              histórico do banco
│       ├── Models/                  entidades do backend
│       ├── Program.cs               configuração e pipeline da API
│       └── Dockerfile               build para deploy
├── ios/                             configuração iOS
├── lib/
│   ├── core/
│   │   ├── config/                  URL e configurações da API
│   │   └── theme/                   cores, sombras e decorações
│   ├── features/
│   │   ├── auth/                    login, cadastro e sessão
│   │   ├── book_details/            detalhes do livro
│   │   ├── dashboard/               tela inicial
│   │   ├── goals/                   metas de leitura
│   │   ├── my_bookshelf/            estante, estado e ações
│   │   ├── profile_page/            perfil
│   │   ├── search_books/            busca de livros
│   │   ├── settings_page/           configurações da conta
│   │   ├── shopping_list/           lista de compras
│   │   └── streak/                  sequência de leitura
│   ├── models/                      modelos de dados
│   ├── shared/
│   │   ├── service/                 serviços HTTP compartilhados
│   │   └── widgets/                 componentes reutilizáveis
│   ├── app.dart                     tema e navegação principal
│   └── main.dart                    inicialização e restauração da sessão
├── test/                            testes automatizados
├── pubspec.yaml                     dependências e configuração Flutter
└── README.md                        documentação do projeto
```

### Separação de responsabilidades

- **Pages e widgets:** apresentam a interface e recebem ações do usuário.
- **Services:** concentram comunicação HTTP e serialização.
- **Models:** representam livros, metas, itens de compra e usuário.
- **Stores e notifiers:** mantêm o estado reativo e notificam a interface.
- **SharedPreferences:** persiste sessão, progresso e sequência de leitura.
- **Backend:** valida o usuário, aplica regras e persiste os dados no PostgreSQL.

## 8. Observações

### Limitações e pendências conhecidas


1. O serviço gratuito do Render pode levar alguns segundos para responder após um período sem uso.
2. O aplicativo depende de internet e não oferece modo offline completo para estante, metas e compras.


