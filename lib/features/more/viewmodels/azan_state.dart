import 'package:equatable/equatable.dart';

class AzanState extends Equatable {
  final bool isAzanEnabled;

  const AzanState({this.isAzanEnabled = false});

  @override
  List<Object?> get props => [isAzanEnabled];
}