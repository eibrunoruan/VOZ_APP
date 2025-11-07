import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/register_request_model.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  final int _totalSteps = 4;

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    switch (_currentStep) {
      case 0: // Nome
        final error = RegisterValidators.validateFirstName(
          _firstNameController.text,
        );
        if (error != null) {
          AuthErrorDialog.show(context, error);
          return;
        }
        break;
      case 1: // Nome de Usuário
        final error = RegisterValidators.validateUsername(
          _usernameController.text,
        );
        if (error != null) {
          AuthErrorDialog.show(context, error);
          return;
        }
        break;
      case 2: // Email
        final error = RegisterValidators.validateEmail(_emailController.text);
        if (error != null) {
          AuthErrorDialog.show(context, error);
          return;
        }
        break;
      case 3: // Senha e Confirmar Senha
        final passwordError = RegisterValidators.validatePassword(
          _passwordController.text,
        );
        final confirmError = RegisterValidators.validateConfirmPassword(
          _confirmPasswordController.text,
          _passwordController.text,
        );
        if (passwordError != null) {
          AuthErrorDialog.show(context, passwordError);
          return;
        }
        if (confirmError != null) {
          AuthErrorDialog.show(context, confirmError);
          return;
        }

        _handleRegister();
        return;
    }

    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.go('/');
    }
  }

  Future<void> _handleRegister() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);

      final registerRequest = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        password: _passwordController.text,
      );

      await repository.register(registerRequest);

      if (!mounted) return;

      context.go(
        '/verify-email',
        extra: {
          'email': _emailController.text.trim(),
          'name': _firstNameController.text.trim(),
        },
      );
    } on EmailAlreadyExistsException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Este email já está cadastrado');
    } on UsernameAlreadyExistsException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthErrorDialog.show(context, 'Este nome de usuário já está em uso');
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
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.navbarText,
                    ),
                    onPressed: _previousStep,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  RegisterStepIndicator(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                  ),

                  const SizedBox(height: AppSizes.spacing40),

                  Expanded(
                    child: SingleChildScrollView(
                      child: RegisterStepContent(
                        currentStep: _currentStep,
                        firstNameController: _firstNameController,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        isLoading: _isLoading,
                        onNextStep: _nextStep,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  Column(
                    children: [

                      AuthLoadingButton(
                        onPressed: _nextStep,
                        text: _currentStep == _totalSteps - 1
                            ? 'Cadastrar'
                            : 'Continuar',
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: AppSizes.spacing16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem conta? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.navbarText,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/login'),
                            style: AppButtonStyles.text,
                            child: const Text('Entrar'),
                          ),
                        ],
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
