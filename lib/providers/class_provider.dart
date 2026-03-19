import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pacifitcal/models/class_model.dart';
import 'package:pacifitcal/services/firestore_service.dart';

class ClassProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ClassModel> _upcomingClasses = [];
  List<ClassModel> _allClasses = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<ClassModel>>? _upcomingSub;
  StreamSubscription<List<ClassModel>>? _allSub;

  List<ClassModel> get upcomingClasses => _upcomingClasses;
  List<ClassModel> get allClasses => _allClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startListeningUpcoming() {
    _upcomingSub?.cancel();
    _upcomingSub = _firestoreService.streamUpcomingClasses().listen(
      (classes) {
        _upcomingClasses = classes;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void startListeningAll() {
    _allSub?.cancel();
    _allSub = _firestoreService.streamAllClasses().listen(
      (classes) {
        _allClasses = classes;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<String> createClass(ClassModel classModel) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _firestoreService.createClass(classModel);
      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateClass(ClassModel classModel) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateClass(classModel);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteClass(String classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteClass(classId);
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

  @override
  void dispose() {
    _upcomingSub?.cancel();
    _allSub?.cancel();
    super.dispose();
  }
}
