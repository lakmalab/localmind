import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';

class ServerCard extends StatelessWidget {
  const ServerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerProvider>(
      builder: (context, provider, child) {
        final status = provider.status;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      status.isRunning ? Icons.wifi : Icons.wifi_off,
                      color: status.isRunning ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Server Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('IP Address: ${status.ipAddress ?? "Loading..."}'),
                Text('Port: ${status.port}'),
                if (status.isRunning) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Endpoints:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('GET  http://${status.ipAddress}:${status.port}/health'),
                        Text('POST http://${status.ipAddress}:${status.port}/generate'),
                        Text('GET  http://${status.ipAddress}:${status.port}/model'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🌐 Web Chat UI:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                'http://${status.ipAddress}:${status.port}/chat',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: status.isRunning
                      ? () => provider.stopServer()
                      : () => provider.startServer(),
                  icon: Icon(status.isRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(status.isRunning ? 'Stop Server' : 'Start Server'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status.isRunning ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}