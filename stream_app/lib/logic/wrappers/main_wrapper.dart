import 'package:flutter/material.dart';
import 'package:stream_app/data/models/tab_item.dart';
import 'package:stream_app/logic/wrappers/profile_wrapper.dart';
import 'package:stream_app/views/screens/tabs/explore_screen.dart';
import 'package:stream_app/views/screens/tabs/home_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // final kelimesini kaldırdık ki sekmeler arası geçişte değeri güncelleyebilelim
  int _currentIndex = 0;

  // Sekmeleri burada tanımlamak daha temizdir
  final List<TabItem> _tabs = [
    TabItem(
      title: 'Home',
      icon: const Icon(Icons.home_rounded),
      page: const HomeScreen(),
    ),
    TabItem(
      title: 'Explore',
      icon: const Icon(Icons.explore_rounded),
      page: const ExploreScreen(),
    ),
    TabItem(
      title: 'Profile',
      icon: const Icon(Icons.person_rounded),
      page: const ProfileWrapper(),
    ), // ProfileScreen'i henüz tasarlamadık ama sayfa olarak durabilir
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Bu özellik, sayfa içeriğinin alt barın "arkasına" kadar inmesini sağlar (Floating efekti için şart)
      extendBody: true,

      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),

      // Temaya uygun Custom Floating Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F), // Temadaki darkBackground
            borderRadius: BorderRadius.circular(100), // Hap görünümü
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_tabs.length, (index) {
              final isSelected = _currentIndex == index;
              final tab = _tabs[index];
              // tab.icon bir Icon widget'ı olduğu için içindeki iconData'yı alıyoruz
              final iconData = (tab.icon).icon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconData,
                        color: isSelected ? Colors.black87 : Colors.white70,
                      ),
                      // Sadece seçili olan sekmenin metni görünür
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          tab.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
