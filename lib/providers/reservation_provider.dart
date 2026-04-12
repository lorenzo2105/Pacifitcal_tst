import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/models/reservation_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class ReservationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReservationModel> _userReservations = [];
  List<String> _reservedClassIds = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ReservationModel>>? _userResSub;

  List<ReservationModel> get userReservations => _userReservations;
  List<ReservationModel> get upcomingReservations =>
      _userReservations.where((r) => r.isUpcoming).toList();
  List<String> get reservedClassIds => _reservedClassIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isReserved(String classId) => _reservedClassIds.contains(classId);

  void startListeningUserReservations(String userId) {
    if (kDebugMode) {
      print('🔄 Démarrage du stream de réservations');
    }
    _userResSub?.cancel();
    _userResSub = _firestoreService.streamUserReservations(userId).listen(
      (reservations) {
        if (kDebugMode) {
          print(
              '✅ Stream réservations reçu: ${reservations.length} réservation(s)');
        }
        _userReservations = reservations;
        _reservedClassIds = reservations.map((r) => r.classId).toList();
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) {
          print('❌ Erreur stream réservations: $e');
        }
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> reserve({
    required String userId,
    required String userName,
    required ClassModel classModel,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final reservation = await _firestoreService.createReservation(
        userId: userId,
        userName: userName,
        classModel: classModel,
      );

      // Mise à jour optimiste : ajouter immédiatement la réservation localement
      // avant que le stream Firestore ne se mette à jour (pour affichage immédiat)
      _userReservations.add(reservation);
      _reservedClassIds.add(classModel.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancel({
    required String reservationId,
    required String classId,
    required String userId,
    required String className,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _firestoreService.cancelReservation(reservationId, classId);

      // Mise à jour optimiste : retirer immédiatement la réservation localement
      _userReservations.removeWhere((r) => r.id == reservationId);
      _reservedClassIds.remove(classId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _userResSub?.cancel();
    _userReservations = [];
    _reservedClassIds = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _userResSub?.cancel();
    super.dispose();
  }
}
