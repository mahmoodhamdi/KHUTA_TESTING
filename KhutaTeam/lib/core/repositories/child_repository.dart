import 'package:khuta/models/child.dart';

/// Result of a paginated query containing children and pagination cursor.
class PaginatedChildren {
  /// The list of children returned by the query.
  final List<Child> children;

  /// Cursor for fetching the next page. Null if no more pages.
  final Object? nextPageCursor;

  /// Whether there are more children to load.
  bool get hasMore => nextPageCursor != null;

  const PaginatedChildren({
    required this.children,
    this.nextPageCursor,
  });
}

/// Abstract repository interface for child data operations.
///
/// This interface defines the contract for managing child profiles in the app.
/// Implementations can use different data sources:
/// - [FirebaseChildRepository]: Cloud Firestore storage (production)
/// - MockChildRepository: In-memory storage (testing)
///
/// ## Key Features
///
/// - **Soft Delete Pattern**: Children are never permanently deleted. Instead,
///   the `isDeleted` flag is set to true, preserving data for potential recovery.
/// - **Real-time Updates**: The [watchChildren] method provides a stream for
///   reactive UI updates when child data changes.
/// - **User Scoping**: All operations are scoped to the authenticated user's
///   children collection.
///
/// ## Usage with Dependency Injection
///
/// ```dart
/// // Get the repository from ServiceLocator
/// final repository = ServiceLocator().childRepository;
///
/// // Load children
/// final children = await repository.getChildren();
///
/// // Watch for real-time updates
/// repository.watchChildren().listen((children) {
///   // Update UI
/// });
/// ```
abstract class ChildRepository {
  /// Retrieves all children for the current user.
  ///
  /// Returns only non-deleted children (where `isDeleted == false`).
  /// The list is ordered by creation date (newest first).
  Future<List<Child>> getChildren();

  /// Retrieves a single child by their unique ID.
  ///
  /// Returns `null` if the child doesn't exist or is soft-deleted.
  Future<Child?> getChild(String childId);

  /// Adds a new child to the repository.
  ///
  /// Returns the generated ID of the new child document.
  Future<String> addChild(Child child);

  /// Updates an existing child's data.
  ///
  /// The child is identified by their ID property.
  /// This also updates the `updatedAt` timestamp.
  Future<void> updateChild(Child child);

  /// Soft-deletes a child by setting `isDeleted = true`.
  ///
  /// The child's data is preserved for potential recovery.
  /// Use this instead of permanent deletion to maintain data integrity.
  Future<void> deleteChild(String childId);

  /// Returns a stream of children for real-time updates.
  ///
  /// The stream emits a new list whenever the children collection changes.
  /// Only non-deleted children are included in the emitted lists.
  Stream<List<Child>> watchChildren();

  /// Retrieves children with pagination support.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of children to return (default: 20)
  /// - [startAfter]: Cursor from previous query for fetching next page
  ///
  /// Returns a [PaginatedChildren] containing the children and a cursor
  /// for fetching the next page if more children exist.
  ///
  /// Example:
  /// ```dart
  /// // First page
  /// final page1 = await repository.getChildrenPaginated(limit: 10);
  ///
  /// // Next page
  /// if (page1.hasMore) {
  ///   final page2 = await repository.getChildrenPaginated(
  ///     limit: 10,
  ///     startAfter: page1.nextPageCursor,
  ///   );
  /// }
  /// ```
  Future<PaginatedChildren> getChildrenPaginated({
    int limit = 20,
    Object? startAfter,
  });
}
