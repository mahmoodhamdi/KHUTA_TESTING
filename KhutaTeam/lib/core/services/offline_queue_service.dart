import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Operations that can be queued for offline sync.
enum OfflineOperationType {
  addChild,
  updateChild,
  deleteChild,
  saveTestResult,
}

/// Represents a queued operation to be synced when online.
class QueuedOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Service for queuing operations when offline and syncing when back online.
///
/// Operations are stored in SharedPreferences and processed when connectivity
/// is restored. The service maintains order and handles failures gracefully.
///
/// ## Usage
///
/// ```dart
/// // Queue an operation when offline
/// await OfflineQueueService.queueOperation(
///   OfflineOperationType.addChild,
///   {'name': 'John', 'age': 8, 'gender': 'male'},
/// );
///
/// // Sync when back online (called automatically or manually)
/// await OfflineQueueService.syncQueue(processOperation);
/// ```
class OfflineQueueService {
  static const String _queueKey = 'offline_queue';
  static final ConnectivityService _connectivityService = ConnectivityService();

  /// Adds an operation to the offline queue.
  ///
  /// The operation will be stored and processed when connectivity is restored.
  static Future<String> queueOperation(
    OfflineOperationType type,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    queue.add(operation);
    await _saveQueue(prefs, queue);

    if (kDebugMode) {
      debugPrint('Queued offline operation: ${type.name}');
    }

    return operation.id;
  }

  /// Retrieves all queued operations.
  static Future<List<QueuedOperation>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getStringList(_queueKey) ?? [];

    return queueJson
        .map((json) => QueuedOperation.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Gets the number of pending operations.
  static Future<int> getPendingCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  /// Checks if there are pending operations.
  static Future<bool> hasPendingOperations() async {
    final count = await getPendingCount();
    return count > 0;
  }

  /// Processes all queued operations.
  ///
  /// [processOperation] is called for each queued operation. If it succeeds,
  /// the operation is removed from the queue. If it fails, the operation
  /// remains in the queue for retry.
  ///
  /// Returns the number of successfully processed operations.
  static Future<int> syncQueue(
    Future<bool> Function(QueuedOperation operation) processOperation,
  ) async {
    // Check connectivity first
    if (!await _connectivityService.hasConnection()) {
      if (kDebugMode) {
        debugPrint('Cannot sync: no connectivity');
      }
      return 0;
    }

    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    if (queue.isEmpty) {
      return 0;
    }

    if (kDebugMode) {
      debugPrint('Syncing ${queue.length} queued operations...');
    }

    int successCount = 0;
    final remainingQueue = <QueuedOperation>[];

    for (final operation in queue) {
      try {
        final success = await processOperation(operation);
        if (success) {
          successCount++;
          if (kDebugMode) {
            debugPrint('Synced operation: ${operation.type.name}');
          }
        } else {
          remainingQueue.add(operation);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to sync operation ${operation.type.name}: $e');
        }
        remainingQueue.add(operation);
      }
    }

    await _saveQueue(prefs, remainingQueue);

    if (kDebugMode) {
      debugPrint('Sync complete: $successCount/${queue.length} operations');
    }

    return successCount;
  }

  /// Removes a specific operation from the queue.
  static Future<void> removeOperation(String operationId) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    queue.removeWhere((op) => op.id == operationId);
    await _saveQueue(prefs, queue);
  }

  /// Clears all queued operations.
  ///
  /// Use with caution - this will discard all pending offline changes.
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Saves the queue to SharedPreferences.
  static Future<void> _saveQueue(
    SharedPreferences prefs,
    List<QueuedOperation> queue,
  ) async {
    final queueJson = queue.map((op) => jsonEncode(op.toJson())).toList();
    await prefs.setStringList(_queueKey, queueJson);
  }

  /// Sets up automatic sync when connectivity is restored.
  ///
  /// Call this once during app initialization to enable auto-sync.
  static void setupAutoSync(
    Future<bool> Function(QueuedOperation operation) processOperation,
  ) {
    _connectivityService.onConnectivityChanged.listen((isOnline) async {
      if (isOnline && await hasPendingOperations()) {
        if (kDebugMode) {
          debugPrint('Connectivity restored, starting auto-sync...');
        }
        await syncQueue(processOperation);
      }
    });
  }
}
