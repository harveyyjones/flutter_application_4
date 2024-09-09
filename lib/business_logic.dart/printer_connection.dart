import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ZebraPrinterManager {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> devices = [];
  BluetoothConnection? connection;

  Future<void> getPairedDevices() async {
    devices = await bluetooth.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device');
    } catch (error) {
      print('Cannot connect, exception occurred');
      print(error);
      rethrow;
    }
  }

  Future<void> sendTestPrint() async {
    if (connection != null && connection!.isConnected) {
      try {
        String testMessage = "Hello from Flutter!\n" +
                             "This is a test print for Zebra GK420d\n" +
                             "If you can read this, the print was successful!";
        connection!.output.add(Uint8List.fromList(testMessage.codeUnits));
        await connection!.output.allSent;
        print('Test message sent');
      } catch (e) {
        print('Error sending message: $e');
        rethrow;
      }
    } else {
      throw Exception('Not connected to any device');
    }
  }

  void disconnect() {
    connection?.dispose();
    connection = null;
  }
}

class PrinterSelectionWidget extends StatefulWidget {
  final Function(BluetoothDevice) onDeviceSelected;

  PrinterSelectionWidget({required this.onDeviceSelected});

  @override
  _PrinterSelectionWidgetState createState() => _PrinterSelectionWidgetState();
}

class _PrinterSelectionWidgetState extends State<PrinterSelectionWidget> {
  ZebraPrinterManager _printerManager = ZebraPrinterManager();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() async {
    await _printerManager.getPairedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _printerManager.devices.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_printerManager.devices[index].name ?? "Unknown device"),
                subtitle: Text(_printerManager.devices[index].address),
                onTap: () => widget.onDeviceSelected(_printerManager.devices[index]),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _loadDevices,
          child: Text('Refresh Devices'),
        ),
      ],
    );
  }
}

// Example usage in your existing widget:
class YourExistingWidget extends StatelessWidget {
  final ZebraPrinterManager _printerManager = ZebraPrinterManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zebra Printer Integration')),
      body: Column(
        children: [
          Expanded(
            child: PrinterSelectionWidget(
              onDeviceSelected: (device) async {
                try {
                  await _printerManager.connect(device);
                  await _printerManager.sendTestPrint();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test print sent successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _printerManager.disconnect();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Disconnected from printer')),
              );
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}