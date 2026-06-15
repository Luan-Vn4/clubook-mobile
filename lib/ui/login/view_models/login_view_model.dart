import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/utils/validation/input_validators.dart';
import 'package:booklub/utils/validation/input_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:booklub/utils/logger/app_logger.dart';

class LoginViewModel extends ChangeNotifier {

  final log = AppLogger.create();

  final AuthRepository authRepository;

  final InputValidators inputValidators;

  late final InputWrapper usernameInput;

  late final InputWrapper passwordInput;

  LoginViewModel({
    required this.authRepository,
    required this.inputValidators
  }) {
    usernameInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    usernameInput.addListener(notifyListeners);

    passwordInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validatePassword,
    );
    passwordInput.addListener(notifyListeners);
  }

  Future<bool> login() async {
    final inputs = [usernameInput, passwordInput];

    final invalidInputs = inputs.where((input) => !input.isValid);

    if (invalidInputs.isNotEmpty) {
      log.d('Invalid inputs: $invalidInputs');
      return false;
    }

    final authData = await authRepository.login(
      usernameInput.text,
      passwordInput.text
    );

    await authRepository.saveAuthData(authData);
    log.d('Login do usuário ${authData.user.username} realizado com sucesso!');
    return true;
  }

}