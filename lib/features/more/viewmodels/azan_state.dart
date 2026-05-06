class AzanState {
  final bool isAzanEnabled;

  const AzanState({this.isAzanEnabled = false});

  AzanState copyWith({bool? isAzanEnabled}) =>
      AzanState(isAzanEnabled: isAzanEnabled ?? this.isAzanEnabled);
}