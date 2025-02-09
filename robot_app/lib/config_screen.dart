import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/app_state.dart';
import 'custom_app_bar.dart';
import 'menu_drawer.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConfigScreen extends StatefulWidget {
  final bool isInitialSetup;

  ConfigScreen({this.isInitialSetup = false});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  String? _scanResult;
  String? _ssid;
  String? _password;

  @override
  void initState() {
    super.initState();
    _checkNetwork();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  /// Checks if the user is connected to WiFi.
  Future<void> _checkNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.wifi) {
      _showErrorDialog(
          "This app requires a WiFi connection. Please connect to WiFi.");
    }
  }

  /// Handles network changes to prevent mobile data usage.
  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.wifi) {
      _showErrorDialog(
          "You have switched to mobile data, please turn it off and reconnect to WiFi.");
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrController?.pauseCamera();
    } else if (Platform.isIOS) {
      _qrController?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_scanResult == null) {
        setState(() {
          _scanResult = scanData.code;
        });
        _qrController?.pauseCamera();
        _processScanResult(scanData.code);
      }
    });
  }

  void _processScanResult(String? code) {
    if (code == null) return;

    if (code.startsWith("WIFI:")) {
      final ssidMatch = RegExp(r'S:([^;]+);').firstMatch(code);
      final passwordMatch = RegExp(r'P:([^;]+);').firstMatch(code);

      if (ssidMatch != null) {
        _ssid = ssidMatch.group(1);
      }
      if (passwordMatch != null) {
        _password = passwordMatch.group(1);
      }
    } else {
      List<String> parts = code.split(',');
      if (parts.length >= 2) {
        _ssid = parts[0];
        _password = parts[1];
      }
    }

    if (_ssid != null && _password != null) {
      _showConnectDialog();
    } else {
      _showErrorDialog("Invalid QR Code format. Please try again.");
      _qrController?.resumeCamera();
    }
  }

  void _showConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to WiFi'),
        content: Text('SSID: $_ssid\nPassword: $_password'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _qrController?.resumeCamera();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _connectToWifi();
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToWifi() async {
    bool connected = false;
    try {
      connected = await WiFiForIoTPlugin.connect(
        _ssid!,
        password: _password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );
    } catch (e) {
      connected = false;
    }

    if (connected) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('wifi_ssid', _ssid!);
      await prefs.setString('wifi_password', _password!);

      if (widget.isInitialSetup) {
        Navigator.pushReplacementNamed(context, '/jobs');
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      _showErrorDialog("Failed to connect to the WiFi network.");
      _qrController?.resumeCamera();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _qrController?.resumeCamera();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    appState.initTimer();
    return Scaffold(
      appBar: CustomAppBar(title: 'Robot Control'),
      drawer: MenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Theme.of(context).primaryColor,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 250,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 1,
              child: Center(
                child: _scanResult != null
                    ? Text('Scanned: $_scanResult')
                    : Text('Point the camera at a WiFi QR code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
