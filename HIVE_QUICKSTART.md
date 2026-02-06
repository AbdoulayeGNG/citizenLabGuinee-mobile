# Hive Offline-First: Quick Start Guide

## Installation & Setup (Already Done ✅)

The Hive setup is **complete**. All you need to do is use it.

## Using the Offline-First System

### 1. Display Posts (with automatic caching)

```dart
// In any screen using Provider
Consumer<ApiService>(
  builder: (context, apiService, _) {
    return ListView.builder(
      itemCount: apiService.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: apiService.posts[index]);
      },
    );
  },
)
```

**What happens:**
- Data loads from Hive immediately (offline-ready)
- If connected and cache is old, fresh data fetches in background
- UI updates when data arrives

---

### 2. Search Posts (Works Offline!)

```dart
final repo = PostsRepository();
final results = await repo.searchPosts('Guinée');

// Returns matching posts from cache instantly
// Works perfectly offline
```

---

### 3. Filter by Category (Works Offline!)

```dart
final repo = PostsRepository();
final categoryPosts = await repo.getPostsByCategory('actualites');
```

---

### 4. Check Cache Status

```dart
final repo = PostsRepository();

// Get when data was last synced
final lastSync = await repo.getLastSyncTime();
print('Last updated: $lastSync');

// Check if cache is stale (default: 60 minutes for posts)
final needsRefresh = await repo.needsRefresh();
if (needsRefresh) {
  // Fetch fresh data if needed
  final apiService = Provider.of<ApiService>(context, listen: false);
  await apiService.refreshData();
}
```

---

### 5. Manual Refresh

```dart
final apiService = Provider.of<ApiService>(context, listen: false);
await apiService.refreshData();
// Fetches from GraphQL and updates Hive automatically
```

---

### 6. Clear Cache

```dart
final repo = PostsRepository();
await repo.clearAllPosts();
```

---

## Key Points

### ✅ Automatic
- App automatically loads from Hive on startup
- Data cached after first successful fetch
- Auto-syncs when network reconnects

### ✅ Offline Ready
- All data and operations work without internet
- Search, filter, browse all work offline
- No network calls needed

### ✅ Zero Configuration
- Hive boxes already open in `main.dart`
- Adapters already registered
- Just use `PostsRepository`, `CategoriesRepository`, etc.

### ✅ No UI Changes Needed
- Existing screens work automatically
- ApiService handles caching transparently
- Optional: Use repositories directly for more control

---

## Common Tasks

### Display All Posts

```dart
// Option 1: Via ApiService (recommended)
final posts = context.watch<ApiService>().posts;

// Option 2: Direct from repository
final repo = PostsRepository();
final posts = await repo.getAllPostsFromCache();
```

### Get Team Members

```dart
final repo = TeamsRepository();
final teamMembers = await repo.getAllTeamMembersFromCache();
```

### Get Categories

```dart
final repo = CategoriesRepository();
final categories = await repo.getAllCategoriesFromCache();
```

### Search in Any Repository

```dart
// Posts
final posts = await PostsRepository().searchPosts('query');

// Teams
final teams = await TeamsRepository().searchTeamMembers('John');

// Categories - filter by slug
final cat = await CategoriesRepository().getCategoryBySlug('actualites');
```

---

## Example: Complete Offline-First Screen

```dart
class PostsScreen extends StatefulWidget {
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final repo = PostsRepository();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          
          // Posts list (works offline)
          Expanded(
            child: FutureBuilder<List>(
              future: searchQuery.isEmpty
                  ? repo.getAllPostsFromCache()
                  : repo.searchPosts(searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!;
                if (posts.isEmpty) {
                  return Center(child: Text('Aucun article'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.excerpt ?? ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Offline Indicator (Optional)

```dart
Consumer<ApiService>(
  builder: (context, apiService, _) {
    if (apiService.isOffline) {
      return Container(
        color: Colors.amber,
        child: Row(
          children: [
            Icon(Icons.wifi_off),
            Text('Mode hors ligne'),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  },
)
```

---

## Files to Remember

| File | Purpose |
|------|---------|
| `lib/repositories/posts_repository.dart` | Posts caching & search |
| `lib/repositories/categories_repository.dart` | Categories caching |
| `lib/repositories/teams_repository.dart` | Team members caching |
| `lib/models/hive_*.dart` | Hive model definitions |
| `lib/services/api_service.dart` | Main service (uses repos) |
| `lib/main.dart` | Hive initialization |

---

## Troubleshooting

### Data not showing?
- Check if app is connected on first launch
- Call `apiService.refreshData()`
- Check cache with `repo.getAllPostsFromCache()`

### Stale data after reconnect?
- Call `apiService.refreshData()` manually
- Or wait for automatic sync (happens in `_loadCachedData`)

### Want to force cache refresh?
```dart
final repo = PostsRepository();
await repo.clearAllPosts(); // Clear cache
await apiService.refreshData(); // Fetch fresh
```

---

## That's It! 🎉

Your app is now:
- ✅ **Offline-first** (loads from cache immediately)
- ✅ **Auto-syncing** (fetches fresh data when connected)
- ✅ **Searchable** (full-text search works offline)
- ✅ **Filterable** (category filtering works offline)
- ✅ **Persistent** (data survives app restart)

No further configuration needed!
