import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/server_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const LocalAIServerApp());
}

class LocalAIServerApp extends StatelessWidget {
  const LocalAIServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServerProvider()),
      ],
      child: MaterialApp(
        title: 'Local AI Server',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}