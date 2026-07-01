import 'package:booklub/ui/core/view_models/async_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:booklub/domain/entities/books/book_club_stats.dart';
import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/entities/books/book_rating.dart';
import 'package:booklub/infra/books/book_api_repository.dart';

class BookProfileViewModel extends AsyncChangeNotifier<BookItem> {
  final BookApiRepository _bookRepository;
  final String volumeId;

  BookProfileViewModel({
    required BookApiRepository bookRepository,
    required this.volumeId,
  }) : _bookRepository = bookRepository {
    _setBook(volumeId);
  }

  BookItem? _book;

  BookClubStats? _clubStats;

  List<BookRating> _ratings = const [];

  @override
  BookItem? get payload => _book;

  BookItem? get book => payload;

  BookClubStats? get clubStats => _clubStats;

  List<BookRating> get ratings => _ratings;

  /// Average star rating across all reviews, or null if there are none.
  double? get averageRating {
    if (_ratings.isEmpty) return null;
    final sum = _ratings.fold<int>(0, (acc, r) => acc + r.rating);
    return sum / _ratings.length;
  }

  Future<void> _setBook(String volumeId) async {
    isLoading = true;
    notifyListeners();
    print('entrou no setBook com volumeId: $volumeId');
    try {
      print('entrou no try do setBook');
      final bookData = await _bookRepository.getBookById(volumeId);
      _book = bookData;
      error = null;
    } catch (e, trace) {
      print('Erro ao carregar livro: $e\nStack trace: $trace');
      error = (object: e, stackTrace: trace);
      _book = null;
    } finally {
      print('Finalizando o carregamento do livro');
      isLoading = false;
      print('Book loaded: $_book');
      notifyListeners();
    }

    // Club stats are non-critical: a failure here must not break the page.
    try {
      _clubStats = await _bookRepository.getBookClubStats(volumeId);
      notifyListeners();
    } catch (e, trace) {
      print('Erro ao carregar estatísticas: $e\nStack trace: $trace');
    }

    // Reviews are non-critical too.
    try {
      _ratings = await _bookRepository.getBookRatings(volumeId);
      notifyListeners();
    } catch (e, trace) {
      print('Erro ao carregar avaliações: $e\nStack trace: $trace');
    }
  }

  void checkBookLoaded() {
    if (_book == null) {
      throw StateError(
        'Book id '
        ' $volumeId '
        ' not loaded',
      );
    }
  }
}