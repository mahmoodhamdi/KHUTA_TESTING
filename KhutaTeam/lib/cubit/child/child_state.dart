part of 'child_cubit.dart';

enum ChildStatus { initial, loading, loaded, adding, deleting, error }

class ChildState extends Equatable {
  final ChildStatus status;
  final List<Child> children;
  final String? errorMessage;

  const ChildState({
    required this.status,
    required this.children,
    this.errorMessage,
  });

  const ChildState.initial()
      : status = ChildStatus.initial,
        children = const [],
        errorMessage = null;

  ChildState copyWith({
    ChildStatus? status,
    List<Child>? children,
    String? errorMessage,
  }) {
    return ChildState(
      status: status ?? this.status,
      children: children ?? this.children,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ChildStatus.loading;
  bool get hasError => status == ChildStatus.error;
  bool get isEmpty => children.isEmpty && status == ChildStatus.loaded;

  @override
  List<Object?> get props => [status, children, errorMessage];
}
