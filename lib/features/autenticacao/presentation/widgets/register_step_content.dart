import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'auth_form_field.dart';
import 'auth_password_field.dart';

class RegisterStepContent extends StatelessWidget {
  final int currentStep;
  final TextEditingController firstNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onNextStep;

  const RegisterStepContent({
    super.key,
    required this.currentStep,
    required this.firstNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
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
        AuthFormField(
          controller: firstNameController,
          label: 'Nome',
          hintText: 'Digite seu nome',
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          onFieldSubmitted: (_) => onNextStep(),
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
        AuthFormField(
          controller: usernameController,
          label: 'Nome de Usuário',
          hintText: 'Digite seu nome de usuário',
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          onFieldSubmitted: (_) => onNextStep(),
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
        AuthFormField(
          controller: emailController,
          label: 'Email',
          hintText: 'Digite seu email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          onFieldSubmitted: (_) => onNextStep(),
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
        AuthPasswordField(
          controller: passwordController,
          label: 'Senha',
          hintText: 'Digite sua senha',
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
        ),
        const SizedBox(height: AppSizes.spacing20),
        AuthPasswordField(
          controller: confirmPasswordController,
          label: 'Confirmar Senha',
          hintText: 'Digite sua senha novamente',
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onFieldSubmitted: (_) => onNextStep(),
        ),
      ],
    );
  }
}
