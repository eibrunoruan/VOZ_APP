import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifiers/auth_notifier.dart';

class GuestSettingsScreen extends ConsumerStatefulWidget {
  const GuestSettingsScreen({super.key});

  @override
  ConsumerState<GuestSettingsScreen> createState() =>
      _GuestSettingsScreenState();
}

class _GuestSettingsScreenState extends ConsumerState<GuestSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentNickname = ref.read(authNotifierProvider).guestNickname ?? '';
    _nicknameController = TextEditingController(text: currentNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Apelido é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Apelido deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > 20) {
      return 'Apelido deve ter no máximo 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s._-]+$').hasMatch(value)) {
      return 'Apelido contém caracteres inválidos';
    }
    return null;
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nickname = _nicknameController.text.trim();
      await ref
          .read(authNotifierProvider.notifier)
          .updateGuestNickname(nickname);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apelido atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela anterior
      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar apelido: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCreateAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Conta'),
        content: const Text(
          'Ao criar uma conta, você terá acesso a recursos completos como:\n\n'
          '• Editar e excluir suas denúncias\n'
          '• Acompanhar suas denúncias\n'
          '• Receber notificações\n'
          '• Perfil personalizado\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Criar Conta'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.go('/register');
    }
  }

  Future<void> _handleClearSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Modo Visitante'),
        content: const Text(
          'Tem certeza que deseja sair?\n\n'
          'Seu apelido será removido, mas você poderá entrar como visitante novamente depois.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Visitante'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Status Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.blue.shade700,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modo Visitante',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authState.guestNickname ?? 'Sem apelido',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Apelido
                const Text(
                  'Seu Apelido',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este nome será exibido nas suas denúncias e comentários',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Nickname field
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Apelido',
                    hintText: 'Digite seu apelido',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                    helperText: '3 a 20 caracteres',
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  validator: _validateNickname,
                ),
                const SizedBox(height: 16),

                // Update button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Atualizar Apelido'),
                ),
                const SizedBox(height: 32),

                const Divider(),
                const SizedBox(height: 16),

                // Section: Upgrade
                const Text(
                  'Quer Mais Recursos?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Create account card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Crie uma Conta Completa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Editar e excluir suas denúncias\n'
                          '• Acompanhar o status das suas denúncias\n'
                          '• Receber notificações de atualizações\n'
                          '• Perfil personalizado\n'
                          '• Histórico completo',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _handleCreateAccount,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Criar Conta Grátis'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Divider(),
                const SizedBox(height: 16),

                // Section: Sair
                const Text(
                  'Sessão',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Clear session button
                OutlinedButton.icon(
                  onPressed: _handleClearSession,
                  icon: const Icon(Icons.exit_to_app, color: Colors.red),
                  label: const Text(
                    'Sair do Modo Visitante',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),

                // Info text
                Text(
                  'Seus dados estão salvos no dispositivo de forma segura e permanente.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
