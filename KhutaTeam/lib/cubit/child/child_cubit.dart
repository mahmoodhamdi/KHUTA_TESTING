import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:khuta/core/di/service_locator.dart';
import 'package:khuta/core/repositories/child_repository.dart';
import 'package:khuta/core/services/error_handler_service.dart';
import 'package:khuta/models/child.dart';

part 'child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final ChildRepository _repository;

  ChildCubit({ChildRepository? repository})
      : _repository = repository ?? ServiceLocator().childRepository,
        super(const ChildState.initial());

  /// Load all children from the repository
  Future<void> loadChildren() async {
    emit(state.copyWith(status: ChildStatus.loading));

    try {
      final children = await _repository.getChildren();
      emit(state.copyWith(
        status: ChildStatus.loaded,
        children: children,
      ));
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading children: $e');
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
    }
  }

  /// Add a new child
  Future<bool> addChild(Child child) async {
    emit(state.copyWith(status: ChildStatus.adding));

    try {
      await _repository.addChild(child);
      await loadChildren(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding child: $e');
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
      return false;
    }
  }

  /// Update an existing child
  Future<bool> updateChild(Child child) async {
    try {
      await _repository.updateChild(child);
      await loadChildren(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating child: $e');
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
      return false;
    }
  }

  /// Delete a child
  Future<bool> deleteChild(String childId) async {
    emit(state.copyWith(status: ChildStatus.deleting));

    try {
      await _repository.deleteChild(childId);
      await loadChildren(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting child: $e');
      emit(state.copyWith(
        status: ChildStatus.error,
        errorMessage: ErrorHandlerService.getErrorMessage(e),
      ));
      return false;
    }
  }

  /// Get a specific child by ID
  Child? getChildById(String childId) {
    try {
      return state.children.firstWhere((child) => child.id == childId);
    } catch (e) {
      return null;
    }
  }

  /// Clear any error state
  void clearError() {
    if (state.hasError) {
      emit(state.copyWith(
        status: ChildStatus.loaded,
        errorMessage: null,
      ));
    }
  }

  /// Refresh children list
  Future<void> refresh() async {
    await loadChildren();
  }
}
