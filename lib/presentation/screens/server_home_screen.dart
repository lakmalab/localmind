import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../widgets/server_card.dart';
import '../widgets/model_card.dart';
import '../widgets/logs_card.dart';

class ServerHomeScreen extends StatelessWidget {
  const ServerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalMind Server'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            ServerCard(),
            SizedBox(height: 16),
            ModelCard(),
            SizedBox(height: 16),
            LogsCard(),
          ],
        ),
      ),
    );
  }
}
