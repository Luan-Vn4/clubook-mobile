import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/ui/core/widgets/buttons/purple_rounded_button.dart';
import 'package:booklub/ui/core/widgets/input_fields/named_text_field_widget.dart';
import 'package:booklub/ui/login/view_models/login_view_model.dart';
import 'package:booklub/ui/login/widgets/cadastrar_clickable_text.dart';
import 'package:booklub/ui/login/widgets/esqueceu_senha_clickable_text.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:booklub/utils/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {

  final _formKey = GlobalKey<FormState>();

  final log = AppLogger.create();

  late final LoginViewModel loginViewModel;

  LoginPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    loginViewModel = context.read<LoginViewModel>();

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: _buildLogo),
            Builder(builder: _buildForm),
            Builder(builder: _buildButtons),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      'assets/images/Booklub_logo.png',
      height: MediaQuery.sizeOf(context).height * 0.28,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        PurpleRoundedButton("Entrar", () => _onSubmit(context)),
        CadastrarClickableText(),
      ],
    );
  }

  void _onSubmit(BuildContext context) async {
    log.d('Botão Entrar clicado');
    final isValid = _formKey.currentState?.validate() ?? false;
    log.d('Formulário válido: $isValid');
    if (isValid) {
      try {
        final succeded = await loginViewModel.login();
        log.d('Login resultado: $succeded');
        if (context.mounted && succeded) context.go(Routes.home);
      } on AuthException catch (e, stack) {
        log.e('AuthException no login', error: e, stackTrace: stack);
        if (context.mounted) {
          ToastHelper.showError(context, e.message);
        }
      } on NetworkException catch (e, stack) {
        log.e('NetworkException no login', error: e, stackTrace: stack);
        if (context.mounted) {
          ToastHelper.showError(context, e.message);
        }
      } catch (e, stack) {
        log.e('Erro inesperado no login', error: e, stackTrace: stack);
        if (context.mounted) {
          ToastHelper.showError(context, 'Erro inesperado. Tente novamente.');
        }
      }
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(builder: _buildUsernameField),
          Builder(builder: _buildPasswordField),
          EsqueceuSenhaClickableText(),
        ],
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return NamedTextFieldWidget(
      label: 'Usuário',
      inputWrapper: loginViewModel.usernameInput,
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return NamedTextFieldWidget(
      label: 'Senha',
      inputWrapper: loginViewModel.passwordInput,
      hidable: true,
    );
  }



}
