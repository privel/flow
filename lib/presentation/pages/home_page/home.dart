import 'package:flow/presentation/pages/home_page/home_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; // 0 = Team, 1 = Personal

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Здесь можно обновить данные
  }

  Widget Switer(){
    return // Свичер
            Container(
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: List.generate(2, (index) {
                  final isSelected = index == selectedIndex;
                  final label = index == 0 ? 'Team' : 'Personal';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    
    final teamItems = List.generate(5, (i) => 'Team Project ${i + 1}');
    final personalItems = List.generate(3, (i) => 'Personal Task ${i + 1}');

    final visibleItems = selectedIndex == 0 ? teamItems : personalItems;

       final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final size = MediaQuery.of(context).size;

    HomeLayout homeLayout = HomeLayout(isMobile,isTablet);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // // Заголовок
            // const Text(
            //   'Projects',
            //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 16),

            // Switer(),

            // const SizedBox(height: 24),

            // // Отображаемые элементы
            // ...visibleItems.map((item) => Card(
            //       color: const Color(0xFF1E1E1E),
            //       child: Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Text(item, style: const TextStyle(color: Colors.white)),
            //       ),
            //     )),

            Image.asset("assets/image/",scale: homeLayout.ImageScaleIcon,),
            Container(

            ),
          ],
        ),
      ),
    );
  }
}
