// Feito por: Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/dashboard/dashboard_page.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/my_bookshelf/my_bookshelf_page.dart';
import 'package:bookcase/features/search_books/search_books_page.dart';
import 'package:bookcase/features/shopping_list/shopping_list_page.dart';
import 'package:bookcase/features/streak/streak_store.dart';
import 'package:bookcase/shared/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookcase/features/profile_page/profile_page.dart';
import 'package:bookcase/features/goals/metas_screen.dart';

class App extends StatefulWidget {
  final Widget? initialHome;

  const App({super.key, this.initialHome});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int currentIndex = 0;

  static const searchPageIndex = 2;

  int searchPageKey = 0;

  @override
  void initState() {
    super.initState();
    _loadBookshelf();
    StreakStore.instance.load();
  }

  Future<void> _loadBookshelf() async {
    try {
      await BookshelfStore.instance.loadFromApi();
    } catch (_) {
      // O serviço registra detalhes da falha; a tela pode tentar novamente.
    }
  }

  List<Widget> get pages => [
    DashboardPage(onNavigate: _selectPage),
    const MyBookshelfPage(),
    SearchBooksPage(key: ValueKey(searchPageKey)),
    const MetasScreen(),
    const ShoppingListPage(embeddedInNavigation: true),
    const ProfilePage(),
  ];

  void _selectPage(int index) {
    setState(() {
      if (currentIndex == searchPageIndex && index != searchPageIndex) {
        searchPageKey++;
      }
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const buttonShape = RoundedRectangleBorder(
      borderRadius: AppDecorations.buttonBorderRadius,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardSurface,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(buttonShape)),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(buttonShape)),
        ),
        outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(buttonShape)),
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(shape: WidgetStatePropertyAll(buttonShape)),
        ),
      ),
      home:
          widget.initialHome ??
          Scaffold(
            extendBody: true,
            body: IndexedStack(index: currentIndex, children: pages),
            bottomNavigationBar: AppBottomNavigation(
              currentIndex: currentIndex,
              onTap: _selectPage,
            ),
          ),
    );
  }
}
