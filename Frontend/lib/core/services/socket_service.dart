import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  static SocketService? _instance;
  static SocketService get instance => _instance ??= SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  static String get _serverUrl => AppConfig.serverBaseUrl;

  SocketService._internal();

  void init() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      print("[SocketService] Connected to server");
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      print("[SocketService] Disconnected from server: $reason");
    });

    _socket!.onConnectError((err) {
      print("[SocketService] Connection error: $err");
    });

    _socket!.connect();
  }

  void joinGroup(String groupId) {
    if (_socket == null) init();
    _socket?.emit("join_group", groupId);
    print("[SocketService] Emitted join_group: $groupId");
  }

  void leaveGroup(String groupId) {
    _socket?.emit("leave_group", groupId);
    print("[SocketService] Emitted leave_group: $groupId");
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket == null) init();
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
