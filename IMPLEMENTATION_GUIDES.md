# 🚀 HIGH-PRIORITY FEATURE IMPLEMENTATIONS

Ready-to-use code snippets for the recommended enhancements

---

## 1. ACHIEVEMENT BADGES & STREAK SYSTEM

### Add to home_screen.dart (after the weekly stats section)

```dart
// Place this after the "This Week" section and before "Explore Features"

const SizedBox(height: 24),

// Streak Card
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [const Color(0xFFFF9800), const Color(0xFFFF6F00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFFFF9800).withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.local_fire_department,
            color: Colors.white, size: 32),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "7 Day Streak! 🔥",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Text(
              "Amazing consistency!",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      const Icon(Icons.trending_up, color: Colors.white, size: 24),
    ],
  ),
),

const SizedBox(height: 24),

// Achievement Badges Section
Text(
  "Achievements",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: isDarkTheme ? Colors.white : Colors.black87,
  ),
),
const SizedBox(height: 12),

// Badge Grid (2 columns)
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _buildBadge(
        context,
        icon: Icons.favorite,
        label: "Starter",
        color: Colors.blue,
        isEarned: true,
        isDarkTheme: isDarkTheme,
      ),
      const SizedBox(width: 12),
      _buildBadge(
        context,
        icon: Icons.star,
        label: "Week Warrior",
        color: Colors.amber,
        isEarned: true,
        isDarkTheme: isDarkTheme,
      ),
      const SizedBox(width: 12),
      _buildBadge(
        context,
        icon: Icons.emoji_events,
        label: "Champion",
        color: Colors.purple,
        isEarned: false,
        isDarkTheme: isDarkTheme,
      ),
    ],
  ),
),
```

### Add this method to _HomeScreenState class

```dart
Widget _buildBadge(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Color color,
  required bool isEarned,
  required bool isDarkTheme,
}) {
  return Column(
    children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isEarned ? 1.0 : 0.2),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isEarned ? Colors.white : Colors.grey[400],
          size: 36,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isEarned
              ? (isDarkTheme ? Colors.white : Colors.black87)
              : (isDarkTheme ? Colors.grey[500] : Colors.grey[500]),
        ),
      ),
    ],
  );
}
```

---

## 2. FLOATING ACTION BUTTON (Quick Log)

### Wrap Scaffold in home_screen.dart

```dart
return Scaffold(
  backgroundColor: isDarkTheme ? Colors.black87 : Colors.white,
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => _showQuickLogDialog(context),
    backgroundColor: Theme.of(context).colorScheme.primary,
    elevation: 8,
    icon: const Icon(Icons.add),
    label: const Text("Log Activity"),
    tooltip: "Quick log your workout",
  ),
  body: Container(
    // ... rest of your body code
  ),
);
```

### Add this method to _HomeScreenState

```dart
void _showQuickLogDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quick Log",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickLogButton(
                  context,
                  icon: Icons.fitness_center,
                  label: "Workout",
                  onTap: () => _logWorkout(),
                ),
                _buildQuickLogButton(
                  context,
                  icon: Icons.local_drink,
                  label: "Water",
                  onTap: () => _logWater(),
                ),
                _buildQuickLogButton(
                  context,
                  icon: Icons.restaurant,
                  label: "Meal",
                  onTap: () => _logMeal(),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Widget _buildQuickLogButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      CircleAvatar(
        radius: 35,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        child: IconButton(
          icon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
          onPressed: onTap,
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

void _logWorkout() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Workout logged!")),
  );
}

void _logWater() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Water logged!")),
  );
}

void _logMeal() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Meal logged!")),
  );
}
```

---

## 3. BOTTOM NAVIGATION BAR

### Create a new file: `lib/screens/main_navigation.dart`

```dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    // TODO: Add ProgressScreen
    Placeholder(),
    // TODO: Add GoalsScreen
    Placeholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: isDarkTheme ? Colors.grey[850] : Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: isDarkTheme ? Colors.grey[600] : Colors.grey[500],
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            activeIcon: Icon(Icons.assessment_outlined),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Goals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person_filled),
            label: "Profile",
          ),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
```

### Update `lib/screens/wrapper.dart`

Replace `const HomeScreen()` with `const MainNavigation()`

```dart
return MainNavigation();
```

---

## 4. SWIPEABLE HISTORICAL DATA

### Add to home_screen.dart

```dart
// Add after weekly stats section

const SizedBox(height: 24),

Text(
  "Last 7 Days",
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: isDarkTheme ? Colors.white : Colors.black87,
  ),
),
const SizedBox(height: 12),

SizedBox(
  height: 100,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 7,
    itemBuilder: (context, index) {
      final daysAgo = 6 - index;
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final isToday = daysAgo == 0;
      
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _buildDayCard(context, date, isToday, isDarkTheme),
      );
    },
  ),
),
```

### Add this method

```dart
Widget _buildDayCard(
  BuildContext context,
  DateTime date,
  bool isToday,
  bool isDarkTheme,
) {
  return Container(
    width: 60,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isToday
          ? Theme.of(context).colorScheme.primary
          : (isDarkTheme ? Colors.grey[800] : Colors.white),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isToday
            ? Theme.of(context).colorScheme.primary
            : (isDarkTheme
                ? Colors.grey[700]!
                : Colors.grey[200]!),
        width: 1.5,
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getDayName(date.weekday),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isToday ? Colors.white : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${date.day}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isToday ? Colors.white : (isDarkTheme ? Colors.white : Colors.black),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? Colors.white : Colors.green,
          ),
        ),
      ],
    ),
  );
}

String _getDayName(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}
```

---

## 5. SKELETON LOADING STATE

### Create `lib/widgets/shimmer_loading.dart`

```dart
import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const ShimmerLoading({
    required this.isLoading,
    required this.child,
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(-0.5 + _controller.value * 2, 0),
              colors: [
                Colors.grey[400]!,
                Colors.grey[200]!,
                Colors.grey[400]!,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
```

### Use in home_screen.dart

```dart
return ShimmerLoading(
  isLoading: snapshot.connectionState == ConnectionState.waiting,
  child: _buildHomeContent(user, isDarkTheme),
);
```

---

## 6. HAPTIC FEEDBACK

Add to any button press:

```dart
import 'package:flutter/services.dart';

onPressed: () {
  HapticFeedback.mediumImpact();
  // Your action here
}
```

---

## 📊 ESTIMATED IMPLEMENTATION TIME

| Feature | Time | Difficulty |
|---------|------|-----------|
| Achievement Badges | 2-3 hours | Medium |
| Streak System | 1-2 hours | Easy |
| FAB Quick Log | 1-2 hours | Easy |
| Bottom Navigation | 2-3 hours | Medium |
| Historical Data Swipe | 1-2 hours | Easy |
| Skeleton Loaders | 1-2 hours | Easy |
| Haptic Feedback | 30 mins | Very Easy |

**Total:** ~11-16 hours to implement all features

---

## 🎯 PRIORITY RECOMMENDATION

1. ✅ **Quick Win:** Add achievement badges + streak (2-3 hours, high impact)
2. ✅ **Foundation:** Bottom navigation bar (2-3 hours, enables future features)
3. ✅ **Engagement:** FAB quick log (1-2 hours, immediate value)
4. ✅ **Polish:** Haptic feedback & skeleton loaders (1-2 hours, UX improvement)
5. ✅ **Data:** Historical swipe view (1-2 hours, user value)

Start with #1 and #2, test with users, then iterate!

---

Generated: January 20, 2026
