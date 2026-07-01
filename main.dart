import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_stats_provider.dart';
import 'models/game_state.dart';
import 'screens/splash_screen.dart';
import 'utils/sound_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStatsProvider()),
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
        ChangeNotifierProvider(create: (_) => SoundManager()),
      ],
      child: MaterialApp(
        title: 'Math Adventure',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Comic Sans MS',
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// GameStatsProvider moved to lib/providers/game_stats_provider.dart