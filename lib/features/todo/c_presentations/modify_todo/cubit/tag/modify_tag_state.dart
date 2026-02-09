import 'package:equatable/equatable.dart';

import '../../../models/label_item.dart';

class ModifyTagState extends Equatable {
  final List<LabelItem> labels;
  final bool isLoading;
  final String? error;

  const ModifyTagState({
    this.labels = const [],
    this.isLoading = false,
    this.error,
  });

  ModifyTagState copyWith({
    List<LabelItem>? labels,
    bool? isLoading,
    String? error,
  }) {
    return ModifyTagState(
      labels: labels ?? this.labels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [labels, isLoading, error];
}
