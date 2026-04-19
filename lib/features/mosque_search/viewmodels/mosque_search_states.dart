import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

abstract class MosqueSearchState {}

class MosqueSearchInitial extends MosqueSearchState {}

class MosqueSearchLoading extends MosqueSearchState {}

class MosqueSearchSuccess extends MosqueSearchState {
  final List<MosqueModel> mosques;
  MosqueSearchSuccess(this.mosques);
}

class MosqueSearchError extends MosqueSearchState {
  final String message;
  MosqueSearchError(this.message);
}
