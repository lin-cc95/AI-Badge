import 'package:ai_badge/device/device_port.dart';
import 'package:ai_badge/state/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vertical slice reaches connected and synced state', () async {
    final controller = AppController(VirtualDeviceAdapter());
    expect(await controller.login('demo', 'Badge123!'), isTrue);
    controller.choosePersona('元气搭子');
    await controller.generateCharacter();
    controller.selectCharacter(1);
    await controller.pairDevice();
    await controller.syncCharacter();
    expect(controller.state.device.progress, 1);
    expect(controller.state.character?.name, '米露');
    controller.dispose();
  });
}
