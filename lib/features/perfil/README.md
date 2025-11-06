# Feature: Perfil

## 📁 Estrutura

```
perfil/
└── presentation/
    ├── pages/
    │   └── profile_page.dart          # Página principal do perfil
    └── widgets/
        ├── profile_header.dart         # Cabeçalho com foto, nome e username
        ├── edit_profile_button.dart    # Botão de editar perfil
        ├── profile_menu_item.dart      # Item de menu (Configurações, Sair)
        ├── logout_confirmation_dialog.dart  # Dialog de confirmação de logout
        └── widgets.dart                # Barrel file (exporta todos os widgets)
```

## 🎨 Componentes

### ProfilePage
Página principal do perfil que exibe:
- Header com foto, nome e username
- Botão "Editar Perfil"
- Menu de opções (Configurações, Sair)
- Informação sobre o modo (visitante ou logado)

### ProfileHeader
Widget que exibe:
- Foto de perfil circular
- Nome do usuário
- Username com @ (visitante para modo guest)

### EditProfileButton
Botão estilizado seguindo o padrão das telas de autenticação.

### ProfileMenuItem
Item de menu clicável com:
- Ícone
- Título
- Seta de navegação
- Suporte para estilo de perigo (vermelho) para ações destrutivas

### LogoutConfirmationDialog
Dialog de confirmação antes de fazer logout, com:
- Título com ícone
- Mensagem de confirmação
- Botões "Cancelar" e "Sair"

## 🔗 Rota

**Path:** `/perfil`

**Navegação:**
```dart
context.push('/perfil');
```

## 🎯 Funcionalidades

- ✅ Visualização de perfil
- ✅ Diferenciação entre usuário logado e visitante
- ✅ Navegação para configurações
- ✅ Logout com confirmação
- ⏳ Edição de perfil (TODO)

## 📐 Padrões Seguidos

- **AppColors**: Usa `primaryRed`, `white`, `black`, `grey`, `greyLight`, `error`
- **AppSizes**: Usa `spacing8`, `spacing12`, `spacing16`, `spacing24`, `spacing32`, `spacing40`, `buttonHeight`, `borderRadius`
- **AppTextStyles**: Usa `titleMedium`, `subtitle`, `body`, `button`
- **AppButtonStyles**: Usa `primary`, `secondary`

## 🧩 Separação de Responsabilidades

Cada componente tem uma única responsabilidade:
- `profile_page.dart` - Orquestração e layout geral
- `profile_header.dart` - Exibição de informações do usuário
- `edit_profile_button.dart` - Ação de editar
- `profile_menu_item.dart` - Item de menu reutilizável
- `logout_confirmation_dialog.dart` - Confirmação de logout

Esta estrutura facilita manutenção, testes e escalabilidade.
