import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/features/dashboard/dashboard_page.dart';
import 'package:bookcase/features/my_bookshelf/my_bookshelf_page.dart';
import 'package:bookcase/features/search_books/search_books_page.dart';
import 'package:bookcase/shared/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatefulWidget {
  final Widget? initialHome;

  const App({super.key, this.initialHome});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    MyBookshelfPage(),
    SearchBooksPage(),
    // GoalsPage(),
    // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardSurface,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
      ),
      home:
          widget.initialHome ??
          Scaffold(
            extendBody: true,
            body: IndexedStack(index: currentIndex, children: pages),
            bottomNavigationBar: AppBottomNavigation(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
    );
  }
}
