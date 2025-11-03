import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/register_request_model.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/theme/app_theme.dart';

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

  // Controle de etapas
  int _currentStep = 0;
  final int _totalSteps = 4;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome de usuário é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome de usuário deve ter pelo menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Use apenas letras, números e underscore';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  // Navegação entre steps
  void _nextStep() {
    // Validar o campo atual antes de avançar
    bool isValid = false;

    switch (_currentStep) {
      case 0: // Nome
        isValid = _validateFirstName(_firstNameController.text) == null;
        if (!isValid) {
          _showErrorDialog('Por favor, digite um nome válido');
          return;
        }
        break;
      case 1: // Nome de Usuário
        isValid = _validateUsername(_usernameController.text) == null;
        if (!isValid) {
          _showErrorDialog('Por favor, digite um nome de usuário válido');
          return;
        }
        break;
      case 2: // Email
        isValid = _validateEmail(_emailController.text) == null;
        if (!isValid) {
          _showErrorDialog('Por favor, digite um email válido');
          return;
        }
        break;
      case 3: // Senha e Confirmar Senha
        final passwordValid =
            _validatePassword(_passwordController.text) == null;
        final confirmValid =
            _validateConfirmPassword(_confirmPasswordController.text) == null;
        isValid = passwordValid && confirmValid;
        if (!isValid) {
          if (!passwordValid) {
            _showErrorDialog(
              'A senha deve ter pelo menos 8 caracteres, com maiúscula, minúscula e número',
            );
          } else {
            _showErrorDialog('As senhas não coincidem');
          }
          return;
        }
        // Última etapa - fazer o registro
        _handleRegister();
        return;
    }

    if (isValid && _currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.primaryRed, size: 28),
            const SizedBox(width: AppSizes.spacing12),
            const Text(
              'Erro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppButtonStyles.text,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validate form
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

      // Navigate to verify email screen with email and name
      context.go(
        '/verify-email',
        extra: {
          'email': _emailController.text.trim(),
          'name': _firstNameController.text.trim(),
        },
      );
    } on EmailAlreadyExistsException {
      if (mounted) {
        _showErrorDialog('Este email já está cadastrado');
      }
      setState(() {
        _isLoading = false;
      });
    } on UsernameAlreadyExistsException {
      if (mounted) {
        _showErrorDialog('Este nome de usuário já está em uso');
      }
      setState(() {
        _isLoading = false;
      });
    } on NetworkException {
      if (mounted) {
        _showErrorDialog('Erro de conexão. Verifique sua internet');
      }
      setState(() {
        _isLoading = false;
      });
    } on UnknownAuthException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erro inesperado. Tente novamente');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(
              right: index < _totalSteps - 1 ? AppSizes.spacing8 : 0,
            ),
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? AppColors.primaryRed
                  : AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildUsernameStep();
      case 2:
        return _buildEmailStep();
      case 3:
        return _buildPasswordStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildNameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qual é o seu nome?', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSizes.spacing8),
        const Text(
          'Como você gostaria de ser chamado?',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSizes.spacing40),
        const Text('Nome', style: AppTextStyles.label),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _firstNameController,
          decoration: AppInputDecoration.standard(hintText: 'Digite seu nome'),
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofocus: true,
          onFieldSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha um nome de usuário',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSizes.spacing8),
        const Text(
          'Seu identificador único no app',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSizes.spacing40),
        const Text('Nome de Usuário', style: AppTextStyles.label),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _usernameController,
          decoration: AppInputDecoration.standard(
            hintText: 'Digite seu nome de usuário',
          ),
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofocus: true,
          onFieldSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qual é o seu email?', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSizes.spacing8),
        const Text(
          'Usaremos para verificar sua conta',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSizes.spacing40),
        const Text('Email', style: AppTextStyles.label),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _emailController,
          decoration: AppInputDecoration.standard(hintText: 'Digite seu email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofocus: true,
          onFieldSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Crie sua senha', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSizes.spacing8),
        const Text(
          'Mínimo 8 caracteres com maiúscula, minúscula e número',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: AppSizes.spacing40),
        const Text('Senha', style: AppTextStyles.label),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _passwordController,
          decoration: AppInputDecoration.standard(hintText: 'Digite sua senha')
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.grey,
                    size: AppSizes.iconSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofocus: true,
        ),
        const SizedBox(height: AppSizes.spacing20),
        const Text('Confirmar Senha', style: AppTextStyles.label),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _confirmPasswordController,
          decoration:
              AppInputDecoration.standard(
                hintText: 'Digite sua senha novamente',
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.grey,
                    size: AppSizes.iconSize,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onFieldSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão Voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                    onPressed: _previousStep,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  // Barra de progresso das etapas
                  _buildStepIndicator(),

                  const SizedBox(height: AppSizes.spacing40),

                  // Conteúdo da etapa atual
                  Expanded(
                    child: SingleChildScrollView(child: _buildStepContent()),
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  // Botões de navegação
                  Column(
                    children: [
                      // Botão Continuar/Cadastrar
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextStep,
                          style: AppButtonStyles.primary.copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.disabled)
                                  ? AppColors.primaryRed.withOpacity(0.6)
                                  : AppColors.primaryRed,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _currentStep == _totalSteps - 1
                                      ? 'Cadastrar'
                                      : 'Continuar',
                                ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.spacing16),

                      // Link para Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já tem conta? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.black,
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
