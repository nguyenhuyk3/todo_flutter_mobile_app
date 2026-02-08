import 'package:equatable/equatable.dart';

import '../../../models/label_item.dart';

class ModifyLabelState extends Equatable {
  final List<LabelItem> labels;
  final bool isLoading;
  final String? error;

  const ModifyLabelState({
    this.labels = const [],
    this.isLoading = false,
    this.error,
  });

  ModifyLabelState copyWith({
    List<LabelItem>? labels,
    bool? isLoading,
    String? error,
  }) {
    return ModifyLabelState(
      labels: labels ?? this.labels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [labels, isLoading, error];
}
