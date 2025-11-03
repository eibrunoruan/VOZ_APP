<div align="center"><div align="center">



# 📱 Voz do Povo# 📱 Voz do Povo



### Plataforma Mobile para Denúncias Cidadãs### Plataforma Mobile para Denúncias Cidadãs



[![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?logo=flutter)](https://flutter.dev)[![Flutter](https://img.shields.io/badge/Flutter-3.9.0+-02569B?logo=flutter)](https://flutter.dev)

[![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?logo=dart)](https://dart.dev)[![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?logo=dart)](https://dart.dev)

[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)



*Conectando cidadãos e gestão pública através de denúncias georreferenciadas**Conectando cidadãos e gestão pública através de denúncias georreferenciadas*



[Começar](#-quick-start) • [Documentação](#-documentação) • [Arquitetura](#️-arquitetura) • [Features](#-features)[Começar](#-quick-start) • [Documentação](#-documentação) • [Arquitetura](#️-arquitetura) • [Features](#-features)



</div></div>



------



## 📖 Sobre o Projeto## 📖 Sobre o Projeto



**Voz do Povo** é um aplicativo móvel desenvolvido em Flutter que permite aos cidadãos reportar problemas urbanos (buracos, iluminação, lixo, etc.) através de denúncias georreferenciadas com fotos e descrições detalhadas. A plataforma conecta a população diretamente com a gestão pública municipal.**Voz do Povo** é um aplicativo móvel desenvolvido em Flutter que permite aos cidadãos reportar problemas urbanos (buracos, iluminação, lixo, etc.) através de denúncias georreferenciadas com fotos e descrições detalhadas. A plataforma conecta a população diretamente com a gestão pública municipal.



### Status do Projeto### Status do Projeto



``````

🟢 Autenticação ████████████████████████████████████████ 100%� Autenticação ████████████████████████████████████████ 100%

🟢 Infraestrutura ████████████████████████████████████████ 100%🟢 Infraestrutura ████████████████████████████████████████ 100%

🟡 Home & Mapa ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░  30%� Home & Mapa ████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░  30%

⚪ Denúncias    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%⚪ Denúncias    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%

⚪ Perfil       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%⚪ Perfil       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%

``````



**Progresso Total:** 35% completo**Progresso Total:** 35% completo



------



## 🚀 Quick Start## 🚀 Quick Start



### Pré-requisitos### Pré-requisitos



- Flutter SDK 3.9.0 ou superior- Flutter SDK 3.9.0 ou superior

- Dart SDK 3.9.0 ou superior- Dart SDK 3.9.0 ou superior

- Android Studio / VS Code- Android Studio / VS Code

- Dispositivo Android físico ou emulador- Dispositivo Android físico ou emulador

- Backend Django rodando (veja [configuração](#configurar-backend))- Backend Django rodando (veja [configuração](#configurar-backend))



### Instalação### Instalação



```bash```bash

# 1. Clone o repositório# 1. Clone o repositório

git clone https://github.com/eibrunoruan/VOZ_APP.gitgit clone https://github.com/eibrunoruan/VOZ_APP.git

cd voz_do_povo_fluttercd voz_do_povo_flutter



# 2. Instale as dependências# 2. Instale as dependências

flutter pub getflutter pub get



# 3. Execute o aplicativo# 3. Execute o aplicativo

flutter runflutter run```

```

### Configurar Backend

### Configurar Backend

#### Para Emulador Android

#### Para Emulador Android

```dart

```dart// lib/config/dio/dio_client.dart

// lib/config/dio/dio_client.dartconst String baseUrl = 'http://10.0.2.2:8000';  // Android Emulator

const String baseUrl = 'http://10.0.2.2:8000';  // Android Emulator```

```

#### Para Dispositivo Físico

#### Para Dispositivo Físico

```bash

```bash# 1. Descubra seu IP local

# 1. Descubra seu IP localipconfig    # Windows

ipconfig    # Windowsifconfig    # Linux/Mac

ifconfig    # Linux/Mac

# 2. Inicie o backend no IP da rede

# 2. Inicie o backend no IP da redepython manage.py runserver 0.0.0.0:8000

python manage.py runserver 0.0.0.0:8000

# 3. Atualize o baseUrl no app

# 3. Atualize o baseUrl no app// lib/config/dio/dio_client.dart

// lib/config/dio/dio_client.dartconst String baseUrl = 'http://192.168.1.10:8000';  // Seu IP local

const String baseUrl = 'http://192.168.1.10:8000';  // Seu IP local

# 4. Conecte o dispositivo na mesma rede Wi-Fi

# 4. Conecte o dispositivo na mesma rede Wi-Fi# 5. Habilite Depuração USB

# 5. Habilite Depuração USB# 6. Execute: flutter run

# 6. Execute: flutter run```

```

📄 **Guia completo:** [USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md)

📄 **Guia completo:** [USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md)

---

---

## 🏗️ Arquitetura

## 🏗️ Arquitetura

Este projeto segue os princípios de **Clean Architecture** com organização **Feature-First**:

Este projeto segue os princípios de **Clean Architecture** com organização **Feature-First**:

```

```lib/

lib/├── main.dart                    # Entry point

├── main.dart                    # Entry point├── config/

├── config/│   ├── dio/                     # HTTP Client (Dio + Interceptors)

│   ├── dio/                     # HTTP Client (Dio + Interceptors)│   ├── env/                     # Environment variables

│   ├── env/                     # Environment variables│   └── router/                  # Navegação (GoRouter + Guards)

│   └── router/                  # Navegação (GoRouter + Guards)├── core/

├── core/│   ├── exceptions/              # 7 exceções customizadas

│   ├── exceptions/              # 7 exceções customizadas│   └── widgets/                 # Widgets compartilhados

│   └── widgets/                 # Widgets compartilhados└── features/

└── features/    ├── autenticacao/            # ✅ 100% Completo

    ├── autenticacao/            # ✅ 100% Completo    │   ├── data/

    │   ├── data/    │   │   ├── datasources/     # API calls

    │   │   ├── datasources/     # API calls    │   │   ├── models/          # DTOs

    │   │   ├── models/          # DTOs    │   │   └── repositories/    # Business logic

    │   │   └── repositories/    # Business logic    │   └── presentation/

    │   └── presentation/    │       ├── notifiers/       # State (Riverpod)

    │       ├── notifiers/       # State (Riverpod)    │       └── views/           # UI (10 telas)

    │       └── views/           # UI (10 telas)    ├── home/                    # 🟡 30% Em desenvolvimento

    ├── home/                    # 🟡 30% Em desenvolvimento    └── denuncias/               # ⚪ Próxima feature

    └── denuncias/               # ⚪ Próxima feature```

```

### Tecnologias e Padrões

### Tecnologias e Padrões

- **State Management:** Riverpod 2.5.1

- **State Management:** Riverpod 2.5.1- **HTTP Client:** Dio 5.4.0 com interceptors personalizados

- **HTTP Client:** Dio 5.4.0 com interceptors personalizados- **Navegação:** GoRouter 13.0.0 com guards de autenticação

- **Navegação:** GoRouter 13.0.0 com guards de autenticação- **Persistência:** FlutterSecureStorage 9.0.0 (criptografia nativa)

- **Persistência:** FlutterSecureStorage 9.0.0 (criptografia nativa)- **Mapas:** Google Maps Flutter 2.5.3

- **Mapas:** Google Maps Flutter 2.5.3- **Arquitetura:** Clean Architecture + Feature-First

- **Arquitetura:** Clean Architecture + Feature-First

---

---

## ✨ Features

## ✨ Features

### ✅ Sistema de Autenticação (100%)

### ✅ Sistema de Autenticação (100%)

- **Login** - JWT com access + refresh tokens

- **Login** - JWT com access + refresh tokens- **Cadastro** - Validação em tempo real

- **Cadastro** - Validação em tempo real- **Verificação de Email** - Código de 5 dígitos

- **Verificação de Email** - Código de 5 dígitos- **Esqueci Senha** - Fluxo em 3 etapas

- **Esqueci Senha** - Fluxo em 3 etapas- **Modo Visitante** - Apelido persistente sem cadastro

- **Modo Visitante** - Apelido persistente sem cadastro- **Auto-restauração** - Sessão persiste após fechar app

- **Auto-restauração** - Sessão persiste após fechar app

**Telas:** 10/10 | **Código:** ~2.500 linhas | **Endpoints:** 8 integrados

**Telas:** 10/10 | **Código:** ~2.500 linhas | **Endpoints:** 8 integrados

### 🟡 Home com Mapa (30%)

### 🟡 Home com Mapa (30%)

- ✅ Google Maps integrado com API Key

- ✅ Google Maps integrado com API Key- ✅ Bottom Navigation (Mapa, Denúncias, Perfil)

- ✅ Bottom Navigation (Mapa, Denúncias, Perfil)- ✅ Cards de denúncias com geocoding

- ✅ Cards de denúncias com geocoding- 🟡 Criação de denúncia (5 etapas)

- 🟡 Criação de denúncia (5 etapas)- 🟡 Marcadores no mapa

- 🟡 Marcadores no mapa- ⚪ Filtros e pesquisa

- ⚪ Filtros e pesquisa- ⚪ Bottom sheet de preview

- ⚪ Bottom sheet de preview

### ⚪ Gestão de Denúncias (0%)

### ⚪ Gestão de Denúncias (0%)

- ⚪ Criar denúncia com fotos

- ⚪ Criar denúncia com fotos- ⚪ Upload de imagens

- ⚪ Upload de imagens- ⚪ Detalhes da denúncia

- ⚪ Detalhes da denúncia- ⚪ Sistema de comentários

- ⚪ Sistema de comentários- ⚪ Acompanhamento de status

- ⚪ Acompanhamento de status

### ⚪ Perfil do Usuário (0%)

### ⚪ Perfil do Usuário (0%)

- ⚪ Editar perfil

- ⚪ Editar perfil- ⚪ Minhas denúncias

- ⚪ Minhas denúncias- ⚪ Histórico de atividades

- ⚪ Histórico de atividades- ⚪ Configurações

- ⚪ Configurações

---

---

## 📚 Documentação

## 📚 Documentação

### Guias Principais

### Guias Principais

- 📄 [INDICE_GERAL.md](INDICE_GERAL.md) - Índice completo da documentação

- 📄 [INDICE_GERAL.md](INDICE_GERAL.md) - Índice completo da documentação- 📄 [RESUMO_EXECUTIVO.md](RESUMO_EXECUTIVO.md) - Resumo executivo (10 min)

- 📄 [RESUMO_EXECUTIVO.md](RESUMO_EXECUTIVO.md) - Resumo executivo (10 min)- � [DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md) - Documentação técnica (30 min)

- 📄 [DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md) - Documentação técnica (30 min)

### Guias Técnicos

### Guias Técnicos

- 📄 [GUIA-FLUTTER.MD](GUIA-FLUTTER.MD) - Arquitetura e padrões

- 📄 [GUIA-FLUTTER.MD](GUIA-FLUTTER.MD) - Arquitetura e padrões- 📄 [REQUISITOS_UI_UX.md](REQUISITOS_UI_UX.md) - Design system

- 📄 [REQUISITOS_UI_UX.md](REQUISITOS_UI_UX.md) - Design system- � [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md) - Comandos úteis

- 📄 [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md) - Comandos úteis- 📄 [LOGS_README.md](LOGS_README.md) - Sistema de logs

- 📄 [LOGS_README.md](LOGS_README.md) - Sistema de logs

### Configuração

### Configuração

- � [USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md) - Testar em dispositivo físico

- 📄 [USAR_CELULAR_ANDROID.md](USAR_CELULAR_ANDROID.md) - Testar em dispositivo físico- � [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) - Configurar Google Maps API

- 📄 [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) - Configurar Google Maps API- 📄 [ERROS_RESOLVIDOS.md](ERROS_RESOLVIDOS.md) - Troubleshooting

- 📄 [ERROS_RESOLVIDOS.md](ERROS_RESOLVIDOS.md) - Troubleshooting

---

---

## 🧪 Testes

## 🧪 Testes

```bash

```bash# Rodar todos os testes

# Rodar todos os testesflutter test

flutter test

# Testes com coverage

# Testes com coverageflutter test --coverage

flutter test --coverage

# Análise de código

# Análise de códigoflutter analyze

flutter analyze```

```

**Status:** Testes unitários não implementados (0%)

**Status:** Testes unitários não implementados (0%)

---

---

## 📱 Testar em Dispositivo Android

## 📱 Testar em Dispositivo Android

### Configuração Rápida

### Configuração Rápida

```bash

```bash# 1. Habilitar modo desenvolvedor

# 1. Habilitar modo desenvolvedor# Configurações > Sobre o telefone > Toque 7x em "Número da versão"

# Configurações > Sobre o telefone > Toque 7x em "Número da versão"

# 2. Habilitar depuração USB

# 2. Habilitar depuração USB# Configurações > Opções do desenvolvedor > Depuração USB

# Configurações > Opções do desenvolvedor > Depuração USB

# 3. Conectar via USB e verificar

# 3. Conectar via USB e verificarflutter devices

flutter devices

# 4. Executar no dispositivo

# 4. Executar no dispositivoflutter run -d <DEVICE_ID>

flutter run -d <DEVICE_ID>```

```

### Troubleshooting

### Troubleshooting

| Erro | Solução |

| Erro | Solução ||------|---------|

|------|---------|| **Connection refused** | Backend em IP local, não localhost. Mesma rede Wi-Fi |

| **Connection refused** | Backend em IP local, não localhost. Mesma rede Wi-Fi || **Unauthorized device** | Aceitar prompt de autorização no celular |

| **Unauthorized device** | Aceitar prompt de autorização no celular || **App não conecta** | Verificar `baseUrl` em `dio_client.dart` e testar backend: `http://SEU_IP:8000/api/health/` |

| **App não conecta** | Verificar `baseUrl` em `dio_client.dart` e testar backend: `http://SEU_IP:8000/api/health/` |

---

---

## 🐛 Debug e Logs

## 🐛 Debug e Logs

O sistema de logs do Dio exibe:

O sistema de logs do Dio exibe:- 🌐 **REQUEST** - Requisições enviadas

- 🌐 **REQUEST** - Requisições enviadas- ✅ **SUCCESS** - Respostas bem-sucedidas  

- ✅ **SUCCESS** - Respostas bem-sucedidas  - ❌ **ERROR** - Erros detalhados

- ❌ **ERROR** - Erros detalhados- ⛔ **403** - Problemas de autenticação

- ⛔ **403** - Problemas de autenticação

Veja [LOGS_README.md](LOGS_README.md) para mais detalhes.

Veja [LOGS_README.md](LOGS_README.md) para mais detalhes.

---

---

## 🏗️ Estrutura do Projetolib/

## 🛠️ Stack Tecnológica

├── main.dart

| Categoria | Tecnologia | Versão |

|-----------|-----------|--------|```├── config/          # Configurações (Dio, Router, Env)

| Framework | Flutter | 3.9.0+ |

| Linguagem | Dart | 3.9.0+ |lib/├── core/            # Código compartilhado (Exceptions, Widgets)

| State Management | Riverpod | 2.5.1 |

| HTTP Client | Dio | 5.4.0 |├── main.dart                   # Entry point└── features/

| Navegação | GoRouter | 13.0.0 |

| Persistência | FlutterSecureStorage | 9.0.0 |├── config/    └── autenticacao/  # Feature completa

| Mapas | Google Maps Flutter | 2.5.3 |

| Localização | Geolocator | 11.0.0 |│   ├── dio/                    # HTTP Client (Dio)        ├── data/        # Models, Datasources, Repositories

| Geocoding | Geocoding | 3.0.0 |

│   ├── env/                    # Environment variables        └── presentation/ # Notifiers, Views

---

│   └── router/                 # Navegação (GoRouter)```

## 📈 Estatísticas do Projeto

├── core/

```

📁 Features Completas:    1/5 (20%)│   └── exceptions/             # Exceções customizadas---

📄 Telas Implementadas:   10/35 (29%)

📝 Linhas de Código:      ~5.000└── features/

🔌 Endpoints Integrados:  8

🧪 Cobertura de Testes:   0%    └── autenticacao/           # ✅ COMPLETO (10 telas)## 🧪 Testes

🐛 Bugs Conhecidos:       0

```        ├── data/



---        │   ├── datasources/    # API calls```bash



## 🗺️ Roadmap        │   ├── models/         # Data models# Rodar testes



### ✅ Fase 1 - Autenticação (Concluída)        │   └── repositories/   # Business logicflutter test

- [x] Sistema completo de autenticação

- [x] Infraestrutura base (Dio, Router, Storage)        └── presentation/

- [x] Design system e componentes reutilizáveis

            ├── notifiers/      # State management (Riverpod)# Rodar testes com coverage

### 🟡 Fase 2 - Home & Navegação (Em Andamento)

- [x] Integração Google Maps            └── views/          # UI (Screens)flutter test --coverage

- [x] Bottom Navigation

- [x] Cards de denúncias``````

- [ ] Criação de denúncia completa

- [ ] Marcadores no mapa

- [ ] Filtros e pesquisa

---**Status:** Testes não implementados (0%)

### ⚪ Fase 3 - Gestão de Denúncias

- [ ] CRUD completo de denúncias

- [ ] Upload de múltiplas fotos

- [ ] Sistema de comentários## ✅ Features Implementadas---

- [ ] Notificações push

- [ ] Acompanhamento de status## �️ Stack Tecnológica



### ⚪ Fase 4 - Perfil & Social| Categoria | Tecnologia | Versão |

- [ ] Perfil do usuário|-----------|-----------|--------|

- [ ] Minhas denúncias| Framework | Flutter | 3.9.0+ |

- [ ] Histórico de atividades| Linguagem | Dart | 3.9.0+ |

- [ ] Gamificação (pontos, badges)| State Management | Riverpod | 2.5.1 |

| HTTP Client | Dio | 5.4.0 |

### ⚪ Fase 5 - Melhorias| Navegação | GoRouter | 13.0.0 |

- [ ] Testes unitários e de integração| Persistência | FlutterSecureStorage | 9.0.0 |

- [ ] CI/CD pipeline| Mapas | Google Maps Flutter | 2.5.3 |

- [ ] Analytics| Localização | Geolocator | 11.0.0 |

- [ ] Otimizações de performance| Geocoding | Geocoding | 3.0.0 |



------



## 🤝 Contribuindo## 📈 Estatísticas do Projeto



Contribuições são bem-vindas! Para contribuir:```

📁 Features Completas:    1/5 (20%)

1. Leia [GUIA-FLUTTER.MD](GUIA-FLUTTER.MD) para entender os padrões de código📄 Telas Implementadas:   10/35 (29%)

2. Leia [DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md) para contexto do projeto📝 Linhas de Código:      ~5.000

3. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)🔌 Endpoints Integrados:  8

4. Commit suas mudanças (`git commit -m 'Add: MinhaFeature'`)🧪 Cobertura de Testes:   0%

5. Push para a branch (`git push origin feature/MinhaFeature`)🐛 Bugs Conhecidos:       0

6. Abra um Pull Request```



------



## 👥 Autores## 🗺️ Roadmap



- **Bruno Ruan** - [@eibrunoruan](https://github.com/eibrunoruan)### ✅ Fase 1 - Autenticação (Concluída)

- [x] Sistema completo de autenticação

---- [x] Infraestrutura base (Dio, Router, Storage)

- [x] Design system e componentes reutilizáveis

## 📄 Licença

### 🟡 Fase 2 - Home & Navegação (Em Andamento)

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.- [x] Integração Google Maps

- [x] Bottom Navigation

---- [x] Cards de denúncias

- [ ] Criação de denúncia completa

## 📞 Contato e Suporte- [ ] Marcadores no mapa

- [ ] Filtros e pesquisa

- 📧 Email: [contato@vozdopovo.com](mailto:contato@vozdopovo.com)

- 🐛 Issues: [GitHub Issues](https://github.com/eibrunoruan/VOZ_APP/issues)### ⚪ Fase 3 - Gestão de Denúncias

- 📖 Wiki: [GitHub Wiki](https://github.com/eibrunoruan/VOZ_APP/wiki)- [ ] CRUD completo de denúncias

- [ ] Upload de múltiplas fotos

---- [ ] Sistema de comentários

- [ ] Notificações push

<div align="center">- [ ] Acompanhamento de status



**Desenvolvido com ❤️ usando Flutter**### ⚪ Fase 4 - Perfil & Social

- [ ] Perfil do usuário

⭐ Se este projeto te ajudou, considere dar uma estrela!- [ ] Minhas denúncias

- [ ] Histórico de atividades

</div>- [ ] Gamificação (pontos, badges)


### ⚪ Fase 5 - Melhorias
- [ ] Testes unitários e de integração
- [ ] CI/CD pipeline
- [ ] Analytics
- [ ] Otimizações de performance

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Leia [GUIA-FLUTTER.MD](GUIA-FLUTTER.MD) para entender os padrões de código
2. Leia [DOCUMENTACAO_COMPLETA.md](DOCUMENTACAO_COMPLETA.md) para contexto do projeto
3. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
4. Commit suas mudanças (`git commit -m 'Add: MinhaFeature'`)
5. Push para a branch (`git push origin feature/MinhaFeature`)
6. Abra um Pull Request

---

## 👥 Autores

- **Bruno Ruan** - [@eibrunoruan](https://github.com/eibrunoruan)

---

## � Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## � Contato e Suporte

- � Email: [contato@vozdopovo.com](mailto:contato@vozdopovo.com)
- � Issues: [GitHub Issues](https://github.com/eibrunoruan/VOZ_APP/issues)
- 📖 Wiki: [GitHub Wiki](https://github.com/eibrunoruan/VOZ_APP/wiki)

---

<div align="center">

**Desenvolvido com ❤️ usando Flutter**

⭐ Se este projeto te ajudou, considere dar uma estrela!

</div>

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
