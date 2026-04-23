import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import '../models/mosque_detail_model.dart';
import '../repo/mosque_details_repo.dart';
import 'mosque_details_state.dart';

class MosqueDetailsCubit extends Cubit<MosqueDetailsState> {
  final MosqueDetailsRepo _repo;
  String _lastMosqueId = '';
  MosqueModel? _preview;

  MosqueDetailsCubit(this._repo) : super(MosqueDetailsInitial());

  Future<void> loadMosqueDetails(
    String mosqueId, {
    MosqueModel? preview,
  }) async {
    final current = state;
    if (current is MosqueDetailsSuccess && current.mosque.id == mosqueId) {
      return;
    }

    _lastMosqueId = mosqueId;
    _preview = preview ?? _preview;

    if (_preview != null) {
      final previewDetails = _repo.buildPreviewDetails(_preview!);
      final isFavorite = await _repo.isFavorite(previewDetails.id);
      emit(
        MosqueDetailsSuccess(
          previewDetails.copyWith(isFavorite: isFavorite),
        ),
      );
      return;
    }

    emit(
      MosqueDetailsError(
        'Mosque details are unavailable until nearby mosques are loaded.',
      ),
    );
  }

  Future<void> retry() => loadMosqueDetails(_lastMosqueId, preview: _preview);

  Future<void> toggleFavorite() async {
    final current = state;
    if (current is! MosqueDetailsSuccess) return;

    final updated = current.mosque.copyWith(
      isFavorite: !current.mosque.isFavorite,
    );
    emit(MosqueDetailsSuccess(updated));

    await _repo.toggleFavorite(updated);
  }

  MosqueDetailModel? get mosque => state is MosqueDetailsSuccess
      ? (state as MosqueDetailsSuccess).mosque
      : null;
}
