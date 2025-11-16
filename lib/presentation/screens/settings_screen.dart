import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../../data/models/model_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ModelSettings _currentSettings;
  final _systemPromptController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<ServerProvider>(context, listen: false);
    _currentSettings = provider.modelSettings;
    _systemPromptController.text = _currentSettings.systemPrompt;
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Settings'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-width card at the top
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _SettingChip(
                        label: 'Temperature',
                        value: _currentSettings.temperature.toStringAsFixed(2),
                        color: Colors.blue,
                      ),
                      _SettingChip(
                        label: 'Max Tokens',
                        value: _currentSettings.maxTokens.toString(),
                        color: Colors.green,
                      ),
                      _SettingChip(
                        label: 'Top P',
                        value: _currentSettings.topP.toStringAsFixed(2),
                        color: Colors.purple,
                      ),
                      _SettingChip(
                        label: 'Top K',
                        value: _currentSettings.topK.toString(),
                        color: Colors.orange,
                      ),
                      _SettingChip(
                        label: 'Repeat Penalty',
                        value: _currentSettings.repeatPenalty.toStringAsFixed(2),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_currentSettings.systemPrompt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'System Prompt:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentSettings.systemPrompt.length > 100
                          ? '${_currentSettings.systemPrompt.substring(0, 100)}...'
                          : _currentSettings.systemPrompt,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Model Parameters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust the parameters to control how the AI model generates responses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),
            _buildSliderSetting(
              'Temperature',
              _currentSettings.temperature,
              0.0,
              2.0,
                  (value) => setState(() {
                _currentSettings = _currentSettings.copyWith(temperature: value);
              }),
              'Controls randomness: Lower = more deterministic, Higher = more creative',
              icon: Icons.thermostat,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              'Max Tokens',
              _currentSettings.maxTokens.toDouble(),
              1,
              2048,
                  (value) => setState(() {
                _currentSettings = _currentSettings.copyWith(maxTokens: value.toInt());
              }),
              'Maximum number of tokens to generate',
              icon: Icons.format_size,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              'Top P',
              _currentSettings.topP,
              0.0,
              1.0,
                  (value) => setState(() {
                _currentSettings = _currentSettings.copyWith(topP: value);
              }),
              'Nucleus sampling: Consider tokens with top_p probability mass',
              icon: Icons.show_chart,
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              'Top K',
              _currentSettings.topK.toDouble(),
              1,
              100,
                  (value) => setState(() {
                _currentSettings = _currentSettings.copyWith(topK: value.toInt());
              }),
              'Consider only top K tokens',
              icon: Icons.filter_alt,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              'Repeat Penalty',
              _currentSettings.repeatPenalty,
              1.0,
              2.0,
                  (value) => setState(() {
                _currentSettings = _currentSettings.copyWith(repeatPenalty: value);
              }),
              'Penalty for repeated tokens',
              icon: Icons.repeat,
              color: Colors.red,
            ),
            const SizedBox(height: 24),

            // System Prompt Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat,
                        color: Colors.indigo.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'System Prompt',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define the AI\'s personality and behavior. This prompt will be used for all conversations.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _systemPromptController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'You are a helpful assistant. Answer concisely and stay on topic...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (value) => setState(() {
                      _currentSettings = _currentSettings.copyWith(systemPrompt: value);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
      String label,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged,
      String description, {
        required IconData icon,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            divisions: (max - min) ~/ 0.1,
            activeColor: color,
            inactiveColor: color.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    final provider = Provider.of<ServerProvider>(context, listen: false);
    provider.updateModelSettings(_currentSettings);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SettingChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}