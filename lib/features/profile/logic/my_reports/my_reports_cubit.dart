import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../home/data/models/fault_model.dart';
import '../../../home/data/repos/fault_repository.dart';

part 'my_reports_state.dart';

class MyReportsCubit extends Cubit<MyReportsState> {
  final IFaultRepository _faultRepository;
  String? _currentUserId;
  String? _currentFilter;
  List<FaultModel> _allFaults = [];

  MyReportsCubit(this._faultRepository) : super(MyReportsInitial());

  Future<void> loadUserReports(String userId) async {
    _currentUserId = userId;
    emit(MyReportsLoading());

    try {
      _allFaults = await _faultRepository.getUserFaults(userId);
      // Sort by date in memory (in case Firestore index is not ready yet)
      _allFaults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _applyFilter();
    } on DatabaseException catch (e) {
      emit(MyReportsError(e.message));
    } catch (e) {
      emit(MyReportsError('Failed to load reports. Please try again.'));
    }
  }

  Future<void> refreshReports() async {
    if (_currentUserId != null) {
      await loadUserReports(_currentUserId!);
    }
  }

  void filterByStatus(String? status) {
    _currentFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (_currentFilter == null) {
      emit(MyReportsLoaded(_allFaults));
    } else {
      final filtered = _allFaults
          .where((fault) => fault.status == _currentFilter)
          .toList();
      emit(MyReportsLoaded(filtered));
    }
  }
}
