import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/meetings/entities/meeting_creation_dto.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/meetings/meetings_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/core/view_models/async_change_notifier.dart';
import 'package:booklub/utils/geo/types/latlng.dart';
import 'package:booklub/utils/validation/input_validators.dart';
import 'package:booklub/utils/validation/input_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:booklub/utils/logger/app_logger.dart';

class CreateMeetingViewModel extends AsyncChangeNotifier<void> {
  final Logger log = AppLogger.create();

  final AuthRepository authRepository;
  final MeetingsRepository meetingsRepository;
  final BookApiRepository bookApiRepository;
  final ReadingGoalsRepository readingGoalsRepository;

  final InputValidators inputValidators = InputValidators();

  late final InputWrapper addressInput;
  late final InputWrapper bookTitleInput;
  late final InputWrapper dateTextInput;
  late final InputWrapper timeTextInput;

  late final ValueNotifier<DateTime?> dateInput;
  late final ValueNotifier<LatLng?> latlngInput;
  late final ValueNotifier<TimeOfDay?> timeInput;

  BookItem? selectedBookItem;
  bool created = false;

  @override
  void get payload {
    return;
  }

  CreateMeetingViewModel({
    required this.authRepository,
    required this.meetingsRepository,
    required this.bookApiRepository,
    required this.readingGoalsRepository,
  }) {
    addressInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    addressInput.addListener(notifyListeners);

    bookTitleInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    bookTitleInput.addListener(notifyListeners);

    dateTextInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    )..addListener(notifyListeners);

    timeTextInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    )..addListener(notifyListeners);

    latlngInput = ValueNotifier(null);
    latlngInput.addListener(notifyListeners);

    dateInput = ValueNotifier(null)..addListener(notifyListeners);
    timeInput = ValueNotifier(null)..addListener(notifyListeners);
  }

  void updateLatLng(LatLng? latlng) {
    latlngInput.value = latlng;
  }

  void setDate(DateTime? selectedDate) {
    if (selectedDate != null) {
      dateInput.value = selectedDate;
      dateTextInput.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    }
  }

  void setTime(TimeOfDay? selectedTime, BuildContext context) {
    if (selectedTime != null) {
      timeInput.value = selectedTime;
      timeTextInput.text = selectedTime.format(context);
    }
  }

  bool get isValid {
    return addressInput.isValid &&
        dateInput.value != null &&
        timeInput.value != null;
  }

  Future<void> searchBookByTitle() async {
    final title = bookTitleInput.text;
    if (title.isEmpty) return;

    try {
      final paginator = await bookApiRepository.searchBooks(intitle: title);
      final page = await paginator[0];

      if (page.content.isNotEmpty) {
        selectedBookItem = page.content.first;
        bookTitleInput.text = selectedBookItem!.title;
      } else {
        selectedBookItem = null;
      }
    } catch (e, stackTrace) {
      log.e(
        'Erro ao buscar livro por título',
        error: e,
        stackTrace: stackTrace,
      );
      selectedBookItem = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createMeeting(String clubId) async {
    final authData = await authRepository.getAuthData();
    if (authData == null) throw Exception('User não autenticado');

    if (!isValid) {
      log.w('Dados inválidos para criar meeting');
      return false;
    }

    super.isLoading = true;
    notifyListeners();

    try {
      final readingGoal = await readingGoalsRepository
          .findClubCurrentReadingGoal(clubId);

      final meetingCreationDto = MeetingCreationDto(
        readingGoalId: readingGoal.id,
        address: addressInput.text.trim(),
        latlng: latlngInput.value ?? LatLng(latitude: 0, longitude: 0),
      );

      final meeting = await meetingsRepository.createMeeting(meetingCreationDto);

      log.i('Encontro criado: ${meeting.id}');
      created = true;
      return true;
    } catch (e, stackTrace) {
      log.e('Erro ao criar meeting', error: e, stackTrace: stackTrace);
      created = false;
      return false;
    } finally {
      super.isLoading = false;
      notifyListeners();
    }
  }
}
