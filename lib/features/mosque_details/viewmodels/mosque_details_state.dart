import '../models/mosque_detail_model.dart';

abstract class MosqueDetailsState {}

class MosqueDetailsInitial extends MosqueDetailsState {}

class MosqueDetailsLoading extends MosqueDetailsState {}

class MosqueDetailsSuccess extends MosqueDetailsState {
  final MosqueDetailModel mosque;
  MosqueDetailsSuccess(this.mosque);
}

class MosqueDetailsError extends MosqueDetailsState {
  final String message;
  MosqueDetailsError(this.message);
}
