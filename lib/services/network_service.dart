import 'package:network_info_plus/network_info_plus.dart';
import '../core/utils/logger.dart';

class NetworkService {
  Future<String?> getLocalIPAddress() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      Logger.log('IP Address obtained: $wifiIP', tag: 'NETWORK');
      return wifiIP;
    } catch (e, stackTrace) {
      Logger.error('Failed to get IP address', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}