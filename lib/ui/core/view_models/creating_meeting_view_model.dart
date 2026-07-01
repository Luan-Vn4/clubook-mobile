import 'dart:async';

import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/geocoding/gateways/geocoding_gateway.dart';
import 'package:booklub/domain/geocoding/models/geocoding_result.dart';
import 'package:booklub/domain/meetings/entities/meeting_creation_dto.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/meetings/meetings_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/clubs/meetings/widgets/reading_goal_selector.dart';
import 'package:booklub/ui/core/view_models/async_change_notifier.dart';
import 'package:booklub/utils/geo/types/latlng.dart';
import 'package:booklub/utils/logger/app_logger.dart';
import 'package:booklub/utils/validation/input_validators.dart';
import 'package:booklub/utils/validation/input_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LocationSearchState { idle, loading, results, empty, error }

class CreateMeetingViewModel extends AsyncChangeNotifier<void> {
  final Logger log = AppLogger.create();

  final AuthRepository authRepository;
  final MeetingsRepository meetingsRepository;
  final BookApiRepository bookApiRepository;
  final ReadingGoalsRepository readingGoalsRepository;
  final String _clubId;
  final GeocodingGateway _geocodingGateway;

  final InputValidators inputValidators = InputValidators();

  late final InputWrapper addressInput;
  late final InputWrapper dateTextInput;
  late final InputWrapper timeTextInput;

  late final ValueNotifier<DateTime?> dateInput;
  late final ValueNotifier<LatLng?> latlngInput;
  late final ValueNotifier<TimeOfDay?> timeInput;

  List<ReadingGoalWithBook> readingGoals = const <ReadingGoalWithBook>[];
  ReadingGoalWithBook? selectedReadingGoal;
  ReadingGoalsLoadState goalsLoadState = ReadingGoalsLoadState.idle;

  LocationSearchState _locationSearchState = LocationSearchState.idle;
  List<GeocodingResult> _locationResults = const <GeocodingResult>[];

  LocationSearchState get locationSearchState => _locationSearchState;
  List<GeocodingResult> get locationResults => _locationResults;

  Timer? _addressDebounceTimer;

  bool created = false;

  @override
  void get payload {
    return;
  }

  String get clubId => _clubId;

  CreateMeetingViewModel({
    required this.authRepository,
    required this.meetingsRepository,
    required this.bookApiRepository,
    required this.readingGoalsRepository,
    required String clubId,
    required GeocodingGateway geocodingGateway,
  })  : _clubId = clubId,
        _geocodingGateway = geocodingGateway {
    addressInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    addressInput.addListener(notifyListeners);

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

  Future<void> loadReadingGoals() async {
    goalsLoadState = ReadingGoalsLoadState.loading;
    notifyListeners();
    try {
      final paginator = await readingGoalsRepository.findReadingGoalsByClubId(
        _clubId,
        20,
      );
      final page = await paginator[0];
      final List<ReadingGoal> goals = page.content;
      if (goals.isEmpty) {
        goalsLoadState = ReadingGoalsLoadState.empty;
        readingGoals = const <ReadingGoalWithBook>[];
      } else {
        final enriched = await Future.wait(goals.map(_enrichGoal));
        readingGoals = enriched;
        goalsLoadState = ReadingGoalsLoadState.loaded;
      }
    } catch (e, stackTrace) {
      log.e('Erro ao carregar metas de leitura', error: e, stackTrace: stackTrace);
      goalsLoadState = ReadingGoalsLoadState.error;
      readingGoals = const <ReadingGoalWithBook>[];
    } finally {
      notifyListeners();
    }
  }

  Future<ReadingGoalWithBook> _enrichGoal(ReadingGoal goal) async {
    try {
      final book = await bookApiRepository.getBookById(goal.bookId);
      return ReadingGoalWithBook.fromReadingGoal(goal, book);
    } catch (e, stackTrace) {
      log.e('Erro ao enriquecer meta de leitura ${goal.id}', error: e, stackTrace: stackTrace);
      return ReadingGoalWithBook.fromReadingGoal(goal, BookItem(title: '—'));
    }
  }

  void selectReadingGoal(ReadingGoalWithBook goal) {
    selectedReadingGoal = goal;
    notifyListeners();
  }

  Future<void> searchAddress(String query) async {
    _addressDebounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      _locationSearchState = LocationSearchState.idle;
      _locationResults = const <GeocodingResult>[];
      notifyListeners();
      return;
    }
    _locationSearchState = LocationSearchState.loading;
    notifyListeners();
    _addressDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results =
            await _geocodingGateway.searchByAddress(query: trimmed);
        if (results.isEmpty) {
          _locationSearchState = LocationSearchState.empty;
          _locationResults = const <GeocodingResult>[];
        } else {
          _locationSearchState = LocationSearchState.results;
          _locationResults = results;
        }
      } catch (e, stackTrace) {
        log.e('Erro no geocoding direto', error: e, stackTrace: stackTrace);
        _locationSearchState = LocationSearchState.error;
        _locationResults = const <GeocodingResult>[];
      }
      notifyListeners();
    });
  }

  void selectLocation(GeocodingResult result) {
    latlngInput.value = LatLng(
      latitude: result.latitude,
      longitude: result.longitude,
    );
    addressInput.text = result.address;
    _locationSearchState = LocationSearchState.idle;
    _locationResults = const <GeocodingResult>[];
    notifyListeners();
  }

  void clearLocationSearch() {
    _locationSearchState = LocationSearchState.idle;
    _locationResults = const <GeocodingResult>[];
    notifyListeners();
  }

  Future<void> onMapTapped(LatLng domainLatLng) async {
    _locationSearchState = LocationSearchState.idle;
    _locationResults = const <GeocodingResult>[];
    latlngInput.value = domainLatLng;
    notifyListeners();
    try {
      final result = await _geocodingGateway.reverse(
        latitude: domainLatLng.latitude,
        longitude: domainLatLng.longitude,
      );
      if (result != null) {
        addressInput.text = result.address;
      }
    } catch (e, stackTrace) {
      log.e('Erro no geocoding reverso', error: e, stackTrace: stackTrace);
    } finally {
      notifyListeners();
    }
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

  bool get isValid =>
      addressInput.isValid &&
      dateInput.value != null &&
      timeInput.value != null &&
      selectedReadingGoal != null &&
      latlngInput.value != null;

  Future<bool> createMeeting() async {
    final authData = await authRepository.getAuthData();
    if (authData == null) throw Exception('User não autenticado');

    if (!isValid) {
      log.w('Dados inválidos para criar meeting');
      return false;
    }

    super.isLoading = true;
    notifyListeners();

    try {
      final meetingCreationDto = MeetingCreationDto(
        readingGoalId: selectedReadingGoal!.id,
        address: addressInput.text.trim(),
        latlng: latlngInput.value!,
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

  @override
  void dispose() {
    _addressDebounceTimer?.cancel();
    super.dispose();
  }
}
