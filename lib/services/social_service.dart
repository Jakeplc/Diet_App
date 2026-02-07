class User {
  final String id;
  final String name;
  final String profileImage;
  final double currentWeight;
  final int streak;
  final int totalAchievements;

  User({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.currentWeight,
    required this.streak,
    required this.totalAchievements,
  });
}

class Friend extends User {
  final bool isFollowing;

  Friend({
    required super.id,
    required super.name,
    required super.profileImage,
    required super.currentWeight,
    required super.streak,
    required super.totalAchievements,
    required this.isFollowing,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'steps', 'meals', 'weight_loss', 'streak'
  final int duration; // in days
  final int participants;
  final int yourRank;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
    required this.participants,
    required this.yourRank,
    required this.isActive,
    required this.startDate,
    required this.endDate,
  });
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final String profileImage;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.profileImage,
    required this.isCurrentUser,
  });
}

class SocialService {
  static final List<Friend> _friends = [
    Friend(
      id: '2',
      name: 'Sarah Johnson',
      profileImage: 'https://via.placeholder.com/150?text=Sarah',
      currentWeight: 62.5,
      streak: 15,
      totalAchievements: 8,
      isFollowing: true,
    ),
    Friend(
      id: '3',
      name: 'Mike Chen',
      profileImage: 'https://via.placeholder.com/150?text=Mike',
      currentWeight: 78.2,
      streak: 22,
      totalAchievements: 12,
      isFollowing: true,
    ),
    Friend(
      id: '4',
      name: 'Emma Davis',
      profileImage: 'https://via.placeholder.com/150?text=Emma',
      currentWeight: 68.0,
      streak: 8,
      totalAchievements: 5,
      isFollowing: true,
    ),
  ];

  static final List<Challenge> _activeChallenges = [
    Challenge(
      id: '1',
      title: '7-Day Step Challenge',
      description: 'Reach 70,000 steps in 7 days',
      type: 'steps',
      duration: 7,
      participants: 24,
      yourRank: 3,
      isActive: true,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Challenge(
      id: '2',
      title: 'Meal Logging Streak',
      description: 'Log meals for 10 consecutive days',
      type: 'meals',
      duration: 10,
      participants: 18,
      yourRank: 1,
      isActive: true,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Challenge(
      id: '3',
      title: 'Weight Loss Sprint',
      description: 'Achieve your weight goal in 30 days',
      type: 'weight_loss',
      duration: 30,
      participants: 42,
      yourRank: 12,
      isActive: true,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 20)),
    ),
  ];

  static Future<List<Friend>> getFriends() async {
    return _friends;
  }

  static Future<bool> addFriend(String friendId) async {
    // Simulate adding friend
    return true;
  }

  static Future<bool> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    return true;
  }

  static Future<List<Challenge>> getActiveChallenges() async {
    return _activeChallenges;
  }

  static Future<List<Challenge>> getCompletedChallenges() async {
    return [
      Challenge(
        id: 'past1',
        title: '30-Day Meal Challenge',
        description: 'Log meals every day for 30 days',
        type: 'meals',
        duration: 30,
        participants: 38,
        yourRank: 2,
        isActive: false,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Challenge(
        id: 'past2',
        title: 'Morning Workout Challenge',
        description: 'Complete 10 morning workouts',
        type: 'steps',
        duration: 7,
        participants: 15,
        yourRank: 1,
        isActive: false,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 83)),
      ),
    ];
  }

  static Future<List<LeaderboardEntry>> getFriendLeaderboard() async {
    return [
      LeaderboardEntry(
        rank: 1,
        name: 'You',
        points: 2450,
        profileImage: 'https://via.placeholder.com/150?text=You',
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 2,
        name: 'Mike Chen',
        points: 2380,
        profileImage: 'https://via.placeholder.com/150?text=Mike',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'Sarah Johnson',
        points: 2210,
        profileImage: 'https://via.placeholder.com/150?text=Sarah',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 4,
        name: 'Emma Davis',
        points: 1890,
        profileImage: 'https://via.placeholder.com/150?text=Emma',
        isCurrentUser: false,
      ),
    ];
  }

  static Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    return [
      LeaderboardEntry(
        rank: 1,
        name: 'Alex Rodriguez',
        points: 5890,
        profileImage: 'https://via.placeholder.com/150?text=Alex',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 2,
        name: 'Jordan Smith',
        points: 5720,
        profileImage: 'https://via.placeholder.com/150?text=Jordan',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'You',
        points: 2450,
        profileImage: 'https://via.placeholder.com/150?text=You',
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 4,
        name: 'Taylor Kim',
        points: 4210,
        profileImage: 'https://via.placeholder.com/150?text=Taylor',
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 5,
        name: 'Casey Brown',
        points: 3980,
        profileImage: 'https://via.placeholder.com/150?text=Casey',
        isCurrentUser: false,
      ),
    ];
  }
}
