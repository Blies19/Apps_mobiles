import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  final List<String> _receivedDataList = [];
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _disconnectDevice();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _devices = [];
      _isScanning = true;
      _receivedDataList.clear();
    });

    // Verificar si Bluetooth está encendido
    if (await FlutterBluePlus.isAvailable == false) {
      _showSnackBar("Bluetooth no está disponible en este dispositivo");
      setState(() => _isScanning = false);
      return;
    }

    if (await FlutterBluePlus.isOn == false) {
      _showSnackBar("Por favor enciende el Bluetooth");
      setState(() => _isScanning = false);
      return;
    }

    // Solicitar permisos si es necesario
    await _requestPermissions();

    // Iniciar escaneo
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _devices = results
              .where((result) => result.device.platformName.isNotEmpty)
              .toList();
        });
      });

      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _showSnackBar("Error al escanear: ${e.toString()}");
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _requestPermissions() async {
    // En Android, necesitamos solicitar permisos de ubicación para BLE
    if (await FlutterBluePlus.isSupported) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null &&
        _connectedDevice!.remoteId == device.remoteId) {
      _showSnackBar("Ya estás conectado a este dispositivo");
      return;
    }

    setState(() {
      _isScanning = false;
      _receivedDataList.clear();
    });

    try {
      await _disconnectDevice(); // Desconectar cualquier dispositivo previo

      setState(() => _connectedDevice = device);
      _showSnackBar("Conectando a ${device.platformName}...");

      await device.connect(autoConnect: false);
      _showSnackBar("Conectado a: ${device.platformName}");

      // Descubrir servicios
      List<BluetoothService> services = await device.discoverServices();
      _showSnackBar("Servicios descubiertos: ${services.length}");

      // Explorar características
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          await _handleCharacteristic(service, characteristic);
        }
      }
    } catch (e) {
      _showSnackBar("Error al conectar: ${e.toString()}");
      await _disconnectDevice();
    }
  }

  Future<void> _handleCharacteristic(
      BluetoothService service, BluetoothCharacteristic characteristic) async {
    final serviceUuid = service.uuid.toString();
    final charUuid = characteristic.uuid.toString();

    try {
      // Lectura de características
      if (characteristic.properties.read) {
        List<int> value = await characteristic.read();
        setState(() {
          _receivedDataList.add(
            "Servicio: $serviceUuid\n"
            "Característica: $charUuid\n"
            "Tipo: Lectura\n"
            "Valor: ${String.fromCharCodes(value)}\n",
          );
        });
      }

      // Configurar notificaciones
      if (characteristic.properties.notify ||
          characteristic.properties.indicate) {
        await characteristic.setNotifyValue(true);
        characteristic.onValueReceived.listen((value) {
          setState(() {
            _receivedDataList.add(
              "Servicio: $serviceUuid\n"
              "Característica: $charUuid\n"
              "Tipo: Notificación\n"
              "Valor: ${String.fromCharCodes(value)}\n",
            );
          });
        });
      }
    } catch (e) {
      debugPrint(
          "Error al interactuar con característica $charUuid: ${e.toString()}");
    }
  }

  Future<void> _disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        _showSnackBar("Desconectado de ${_connectedDevice!.platformName}");
      } catch (e) {
        debugPrint("Error al desconectar: ${e.toString()}");
      } finally {
        setState(() => _connectedDevice = null);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_devices.isEmpty) {
      return const Center(
        child: Text(
          "No se encontraron dispositivos Bluetooth.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final result = _devices[index];
        final device = result.device;
        final isConnected = _connectedDevice?.remoteId == device.remoteId;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              device.platformName.isNotEmpty
                  ? device.platformName
                  : "Dispositivo sin nombre",
              style: TextStyle(
                fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                color: isConnected ? Colors.blue : Colors.black,
              ),
            ),
            subtitle: Text(device.remoteId.toString()),
            trailing: Icon(
              Icons.bluetooth,
              color: isConnected ? Colors.blue : Colors.grey,
            ),
            onTap: () => _connectToDevice(device),
          ),
        );
      },
    );
  }

  Widget _buildReceivedDataList() {
    if (_receivedDataList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "No se han recibido datos aún.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _receivedDataList.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                _receivedDataList[index],
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos Bluetooth BLE"),
        actions: [
          if (_connectedDevice != null)
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: _disconnectDevice,
              tooltip: "Desconectar",
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "Dispositivos encontrados:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildDeviceList()),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  "Datos recibidos:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildReceivedDataList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _startScan,
        tooltip: 'Escanear',
        child: _isScanning
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.refresh),
      ),
    );
  }
}
