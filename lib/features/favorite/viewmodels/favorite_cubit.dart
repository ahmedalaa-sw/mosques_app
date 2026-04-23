import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/features/favorite/repo/favorite_repo.dart';

import 'favorite_states.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRepo _repo;
  StreamSubscription? _favoritesSubscription;

  FavoriteCubit({FavoriteRepo? repo})
      : _repo = repo ?? FavoriteRepo.instance,
        super(FavoriteInitial());

  Future<void> loadFavorites() async {
    emit(FavoriteLoading());
    await _favoritesSubscription?.cancel();
    _favoritesSubscription = _repo.watchFavorites().listen(
      (favorites) => emit(FavoriteSuccess(favorites)),
      onError: (Object error, StackTrace stackTrace) {
        emit(FavoriteError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
