import 'package:flutter/material.dart';
import 'package:stream_app/logic/repositories/user_repository_impl.dart';
import '../../data/models/user/user_model.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository;
  UserProvider({required UserRepository repository}) : _repository = repository;

  List<UserModel> _searchResults = [];
  List<UserModel> get searchResults => _searchResults;

  // Takip edilenler ve takipçiler listeleri için state
  List<UserModel> _followingList = [];
  List<UserModel> get followingList => _followingList;

  List<UserModel> _followerList = [];
  List<UserModel> get followerList => _followerList;

  // Genel yükleme (liste yükleme için)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Profil sayfası yüklemesi için AYRI flag
  // Global isLoading'i kirletmemek için ayrı tutuldu
  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  // --- DEVICE & NOTIFICATION ---

  Future<void> registerDevice({
    required String fcmToken,
    required String deviceType,
    String? deviceModel,
  }) async {
    _errorMessage = null;
    final data = {
      'fcm_token': fcmToken,
      'device_type': deviceType,
      'device_model': deviceModel,
    };

    final result = await _repository.registerDevice(data);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (_) => debugPrint("Device registered successfully"),
    );
    notifyListeners();
  }

  Future<void> fetchUser() async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _repository.getMe();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (userData) => _user = userData,
    );
    _setLoading(false);
  }

  /// Profil sayfası için: backend'den en güncel veriyi çeker.
  /// Global isLoading'i değil, isProfileLoading'i kullanır.
  Future<UserModel?> fetchUserProfile(int userId) async {
    _isProfileLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getUserById(userId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isProfileLoading = false;
        notifyListeners();
        return null;
      },
      (userData) {
        // Listelerden birinde varsa güncelle, yoksa bırak
        _syncUserInLists(userData);
        _isProfileLoading = false;
        notifyListeners();
        return userData;
      },
    );
  }

  /// Verilen kullanıcıyı tüm listlerde günceller (profil datası tazelendiğinde)
  void _syncUserInLists(UserModel updatedUser) {
    final searchIndex = _searchResults.indexWhere(
      (u) => u.id == updatedUser.id,
    );
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedUser;
    }

    final followingIndex = _followingList.indexWhere(
      (u) => u.id == updatedUser.id,
    );
    if (followingIndex != -1) {
      _followingList[followingIndex] = updatedUser;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _repository.updateMe(updateData);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (updatedUser) {
        _user = updatedUser;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.searchUsers(query);

    result.fold(
      (failure) {
        debugPrint("UserProvider: Search Error: ${failure.message}");
        _errorMessage = failure.message;
        _searchResults = [];
      },
      (users) {
        debugPrint("UserProvider: Found ${users.length} users for query: $query");
        _searchResults = users;
      },
    );

    _setLoading(false);
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<bool> uploadProfileImage(String filePath) async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _repository.uploadProfileImage(filePath);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setLoading(false);
        return false;
      },
      (uploadedUser) {
        _user = uploadedUser;
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> deactivateAccount() async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _repository.deactivateMe();
    _setLoading(false);
    return result.isRight();
  }

  // --- TAKİP SİSTEMİ ---

  Future<bool> followStreamer(int streamerId) async {
    _errorMessage = null;
    final result = await _repository.followStreamer(streamerId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _updateFollowStateLocally(streamerId, true);
        return true;
      },
    );
  }

  Future<bool> unfollowStreamer(int streamerId) async {
    _errorMessage = null;
    final result = await _repository.unfollowStreamer(streamerId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _updateFollowStateLocally(streamerId, false);
        return true;
      },
    );
  }

  Future<void> fetchFollowingList(int userId) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getFollowingList(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _followingList = [];
      },
      (users) {
        _followingList = users;
      },
    );

    _setLoading(false);
  }

  Future<void> fetchFollowerList(int streamerId) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getFollowerList(streamerId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _followerList = [];
      },
      (users) {
        _followerList = users;
      },
    );

    _setLoading(false);
  }

  /// Follow/unfollow sonrası tüm ilgili listeleri tutarlı şekilde günceller.
  void _updateFollowStateLocally(int streamerId, bool isFollowingNow) {
    // 1. Kendi profilimizdeki "Following" sayısını güncelle
    if (_user != null) {
      final newCount = _user!.followingCount + (isFollowingNow ? 1 : -1);
      _user = _user!.copyWith(followingCount: newCount < 0 ? 0 : newCount);
    }

    // 2. Arama sonuçlarındaki yayıncıyı güncelle
    final searchIndex = _searchResults.indexWhere((u) => u.id == streamerId);
    if (searchIndex != -1) {
      final streamer = _searchResults[searchIndex];
      final newCount = streamer.followersCount + (isFollowingNow ? 1 : -1);
      _searchResults[searchIndex] = streamer.copyWith(
        isFollowing: isFollowingNow,
        followersCount: newCount < 0 ? 0 : newCount,
      );
    }

    // 3. Following listesini güncelle
    final followingIndex = _followingList.indexWhere((u) => u.id == streamerId);
    if (isFollowingNow) {
      // Takip edildi: listede yoksa arama sonuçlarından bul ve ekle
      if (followingIndex == -1) {
        final newFollowing = searchIndex != -1
            ? _searchResults[searchIndex] // güncellenmiş hali al
            : null;
        if (newFollowing != null) {
          _followingList.add(newFollowing);
        }
      } else {
        // Listede var ama isFollowing=false idi (teorik), güncelle
        final streamer = _followingList[followingIndex];
        _followingList[followingIndex] = streamer.copyWith(isFollowing: true);
      }
    } else {
      // Takipten çıkıldı: listeden sil
      if (followingIndex != -1) {
        _followingList.removeAt(followingIndex);
      }
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _errorMessage = null;
    _followingList = [];
    _followerList = [];
    _searchResults = [];
    notifyListeners();
  }
}
