import 'package:booklub/domain/entities/io/picked_image.dart';
import 'package:booklub/domain/entities/users/user_update_dto.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/io/io_repository.dart';
import 'package:booklub/infra/user/user_repository.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:booklub/utils/validation/input_validators.dart';
import 'package:booklub/utils/validation/input_wrapper.dart';
import 'package:flutter/material.dart';

class EditUserProfileViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final AuthRepository authRepository;
  final IORepository ioRepository;
  final InputValidators inputValidators;

  final Logger log = AppLogger.create();

  late ValueNotifier<PickedImage?> profilePicture;
  late InputWrapper firstNameInput;
  late InputWrapper lastNameInput;
  late InputWrapper birthDateInput;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  EditUserProfileViewModel({
    required this.userRepository,
    required this.authRepository,
    required this.inputValidators,
    required this.ioRepository,
  }) {
    profilePicture = ValueNotifier(null);
    profilePicture.addListener(notifyListeners);
    profilePicture.addListener(_clearError);

    firstNameInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    firstNameInput.addListener(notifyListeners);
    firstNameInput.addListener(_clearError);

    lastNameInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    lastNameInput.addListener(notifyListeners);
    lastNameInput.addListener(_clearError);

    birthDateInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    birthDateInput.addListener(notifyListeners);
    birthDateInput.addListener(_clearError);

    _initializeUserData();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _initializeUserData() async {
    final authData = await authRepository.getAuthData();

    if (authData != null) {
      final user = authData.user;

      firstNameInput.text = user.firstName;
      lastNameInput.text = user.lastName;
      birthDateInput.text = user.birthDate;

      notifyListeners();
    }
  }

  Future<void> pickProfilePicture() async {
    profilePicture.value = await ioRepository.pickImage();
  }

  Future<bool> update() async {
    _errorMessage = null;
    notifyListeners();

    final inputs = [
      firstNameInput,
      lastNameInput,
    ];

    final invalidInputs = inputs.where((input) => !input.isValid);

    if (invalidInputs.isNotEmpty) {
      log.d("Invalid inputs: $invalidInputs");
      _errorMessage = 'Preencha o nome e o sobrenome corretamente.';
      notifyListeners();
      return false;
    }

    final authData = await authRepository.getAuthData();

    if (authData == null) {
      log.d("Usuário não logado");
      _errorMessage = 'Sua sessão expirou. Faça login novamente.';
      notifyListeners();
      return false;
    }

    final birthDate = birthDateInput.text.trim();

    final dto = UserUpdateDTO(
      id: authData.user.id,
      firstName: firstNameInput.text,
      lastName: lastNameInput.text,
      birthDate: birthDate.isEmpty ? null : birthDate,
      image: profilePicture.value,
    );

    log.d("Updating user with DTO: $dto");

    try {
      await userRepository.update(dto);
      return true;
    } catch (e, stackTrace) {
      log.e('Erro ao atualizar perfil', error: e, stackTrace: stackTrace);
      _errorMessage = 'Não foi possível atualizar o perfil. Tente novamente.';
      notifyListeners();
      return false;
    }
  }
}