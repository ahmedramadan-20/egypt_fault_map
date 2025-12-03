import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/notification_service.dart';
import '../data/models/notification_model.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;

  NotificationsCubit(
    this._auth,
    this._firestore,
    this._notificationService,
  ) : super(NotificationsInitial());

  /// Load notifications
  Future<void> loadNotifications() async {
    emit(NotificationsLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(NotificationsError('User not logged in'));
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final notifications =
          snapshot.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();

      final unreadCount = notifications.where((n) => !n.read).length;

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications: ${e.toString()}'));
    }
  }

  /// Watch notifications in real-time
  Stream<NotificationsState> watchNotifications() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield NotificationsError('User not logged in');
      return;
    }

    yield NotificationsLoading();

    yield* _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final notifications =
          snapshot.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();

      final unreadCount = notifications.where((n) => !n.read).length;

      return NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    }).handleError((error) {
      return NotificationsError('Failed to watch notifications: $error');
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Reload to update state
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to mark as read: ${e.toString()}'));
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      // Reload to update state
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read: ${e.toString()}'));
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      await _notificationService.clearAllNotifications();
      emit(NotificationsLoaded(notifications: [], unreadCount: 0));
    } catch (e) {
      emit(NotificationsError('Failed to clear notifications: ${e.toString()}'));
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    return await _notificationService.getUnreadCount();
  }
}
