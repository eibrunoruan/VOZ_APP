# Confirmation Bottom Sheet

Modal bottom sheet elegante para confirmações de ações importantes.

## 🎨 Características

- **Ocupa 50% da tela** com blur no background
- **Design minimalista** seguindo padrões do app
- **Animação suave** de entrada e saída
- **Ícone customizável** com cor variável
- **Botões de ação** (confirmar/cancelar)
- **Tipos**: Danger (vermelho) ou Primary (ações normais)

## 📦 Uso

### Importação

```dart
import 'package:voz_do_povo_flutter/core/widgets/confirmation_bottom_sheet.dart';
```

### Exemplo Básico

```dart
final confirm = await ConfirmationBottomSheet.show(
  context: context,
  title: 'Sair da Conta',
  message: 'Tem certeza que deseja sair da sua conta?',
  icon: Icons.logout,
  iconColor: AppColors.error,
  confirmText: 'Sair',
  cancelText: 'Cancelar',
  isDanger: true,
);

if (confirm == true) {
  // Usuário confirmou
}
```

### Exemplo: Ação Normal (não perigosa)

```dart
final confirm = await ConfirmationBottomSheet.show(
  context: context,
  title: 'Criar Conta',
  message: 'Deseja criar uma conta completa?',
  icon: Icons.person_add,
  iconColor: AppColors.primaryRed,
  confirmText: 'Criar Conta',
  cancelText: 'Agora Não',
  isDanger: false, // Botão vermelho se true, primaryRed se false
);
```

## 🔧 Parâmetros

| Parâmetro | Tipo | Obrigatório | Padrão | Descrição |
|-----------|------|-------------|--------|-----------|
| `context` | `BuildContext` | ✅ | - | Contexto do widget |
| `title` | `String` | ✅ | - | Título do modal |
| `message` | `String` | ✅ | - | Mensagem descritiva |
| `icon` | `IconData` | ✅ | - | Ícone a ser exibido |
| `iconColor` | `Color` | ❌ | `AppColors.error` | Cor do ícone e fundo |
| `confirmText` | `String` | ❌ | `'Confirmar'` | Texto do botão de confirmar |
| `cancelText` | `String` | ❌ | `'Cancelar'` | Texto do botão de cancelar |
| `isDanger` | `bool` | ❌ | `true` | Se true, botão vermelho (danger) |

## 🎯 Retorno

Retorna `Future<bool?>`:
- `true` - Usuário confirmou a ação
- `false` - Usuário cancelou
- `null` - Modal foi fechado sem interação (swipe down ou tap fora)

## 💡 Casos de Uso Recomendados

### Ações Perigosas (isDanger: true)
- ❌ Sair da conta
- ❌ Deletar conta
- ❌ Excluir denúncia
- ❌ Limpar dados
- ❌ Desativar notificações importantes

### Ações Normais (isDanger: false)
- ✅ Criar conta
- ✅ Trocar nickname
- ✅ Salvar alterações importantes
- ✅ Publicar denúncia
- ✅ Enviar feedback

## 🎨 Aparência

- Fundo branco com cantos arredondados (24px top)
- Handle bar cinza para indicar que pode arrastar
- Blur no background (sigmaX: 5, sigmaY: 5)
- Ícone circular de 80x80 com background colorido
- Título em 24px, preto, bold
- Mensagem em cinza com altura de linha 1.5
- Botões full-width com 56px de altura
- Espaçamento consistente com AppSizes

## 📝 Notas

- Use para ações irreversíveis ou importantes
- Sempre forneça mensagens claras sobre o que acontecerá
- Use cores apropriadas (vermelho para perigo, primário para ações normais)
- Teste o swipe down para fechar (comportamento nativo)
