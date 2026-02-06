# Hive Local Storage Architecture - CitizenLab Guinée

## Overview

This document describes the offline-first Hive local storage implementation for CitizenLab Guinée. The architecture enables full offline functionality after the first app launch.

## Architecture

### Layer Structure

```
┌─────────────────────────────────────┐
│     UI Screens (Widgets)            │
├─────────────────────────────────────┤
│  ApiService (State Management)      │ <- ChangeNotifier
├─────────────────────────────────────┤
│  Repositories (PostsRepository, etc)│ <- Handle Hive Read/Write
├─────────────────────────────────────┤
│  Hive Boxes (TypeSafe Storage)      │ <- Local Storage
└─────────────────────────────────────┘
```

### Offline-First Strategy

1. **On App Startup:**
   - Load data from Hive (instant, offline-available)
   - If Hive is empty OR data is older than threshold, fetch from GraphQL
   - Save fetched data to Hive for future offline use

2. **On Network Reconnection:**
   - Automatically fetch latest data
   - Replace Hive cache with fresh data

3. **During Offline Usage:**
   - All data comes from Hive
   - User can browse, search, filter without internet

## Hive Models

### HivePost (typeId: 0)
Represents blog posts, news, and articles.

```dart
@HiveType(typeId: 0)
class HivePost {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String? slug;
  @HiveField(3) final String? content;
  @HiveField(4) final String? excerpt;
  @HiveField(5) final DateTime? date;
  @HiveField(6) final String? imageUrl;
  @HiveField(7) final String? imageAlt;
  @HiveField(8) final String? authorName;
  @HiveField(9) final List<String> categories;
  @HiveField(10) final DateTime cachedAt;
}
```

### HiveCategory (typeId: 1)
Represents content categories/tags.

```dart
@HiveType(typeId: 1)
class HiveCategory {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String? slug;
  @HiveField(3) final String? description;
  @HiveField(4) final DateTime cachedAt;
}
```

### HiveTeamMember (typeId: 2)
Represents team/staff members.

```dart
@HiveType(typeId: 2)
class HiveTeamMember {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String? imageUrl;
  @HiveField(3) final String? imageAlt;
  @HiveField(4) final String? team;
  @HiveField(5) final String? role;
  @HiveField(6-9) final String? facebook, instagram, linkedin, twitter;
  @HiveField(10) final DateTime cachedAt;
}
```

## Hive Boxes

| Box Name | Type | Purpose |
|----------|------|---------|
| `postsBox` | `Box<HivePost>` | Cache for blog posts |
| `categoriesBox` | `Box<HiveCategory>` | Cache for categories |
| `teamsBox` | `Box<HiveTeamMember>` | Cache for team members |
| `metadataBox` | `Box` | Stores sync timestamps |
| `cache` | `Box` | Legacy cache (gradual migration) |

## Repositories

### PostsRepository

**Location:** `lib/repositories/posts_repository.dart`

Methods:
- `getAllPostsFromCache()` - Get all cached posts
- `savePosts(List<Post>)` - Save posts to cache
- `savePost(Post)` - Save single post
- `getPostById(String)` - Get post by ID
- `getPostsByCategory(String)` - Filter by category
- `searchPosts(String)` - Full-text search
- `needsRefresh({int minutes})` - Check if cache is stale
- `getLastSyncTime()` - Get last sync timestamp

### CategoriesRepository

**Location:** `lib/repositories/categories_repository.dart`

Similar interface to PostsRepository but for categories.

### TeamsRepository

**Location:** `lib/repositories/teams_repository.dart`

Similar interface but for team members.

## Initialization (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(HivePostAdapter());
  Hive.registerAdapter(HiveCategoryAdapter());
  Hive.registerAdapter(HiveTeamMemberAdapter());

  // Open Hive boxes
  await Hive.openBox('cache');
  await Hive.openBox<HivePost>('postsBox');
  await Hive.openBox<HiveCategory>('categoriesBox');
  await Hive.openBox<HiveTeamMember>('teamsBox');
  await Hive.openBox('metadataBox');

  runApp(const MyApp());
}
```

## Usage Examples

### Example 1: Display Posts (Offline-First)

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApiService>(
      builder: (context, apiService, _) {
        // Data comes from cache (fast, offline-available)
        // Fresh data fetched in background if connected
        return ListView.builder(
          itemCount: apiService.posts.length,
          itemBuilder: (context, index) {
            final post = apiService.posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }
}
```

### Example 2: Search Posts Offline

```dart
final postsRepo = PostsRepository();

// Search works offline
final results = await postsRepo.searchPosts('Guinée');
print('Found ${results.length} posts');
```

### Example 3: Check Cache Age

```dart
final postsRepo = PostsRepository();

// Check if data needs refresh
final needsRefresh = await postsRepo.needsRefresh(minutesThreshold: 60);

if (needsRefresh) {
  print('Cache is older than 60 minutes');
}

// Get last sync time
final lastSync = await postsRepo.getLastSyncTime();
print('Last updated: ${lastSync}');
```

### Example 4: Manual Cache Update

```dart
// In a service or controller
final apiService = Provider.of<ApiService>(context, listen: false);
await apiService.refreshData(); // Fetches from GraphQL and updates Hive
```

## Data Flow Diagram

```
┌─────────────────┐
│  App Startup    │
└────────┬────────┘
         │
         ├─→ Load from Hive (instant)
         │   Display UI with cached data
         │
         ├─→ Check connectivity
         │
         ├─→ Is connected?
         │   ├─ YES: Fetch from GraphQL
         │   │       Save to Hive
         │   │       Update UI
         │   │
         │   └─ NO: Show offline indicator
         │          Use Hive data only
         │
         └─→ On Network Change
             └─ Connected? Fetch fresh data
```

## Sync Strategy

### Cache Refresh Thresholds

| Data Type | Threshold | Reason |
|-----------|-----------|--------|
| Posts | 60 minutes | Content changes frequently |
| Categories | 120 minutes | Rarely changes |
| Team Members | 120 minutes | Rarely changes |

Configure in repositories:
```dart
// Check if 30-minute-old cache needs refresh
final needsRefresh = await postsRepo.needsRefresh(minutesThreshold: 30);
```

## Error Handling

- **Network Errors:** Falls back to Hive cache automatically
- **Hive Errors:** Logged to console, app continues with empty state
- **Large Datasets:** Uses pagination (first: 20) to keep memory footprint low

## Testing Offline Functionality

### Manual Testing
1. Launch app (connected to internet) → data loads and caches
2. Toggle airplane mode → app shows cached data
3. Disable internet → app continues working with Hive
4. Re-enable internet → app fetches fresh data

### Simulating Offline
```bash
# Stop network in Flutter DevTools
# Or use emulator network controls
```

## Migration Path (Legacy Support)

Old cache box is still supported for gradual migration:
- New code uses repositories
- Old code continues using `Hive.box('cache')`
- Both coexist during transition period

## Performance Considerations

- **Read Latency:** ~1-5ms (Hive is very fast)
- **Write Latency:** ~10-50ms (batch writes optimized)
- **Storage Space:** ~5-20MB for typical cache (depends on image counts)
- **Memory:** Boxes loaded in memory, use pagination for large datasets

## Future Enhancements

1. **Data Expiration:** Auto-delete cached data older than X days
2. **Selective Sync:** Only cache specific categories
3. **Compression:** Compress images before caching
4. **Analytics:** Track cache hit/miss rates
5. **Conflict Resolution:** Handle offline edits (when write support added)

## Troubleshooting

### Cache Not Loading
- Check Hive initialization in main.dart
- Verify adapter registration
- Check box open calls

### Stale Data
- Adjust `minutesThreshold` in `needsRefresh()`
- Call `refreshData()` manually
- Check network connectivity

### Storage Issues
- Use `clearAllPosts()` in repository to free space
- Check device storage capacity
- Monitor cache size with DevTools

## Dependencies

- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `provider: ^6.0.5`
- `connectivity_plus: ^4.0.1`

No additional packages needed for repositories.
