import 'hair_refresher_device.dart';

class HairRefresherDeviceService {
  const HairRefresherDeviceService();

  static const demoDevice = HairRefresherDevice(
    id: 'LG_HAIR_REFRESHER_DEMO_001',
    name: 'LG Hair Refresher Demo',
    isConnected: true,
  );

  Future<HairRefresherDevice> connectDemoDevice() async {
    return demoDevice;
  }
}
