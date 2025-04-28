import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/task.dart';

class MyBluetoothService {
  static Future<List<BluetoothDevice>> scanDevices(
      {Duration timeout = const Duration(seconds: 5)}) async {
    List<BluetoothDevice> devices = [];

    await FlutterBluePlus.startScan(timeout: timeout);

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          devices.add(result.device);
        }
      }
    });

    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();

    return devices;
  }

  static Future<void> sendTasksToDevice(
      BluetoothDevice device, List<Task> tasks) async {
    await device.connect();

    List<BluetoothService> services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          for (Task task in tasks) {
            String message = "TAREA: ${task.title}";
            await characteristic.write(message.codeUnits);
            await Future.delayed(const Duration(milliseconds: 300));
          }
          break;
        }
      }
    }

    await device.disconnect();
  }
}
