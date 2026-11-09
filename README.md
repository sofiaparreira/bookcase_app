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
| 3 | Loading e erro visíveis na interface | Atendido | Indicadores de carregamento, skeletons, estados vazios, botão de nova tentativa e alertas padronizados aparecem em busca, estante, metas e compras. Ver `lib/shared/widgets/alerts/app_alert.dart`. |
| 4 | Formulário com `Form` e `validator` | Atendido | Login, cadastro, metas, compras, edição do perfil e alteração de senha usam `GlobalKey<FormState>` e validadores. |
| 5 | Lista dinâmica com `ListView.builder` | Parcialmente atendido | As listas são dinâmicas e construídas sob demanda com `itemCount` e `itemBuilder`, mas utilizam principalmente `ListView.separated`, uma variação do mesmo padrão. Se a rubrica exigir literalmente `ListView.builder`, será necessário trocar ao menos uma ocorrência. |
| 6 | Persistência com `SharedPreferences` | Atendido | Sessão, token, e-mail, progresso local e sequência de leitura são persistidos em `lib/features/auth/auth_service.dart`, `lib/features/my_bookshelf/bookshelf_store.dart` e `lib/features/streak/streak_store.dart`. |
| 7 | Provider e separação entre telas, HTTP e preferências | Parcialmente atendido | O projeto separa telas, serviços HTTP e persistência e usa `ChangeNotifier`, `ValueNotifier` e `ListenableBuilder`. Entretanto, o pacote `provider` não está instalado e não há `ChangeNotifierProvider` ou `Consumer`. |
| 8 | Aplicativo abre e percorre o fluxo sem crashar | Atendido no fluxo principal | O projeto passa no `flutter analyze` e compila. Há uma pendência no teste geral de widgets causada por timers de sincronização e alertas que permanecem ativos após o encerramento do teste. |

### Principais evidências técnicas

- **Navegação principal:** `lib/app.dart` e `lib/shared/widgets/bottom_navigation.dart`.
- **Modelos:** `lib/models`.
- **Telas e funcionalidades:** `lib/features`.
- **Serviços HTTP:** classes `Service` dentro de `lib/features` e `lib/shared/service`.
- **Estado reativo:** `BookshelfStore`, `StreakStore`, `GoalsService.changes` e `AuthService`.
- **Persistência local:** `SharedPreferences`.
- **Listas dinâmicas:** busca, estante, metas e compras.
- **Validação:** login, cadastro, metas, compras e configurações de perfil.

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
| `POST` | `/api/book` | Sim | Adicionar livro à estante |
| `PUT` | `/api/book/{id}` | Sim | Atualizar status, progresso e avaliação |
| `DELETE` | `/api/book/{id}` | Sim | Remover livro da estante |
| `GET` | `/api/shoppinglist` | Sim | Listar itens de compra |
| `POST` | `/api/shoppinglist` | Sim | Criar item de compra |
| `PUT` | `/api/shoppinglist/{id}` | Sim | Atualizar item de compra |
| `DELETE` | `/api/shoppinglist/{id}` | Sim | Excluir item de compra |
| `GET` | `/api/readinggoal` | Sim | Listar metas |
| `POST` | `/api/readinggoal` | Sim | Criar meta |
| `PUT` | `/api/readinggoal/{id}` | Sim | Atualizar meta |
| `PATCH` | `/api/readinggoal/{id}/progress` | Sim | Atualizar progresso da meta |
| `DELETE` | `/api/readinggoal/{id}` | Sim | Excluir meta |

As rotas protegidas recebem o cabeçalho:

```http
Authorization: Bearer <token>
```

### Conta de teste

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

- Flutter **3.47.9** ou versão compatível.
- Dart **3.13.7** ou versão compatível com `sdk: ^3.13.2`.
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

O backend é uma API REST em **ASP.NET Core, C# e .NET 10**, com Entity Framework Core, PostgreSQL, autenticação JWT e documentação Swagger.

### Pré-requisitos

- .NET SDK 10.
- Acesso a um banco PostgreSQL.
- Connection string válida.
- Chave JWT com pelo menos 32 caracteres.

Verifique o SDK:

```bash
dotnet --version
```

### Instalar dependências e ferramentas

A partir da raiz do projeto:

```bash
cd backend/Bookcase.Api
dotnet restore
dotnet tool restore
```

### Configurar os secrets

Os dados sensíveis não ficam no repositório. Configure-os com `user-secrets`:

```bash
dotnet user-secrets set \
  "ConnectionStrings:DefaultConnection" \
  "Host=<host>;Port=5432;Database=postgres;Username=<usuario>;Password=<senha>;SSL Mode=Require;Trust Server Certificate=true"

dotnet user-secrets set \
  "Jwt:Key" \
  "<chave-longa-com-pelo-menos-32-caracteres>"
```

Aplique as migrations:

```bash
dotnet ef database update
```

### Subir o backend

A partir da raiz do repositório:

```bash
cd backend
dotnet run --project Bookcase.Api --launch-profile http
```

Endereços locais:

- API: `http://localhost:5094`
- Swagger: `http://localhost:5094/swagger`

Para parar o backend, pressione `Ctrl+C` no terminal em que ele estiver rodando.

### Usar o backend local no Flutter

Altere temporariamente `lib/core/config/api_config.dart`.

Para Flutter Web ou desktop na mesma máquina:

```dart
static const String baseUrl = 'http://localhost:5094';
```

Para o Android Emulator:

```dart
static const String baseUrl = 'http://10.0.2.2:5094';
```

No Android Emulator, `localhost` aponta para o próprio emulador. O endereço `10.0.2.2` redireciona para a máquina host.

Em um dispositivo físico, use o IP local do computador, permita a porta no firewall e configure o backend para escutar em uma interface acessível pela rede.


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


