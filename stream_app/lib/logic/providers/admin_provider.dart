import 'package:flutter/material.dart';
import 'package:stream_app/data/models/user/user_model.dart';
import 'package:stream_app/logic/repositories/admin_repository_impl.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider({required AdminRepository repository})
    : _repository = repository;

  List<UserModel> _users = [];
  List<UserModel> get users => _filteredUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  String _searchQuery = '';
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 20;

  // Arama işlemi için filtrelenmiş liste ve hiyerarşik sıralama
  List<UserModel> get _filteredUsers {
    var filtered = _users.where((user) {
      final query = _searchQuery.toLowerCase();
      final usernameMatch = user.username.toLowerCase().contains(query);
      final emailMatch = user.email.toLowerCase().contains(query);
      return usernameMatch || emailMatch;
    }).toList();

    // Hiyerarşik Sıralama: Adminler > Streamerlar (ileride Moderator) > Normal Kullanıcılar
    filtered.sort((a, b) {
      int getRank(UserModel u) {
        if (u.isAdmin) return 1;
        // if (u.isModerator) return 2; // İleride eklendiğinde
        if (u.isStreamer) return 3;
        return 4;
      }

      return getRank(a).compareTo(getRank(b));
    });

    return filtered;
  }

  // Kullanıcıları Çekme ve Sayfalama
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _skip = 0;
      _hasMore = true;
      _searchQuery = '';
      _users.clear();
      _setLoading(true);
    } else {
      if (!_hasMore || _isFetchingMore) return;
      _setFetchingMore(true);
    }

    final result = await _repository.getAllUsers(skip: _skip, limit: _limit);

    result.fold(
      (failure) {
        // Hata yönetimi (Snackbark vb. için eklenebilir)
      },
      (newUsers) {
        if (newUsers.length < _limit) {
          _hasMore = false; // Daha fazla veri kalmadı
        }
        _users.addAll(newUsers);
        _skip += _limit;
      },
    );

    _setLoading(false);
    _setFetchingMore(false);
  }

  void searchUsers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<UserModel?> getUserDetails(int userId) async {
    final result = await _repository.getUserDetails(userId);
    return result.fold((failure) {
      debugPrint(failure.message);
      return null;
    }, (user) => user);
  }

  // Kullanıcıyı Streamer Yap
  Future<void> promoteToStreamer(int userId) async {
    final result = await _repository.promoteToStreamer(userId);
    result.fold((failure) => debugPrint(failure.message), (updatedUser) {
      _updateUserInList(updatedUser);
    });
  }

  // Kullanıcı Ban/Unban
  Future<void> toggleUserStatus(int userId) async {
    final result = await _repository.toggleUserStatus(userId);
    result.fold((failure) => debugPrint(failure.message), (updatedUser) {
      _updateUserInList(updatedUser);
    });
  }

  void _updateUserInList(UserModel updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }
}
