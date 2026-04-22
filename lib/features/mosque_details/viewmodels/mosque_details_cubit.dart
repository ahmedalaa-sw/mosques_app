import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/mosque_detail_model.dart';
import '../repo/mosque_details_repo.dart';
import 'mosque_details_state.dart';

class MosqueDetailsCubit extends Cubit<MosqueDetailsState> {
  final MosqueDetailsRepo _repo;

  MosqueDetailsCubit(this._repo) : super(MosqueDetailsInitial());

  Future<void> loadMosqueDetails(String mosqueId) async {
    emit(MosqueDetailsLoading());
    try {
      final mosque = await _repo.fetchMosqueDetails(mosqueId);
      emit(MosqueDetailsSuccess(mosque));
    } catch (e) {
      emit(MosqueDetailsError(e.toString()));
    }
  }

  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! MosqueDetailsSuccess) return;

    final updated = current.mosque.copyWith(isFavorite: !current.mosque.isFavorite);
    emit(MosqueDetailsSuccess(updated));

    await _repo.toggleFavorite(updated.id, isFavorite: updated.isFavorite);
  }

  MosqueDetailModel? get mosque =>
      state is MosqueDetailsSuccess ? (state as MosqueDetailsSuccess).mosque : null;
}
