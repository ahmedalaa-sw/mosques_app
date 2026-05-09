import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

enum MosqueErrorType { network, location, server }

abstract class MosqueSearchState {}

class MosqueSearchInitial extends MosqueSearchState {}

class MosqueSearchLocating extends MosqueSearchState {}

class MosqueSearchLoading extends MosqueSearchState {}

class MosqueSearchSuccess extends MosqueSearchState {
  final List<MosqueModel> mosques;
  MosqueSearchSuccess(this.mosques);
}

class MosqueSearchError extends MosqueSearchState {
  final String message;
  final bool canRetry;
  final MosqueErrorType errorType;
  MosqueSearchError(
    this.message, {
    this.canRetry = true,
    this.errorType = MosqueErrorType.network,
  });
}
