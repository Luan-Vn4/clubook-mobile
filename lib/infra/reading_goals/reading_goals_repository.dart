import 'dart:convert';
import 'dart:io';

import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_creation_dto.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/utils/pagination/page.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:http/http.dart' as http;

class ReadingGoalException implements Exception {
  final String message;

  ReadingGoalException(this.message);

  @override
  String toString() => 'ReadingGoalException: $message';
}

class ReadingGoalsRepository {

  final AuthRepository _authRepository;

  final String _apiUrl;

  ReadingGoalsRepository({
    required AuthRepository authRepository,
    required String apiUrl
  }): _authRepository = authRepository, _apiUrl = apiUrl;

  Future<ReadingGoal> createReadingGoal(CreateReadingGoalDto readingGoal, String clubId) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId/reading-goals');

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
      body: jsonEncode(readingGoal.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao criar reading goal');
    }

    return ReadingGoal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Paginator<ReadingGoal>> findReadingGoalsByClubId(
    String clubId,
    int pageSize,
  ) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    return Paginator.create(pageSize, (page, pageSize) async {
      final uri = Uri.parse(
        '$_apiUrl/api/v1/clubs/$clubId/reading-goals'
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'size': pageSize.toString(),
        }
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
          HttpHeaders.authorizationHeader: authToken.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar reading goals do clube com ID $clubId');
      }

      return Page<ReadingGoal>.fromJson(
        jsonDecode(response.body),
        (json) => ReadingGoal.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  Future<ReadingGoal> findById(String readingGoalId) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    final uri = Uri.parse('$_apiUrl/api/v1/reading-goals/$readingGoalId');

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar reading goal com ID $readingGoalId');
    }

    return ReadingGoal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ReadingGoal> findClubCurrentReadingGoal(String clubId) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/clubs/$clubId/reading-goals/current',
    );

    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Nenhuma leitura atual encontrada para o clube $clubId',
      );
    }

    return ReadingGoal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Owner-only: marks the reading goal finished and saves the owner's review.
  Future<ReadingGoal> finishReadingGoal(
    String readingGoalId, {
    required int rating,
    String? review,
  }) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/reading-goals/$readingGoalId/finish',
    );

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
      body: jsonEncode({'rating': rating, 'review': review}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReadingGoalException(_reviewErrorMessage(response.statusCode));
    }

    return ReadingGoal.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Members can review the book once the reading period has ended.
  Future<void> reviewReadingGoal(
    String readingGoalId, {
    required int rating,
    String? review,
  }) async {
    final authToken = (await _authRepository.getAuthData())!.token;

    final uri = Uri.parse(
      '$_apiUrl/api/v1/reading-goals/$readingGoalId/review',
    );

    final response = await http.post(
      uri,
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        HttpHeaders.authorizationHeader: authToken.toString(),
      },
      body: jsonEncode({'rating': rating, 'review': review}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ReadingGoalException(_reviewErrorMessage(response.statusCode));
    }
  }

  String _reviewErrorMessage(int statusCode) {
    if (statusCode == 403) {
      return 'Você ainda não pode avaliar este livro.';
    }
    return 'Não foi possível enviar a avaliação. Tente novamente.';
  }

}