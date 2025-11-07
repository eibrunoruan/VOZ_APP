import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email é obrigatório';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  Future<void> _handleRequestReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.requestPasswordReset(_emailController.text.trim());

      if (!mounted) return;
      context.push(
        '/validate-reset-code',
        extra: {'email': _emailController.text.trim()},
      );
    } on NetworkException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Erro de conexão. Verifique sua internet');
    } on UnknownAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Erro inesperado. Tente novamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const AuthHeader(
                    title: 'Esqueci minha senha',
                    subtitle:
                        'Digite seu email para receber o código de recuperação',
                  ),

                  const SizedBox(height: AppSizes.spacing40),

                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Digite seu email cadastrado',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _handleRequestReset(),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      AuthLoadingButton(
                        onPressed: _handleRequestReset,
                        text: 'Seguir',
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      AuthLoadingButton(
                        onPressed: () => context.pop(),
                        text: 'Voltar',
                        isPrimary: false,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
