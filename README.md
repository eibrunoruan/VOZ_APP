# 📱 Voz do Povo - Flutter App= # Voz do Povo - Aplicativo Flutter



Aplicativo móvel para conectar cidadãos e gestão pública através de denúncias georreferenciadas.Este é o aplicativo móvel para o projeto Voz do Povo, uma plataforma para conectar cidadãos e a gestão pública.



**Status:** 25% concluído (Autenticação 100% + Infraestrutura 100%)  ---

**Próxima Feature:** Home com Mapa Interativo

## 📚 DOCUMENTAÇÃO

---

### 🎯 COMEÇE AQUI

## 🚀 Quick Start- 📄 **[INDICE_GERAL.md](INDICE_GERAL.md)** - Índice de toda a documentação

- 📄 **[RESUMO_EXECUTIVO.md](RESUMO_EXECUTIVO.md)** - O que foi feito e o que falta (10 min)

### Pré-requisitos- 📄 **[DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md)** - Documentação técnica completa (30 min)

- 📄 **[LEVANTAMENTO_COMPLETO.md](LEVANTAMENTO_COMPLETO.md)** - Lista de arquivos implementados (20 min)

- Flutter 3.9.0+

- Dart 3.9.0+### 📖 REFERÊNCIAS

- Android Studio / VS Code- 📄 **[REQUISITOS_UI_UX.md](REQUISITOS_UI_UX.md)** - Especificações de design

- Dispositivo Android físico ou emulador- 📄 **[GUIA-FLUTTER.MD](GUIA-FLUTTER.MD)** - Guia de arquitetura e padrões

- Backend Django rodando- 📄 **[COMANDOS_UTEIS.md](COMANDOS_UTEIS.md)** - Comandos úteis Flutter/Django



### Instalação---



```bash## 🚀 Quick Start

# 1. Clone o repositório

git clone <url-do-repositorio>### Pré-requisitos

cd voz_do_povo_flutter- Flutter 3.9.0+

- Dart 3.9.0+

# 2. Instale as dependências- Dispositivo Android físico ou emulador

flutter pub get- Backend Django rodando



# 3. Execute o app### Instalação

flutter run

```1. **Clone o repositório**

```bash

### Configurar Backendgit clone <url-do-repositorio>

cd voz_do_povo_flutter

**Para Emulador:**```

```dart

// lib/config/dio/dio_client.dart2. **Instale as dependências**

const String baseUrl = 'http://10.0.2.2:8000';  // Android Emulator```bash

```flutter pub get

```

**Para Dispositivo Físico:**

```bash3. **Configure o Backend**

# 1. Descubra seu IP local   - Certifique-se de que o backend está rodando em `http://192.168.1.10:8000`

ipconfig  # Windows   - Veja [USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md) para configuração

ifconfig  # Linux/Mac

4. **Execute o app**

# 2. Inicie o backend no IP da rede```bash

python manage.py runserver 0.0.0.0:8000flutter run

```

# 3. Atualize o baseUrl no app

// lib/config/dio/dio_client.dart---

const String baseUrl = 'http://SEU_IP:8000';  // Ex: http://192.168.1.10:8000

## ✅ O Que Está Pronto

# 4. Conecte o dispositivo na mesma rede Wi-Fi

# 5. Habilite Depuração USB no celular### Sistema de Autenticação (100%)

# 6. Execute: flutter run- ✅ Login com JWT tokens

```- ✅ Cadastro de usuário

- ✅ Verificação de email (código 5 dígitos)

---- ✅ Reset de senha (3 etapas)

- ✅ Modo visitante com apelido persistente

## 📱 Testar no Celular- ✅ Auto-restauração de sessão



### Android (Samsung A32 / Outros)### Infraestrutura (100%)

- ✅ Clean Architecture implementada

```bash- ✅ Riverpod para state management

# 1. Habilitar modo desenvolvedor- ✅ Dio client com interceptors

# Configurações > Sobre o telefone > Toque 7x em "Número da versão"- ✅ FlutterSecureStorage para persistência

- ✅ GoRouter com guards de autenticação

# 2. Habilitar depuração USB- ✅ 7 exceções customizadas

# Configurações > Opções do desenvolvedor > Depuração USB

**Total:** 10 telas, ~5.000 linhas de código, 0 erros

# 3. Conectar via USB

# Conecte o cabo USB ao computador---



# 4. Verificar dispositivos## 🔴 O Que Falta

flutter devices

### Próxima Feature: Home com Mapa (PRIORIDADE #1)

# 5. Executar no dispositivo- 🔴 Google Maps integrado

flutter run -d <DEVICE_ID>- 🔴 Marcadores de denúncias

```- 🔴 Bottom Navigation Bar

- 🔴 Bottom sheet de preview

### Troubleshooting- 🔴 Barra de pesquisa



**Erro "Connection refused":**### Demais Features

- Backend deve estar em IP local (192.168.1.10), não localhost- 🔴 Criar denúncia com fotos

- Celular e computador na mesma rede Wi-Fi- 🔴 Detalhes da denúncia

- Firewall pode estar bloqueando- 🔴 Sistema de comentários

- 🔴 Perfil do usuário

**Erro "Unauthorized device":**- 🔴 Minhas denúncias

- Aceitar prompt de autorização no celular

- Reinstalar drivers USB (Windows)**Progresso Total:** 25% ████░░░░░░░░░░░░░░░░



**App não conecta ao backend:**---

- Verificar baseUrl no dio_client.dart

- Testar backend no navegador do celular: http://SEU_IP:8000/api/health/## 🏗️ Arquitetura

- Verificar se backend está rodando em 0.0.0.0:8000

O projeto segue **Clean Architecture** com organização **Feature-First**:

---

```

## 🏗️ Estrutura do Projetolib/

├── main.dart

```├── config/          # Configurações (Dio, Router, Env)

lib/├── core/            # Código compartilhado (Exceptions, Widgets)

├── main.dart                   # Entry point└── features/

├── config/    └── autenticacao/  # Feature completa

│   ├── dio/                    # HTTP Client (Dio)        ├── data/        # Models, Datasources, Repositories

│   ├── env/                    # Environment variables        └── presentation/ # Notifiers, Views

│   └── router/                 # Navegação (GoRouter)```

├── core/

│   └── exceptions/             # Exceções customizadas---

└── features/

    └── autenticacao/           # ✅ COMPLETO (10 telas)## 🧪 Testes

        ├── data/

        │   ├── datasources/    # API calls```bash

        │   ├── models/         # Data models# Rodar testes

        │   └── repositories/   # Business logicflutter test

        └── presentation/

            ├── notifiers/      # State management (Riverpod)# Rodar testes com coverage

            └── views/          # UI (Screens)flutter test --coverage

``````



---**Status:** Testes não implementados (0%)



## ✅ Features Implementadas---



### 🔐 Autenticação (100%)## 📱 Testar em Dispositivo Físico



- ✅ **Login** - JWT com access + refresh tokensVeja o guia completo: **[USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md)**

- ✅ **Cadastro** - Com validação em tempo real

- ✅ **Verificação de Email** - Código de 5 dígitos1. Conecte o dispositivo via USB

- ✅ **Esqueci Senha** - Fluxo em 3 etapas (request → validate → set)2. Habilite depuração USB

- ✅ **Modo Visitante** - Apelido persistente sem cadastro3. Backend em IP local (192.168.1.10)

- ✅ **Auto-restauração** - Sessão persiste ao fechar app4. Mesma rede Wi-Fi



**Telas:** 10/10  ---

**Linhas de código:** ~2.500  

**Endpoints:** 8 integrados## 🐛 Depuração



### 🗄️ Persistência (100%)Veja: **[LOGS_README.md](LOGS_README.md)**



- ✅ **FlutterSecureStorage** - Criptografia nativaOs logs do Dio mostram:

- ✅ **Dados permanentes** - Persiste após fechar app/reiniciar- 🌐 REQUEST - Requisições enviadas

- ✅ **3 keys:** access_token, refresh_token, guest_nickname- ✅ SUCCESS - Respostas bem-sucedidas

- ❌ ERROR - Erros detalhados

### 🌐 Networking (100%)- ⛔ 403 - Problemas de autenticação



- ✅ **Dio Client** - Configurado com interceptors---

- ✅ **Base URL:** http://192.168.1.10:8000

- ✅ **Logging detalhado** - REQUEST, SUCCESS, ERROR## 📊 Progresso por Feature

- ✅ **Whitelist** - 7 endpoints públicos (sem token)

- ✅ **Error handling** - 7 exceções customizadas| Feature | Status | Progresso |

|---------|--------|-----------|

### 🎛️ State Management (100%)| Autenticação | ✅ Completo | 100% |

| Home com Mapa | 🔴 Não iniciado | 0% |

- ✅ **Riverpod 2.5.1** - AuthNotifier com 12 métodos| Criar Denúncia | 🔴 Não iniciado | 0% |

- ✅ **AuthState** - isLoggedIn, isGuest, guestNickname| Detalhes | 🔴 Não iniciado | 0% |

- ✅ **Auto-load** - Restaura sessão ao iniciar| Perfil | 🔴 Não iniciado | 0% |



### 🗺️ Navegação (100%)---



- ✅ **GoRouter 13.2.0** - 11 rotas implementadas## 🤝 Contribuindo

- ✅ **Guards** - Autenticação em rotas protegidas

- ✅ **Redirect logic** - Não autenticado → Welcome, Autenticado → Home1. Leia **[GUIA-FLUTTER.MD](GUIA-FLUTTER.MD)** para padrões de código

2. Leia **[DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md)** para contexto

---3. Crie uma branch para sua feature

4. Faça commit das mudanças

## 🔴 Próximas Features5. Abra um Pull Request



### 1. Home com Mapa (PRÓXIMA - 5-6 dias)---

- 🔴 Google Maps integrado

- 🔴 Marcadores de denúncias por status## 📄 Licença

- 🔴 Bottom Navigation Bar customizada

- 🔴 Bottom sheet de preview[Adicionar licença aqui]

- 🔴 Barra de pesquisa flutuante

---

### 2. Criar Denúncia (5-6 dias)

- 🔴 Formulário multi-step## 📞 Contato

- 🔴 Upload de fotos (câmera/galeria)

- 🔴 Seleção de localização[Adicionar contato aqui]

- 🔴 Integração com modo visitante

---

### 3. Detalhes e Comentários (4-5 dias)

- 🔴 Tela de detalhes completa**Última atualização:** 01 de Novembro de 2025  

- 🔴 Sistema de apoios**Versão:** 2.0  

- 🔴 Comentários**Status:** Base sólida, pronto para features principais! 🚀



### 4. Perfil (3-4 dias)---

- 🔴 Dados do usuário

- 🔴 Minhas denúncias## 🎓 Histórico do Backend (Contexto)

- 🔴 Estatísticas

> **Nota:** O texto abaixo refere-se ao backend Django.

**Tempo estimado para MVP:** 3-4 semanas> Para documentação do app Flutter, veja os links acima.



---## O Que Foi Feito (Backend)



## 🧪 Testes1.  **Modelo de Usuário Customizado**: Foi implementado um modelo de usuário (`User`) customizado que herda do `AbstractUser` do Django. Isso permite maior flexibilidade para futuras modificações.

2.  **Gerenciador de Usuário**: Um `UserManager` customizado foi criado para gerenciar a criação de usuários e superusuários, utilizando `email` e `username` como campos principais.

```bash3.  **Ajuste no Campo `username`**: O modelo `User` e seu gerenciador foram ajustados para resolver um `TypeError` que ocorria durante a criação de um superusuário. O campo `username` foi definido como o campo de login (`USERNAME_FIELD`).

# Rodar todos os testes4.  **Estrutura de Autenticação**: Foram criadas as rotas e views básicas para registro (`/api/auth/register/`) e login (`/api/auth/login/`) de usuários usando `djangorestframework-simplejwt` para autenticação baseada em token.

flutter test5.  **API de Localidades**: Foi criada a API para consulta de estados e cidades, com rotas em `/api/localidades/`. Os dados de estados são populados via migração e os de cidades através de um comando customizado que consome a API do IBGE.



# Rodar com coverage## Como Rodar o Projeto

flutter test --coverage

1.  **Clone o Repositório** (se ainda não o fez).

# Ver coverage no navegador

genhtml coverage/lcov.info -o coverage/html2.  **Crie e Ative um Ambiente Virtual**:

open coverage/html/index.html    ```bash

```    # Crie o ambiente virtual

    python -m venv .venv

**Status atual:** Testes não implementados (0%)

    # Ative no Windows

---    .\.venv\Scripts\activate



## 📊 Progresso    # Ative no Linux/macOS

    # source .venv/bin/activate

```    ```

Autenticação:      ████████████████████ 100%

Infraestrutura:    ████████████████████ 100%3.  **Instale as Dependências**:

Home/Mapa:         ░░░░░░░░░░░░░░░░░░░░ 0%    ```bash

Criar Denúncia:    ░░░░░░░░░░░░░░░░░░░░ 0%    pip install -r requirements.txt

Detalhes:          ░░░░░░░░░░░░░░░░░░░░ 0%    ```

Perfil:            ░░░░░░░░░░░░░░░░░░░░ 0%

────────────────────────────────────────4.  **Execute as Migrações do Banco de Dados**:

TOTAL:             ████░░░░░░░░░░░░░░░░ 25%    ```bash

```    python manage.py migrate

    ```

---

5.  **Popule o Banco de Dados com Localidades**:

## 🛠️ Comandos Úteis    Execute os comandos abaixo para popular o banco de dados com os estados e cidades do Brasil.

    ```bash

### Flutter    # Popula os estados (executa a migração de dados)

    python manage.py migrate localidades

```bash

# Limpar build    # Popula as cidades (executa o comando customizado)

flutter clean    python manage.py populate_cities

    ```

# Atualizar dependências

flutter pub get6.  **Crie um Superusuário** (para acesso ao Admin):

flutter pub upgrade    ```bash

    python manage.py createsuperuser

# Verificar problemas    ```

flutter doctor    Siga as instruções no terminal para definir `username`, `email` e `password`.



# Rodar em dispositivo específico6.  **Inicie o Servidor de Desenvolvimento**:

flutter devices    ```bash

flutter run -d <DEVICE_ID>    python manage.py runserver

    ```

# Build APK    O servidor estará disponível em `http://127.0.0.1:8000/`.

flutter build apk --release

## Rotas da API

# Ver logs

flutter logsAqui estão as rotas de autenticação disponíveis e como interagir com elas.

```

---

### Backend (Django)

### Registro de Usuário

```bash

# Rodar servidor em IP local-   **Endpoint**: `POST /api/auth/register/`

python manage.py runserver 0.0.0.0:8000-   **Descrição**: Cria um novo usuário no sistema.

-   **Body (raw/json)**:

# Criar superusuário    ```json

python manage.py createsuperuser    {

        "username": "seu_username",

# Fazer migrações        "email": "seu_email@exemplo.com",

python manage.py makemigrations        "password": "sua_senha_forte",

python manage.py migrate        "first_name": "Seu Nome"

    }

# Popular banco de dados    ```

python manage.py populate_cities-   **Resposta de Sucesso (201 Created)**:

```    ```json

    {

---        "id": 1,

        "username": "seu_username",

## 🐛 Depuração        "email": "seu_email@exemplo.com",

        "first_name": "Seu Nome"

### Ver Logs Detalhados    }

    ```

O Dio Client gera logs coloridos:

---

```

🌐 REQUEST  - POST http://192.168.1.10:8000/api/auth/login/### Login de Usuário

✅ SUCCESS  - Status: 200

❌ ERROR    - Status: 403 - Token is expired-   **Endpoint**: `POST /api/auth/login/`

⛔ 403      - Token expirado ou inválido-   **Descrição**: Autentica um usuário e retorna um par de tokens JWT (acesso e atualização).

```-   **Body (raw/json)**:

    ```json

### Limpar Sessão (Debug)    {

        "username": "seu_username",

```dart        "password": "sua_senha_forte"

// No código ou via DevTools    }

final storage = FlutterSecureStorage();    ```

await storage.deleteAll();-   **Resposta de Sucesso (200 OK)**:

    ```json

// Ou usar método do AuthNotifier    {

await ref.read(authNotifierProvider.notifier).clearSession();        "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",

```        "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

    }

### Verificar Token Atual    ```



```dart---

final storage = FlutterSecureStorage();

final token = await storage.read(key: 'access_token');### Atualizar Token de Acesso

print('Token: $token');

```-   **Endpoint**: `POST /api/auth/login/refresh/`

-   **Descrição**: Gera um novo token de acesso usando um token de atualização (`refresh token`) válido.

----   **Body (raw/json)**:

    ```json

## 📚 Documentação Adicional    {

        "refresh": "seu_refresh_token_obtido_no_login"

### Para Desenvolvedores e IA    }

    ```

- **COPILOT_INSTRUCTIONS.md** - Guia completo para IA/Copilot-   **Resposta de Sucesso (200 OK)**:

  - Arquitetura detalhada    ```json

  - O que está implementado    {

  - Como implementar próximas features        "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

  - Padrões e convenções    }

  - Exemplos de código    ```



### Arquitetura---



O projeto segue **Clean Architecture** com organização **Feature-First**:### Localidades (`/api/localidades/`)



- **Data Layer:** Models, DataSources, Repositories-   `GET /api/localidades/estados/`: Retorna uma lista de todos os estados do Brasil.

- **Presentation Layer:** Notifiers (Riverpod), Views (UI)-   `GET /api/localidades/estados/{id}/`: Retorna os detalhes de um estado específico.

- **Config:** Dio, Router, Environment-   `GET /api/localidades/cidades/`: Retorna uma lista de cidades. Pode ser filtrado por estado.

- **Core:** Exceptions, Widgets, Utils compartilhados-   `GET /api/localidades/cidades/{id}/`: Retorna os detalhes de uma cidade específica.


### Fluxo de Dados

```
UI (Views)
  ↓ usa
StateNotifier (Notifiers)
  ↓ chama
Repository
  ↓ chama
DataSource
  ↓ faz requisição
Backend API
```

---

## 🤝 Contribuindo

1. Leia **COPILOT_INSTRUCTIONS.md** para entender a arquitetura
2. Crie uma branch para sua feature
3. Siga os padrões de código (Clean Architecture + Riverpod)
4. Faça commit das mudanças
5. Abra um Pull Request

### Padrões de Código

- **Nomenclatura de arquivos:** snake_case (auth_notifier.dart)
- **Classes:** PascalCase (AuthNotifier)
- **Variáveis/métodos:** camelCase (loadData)
- **Constantes:** const camelCase (const baseUrl)
- **Private:** _prefixo (_dio, _loadAuthState)

---

## 🔒 Segurança

- ✅ Tokens JWT armazenados com FlutterSecureStorage (criptografado)
- ✅ HTTPS em produção (TODO)
- ✅ Validação de entrada em todos os formulários
- ✅ Sanitização de dados antes de enviar para API
- 🔴 Refresh token automático (TODO)
- 🔴 Biometria para login (TODO)

---

## 📄 Licença

[Definir licença]

---

## 📞 Contato

[Adicionar informações de contato]

---

## 🎓 Stack Tecnológica Completa

```yaml
Frontend:
  - Flutter: 3.9.0
  - Dart: 3.9.0
  - Riverpod: 2.5.1 (State Management)
  - GoRouter: 13.2.0 (Navegação)
  - Dio: 5.4.0 (HTTP Client)
  - FlutterSecureStorage: 9.0.0 (Storage Seguro)
  - GoogleMapsFlutter: 2.5.3 (Mapas)
  - Geolocator: 11.0.0 (Geolocalização)
  - ImagePicker: 1.0.7 (Câmera/Galeria)
  - PermissionHandler: 11.3.0 (Permissões)
  - Equatable: 2.0.5 (Comparação de objetos)

Backend:
  - Django REST Framework
  - PostgreSQL
  - JWT Authentication
  - Base URL: http://192.168.1.10:8000
```

---

## 📈 Roadmap

### Fase 1: Autenticação ✅ (CONCLUÍDA)
- Login, Cadastro, Verificação Email
- Reset de Senha (3 etapas)
- Modo Visitante
- Persistência de Sessão

### Fase 2: Core Features 🔄 (EM PLANEJAMENTO)
- Home com Mapa Interativo
- Criar Denúncia com Fotos
- Detalhes da Denúncia
- Sistema de Comentários
- Perfil do Usuário

### Fase 3: Features Extras 📋 (FUTURO)
- Busca e Filtros Avançados
- Notificações Push
- Compartilhamento
- Estatísticas
- Modo Escuro

### Fase 4: Qualidade 🧪 (FUTURO)
- Testes Unitários
- Testes de Integração
- Testes de Widget
- CI/CD

---

**Última atualização:** Janeiro de 2025  
**Versão:** 3.0 CONSOLIDADO  
**Status:** Pronto para implementar features principais! 🚀

---

## ❓ FAQ

**P: O app funciona offline?**  
R: Não atualmente. Todas as funcionalidades requerem conexão com o backend.

**P: Posso usar o app sem cadastro?**  
R: Sim! Use o modo visitante. Você pode criar denúncias e comentários com um apelido.

**P: Os dados do visitante são salvos?**  
R: Sim! O apelido é salvo permanentemente no dispositivo até fazer logout.

**P: Como faço para me tornar usuário registrado depois de usar como visitante?**  
R: Vá em Configurações de Visitante → Criar Conta.

**P: O app está disponível para iOS?**  
R: Ainda não. Atualmente apenas Android. iOS planejado para o futuro.

**P: Como reportar bugs?**  
R: [Adicionar link para issues do GitHub]

---

🎉 **Pronto para começar! Rode `flutter run` e explore o app.**
