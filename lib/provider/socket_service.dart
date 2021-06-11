import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

// para las escuchas del servidor
  IO.Socket get socket => this._socket;

// esto es para enviar un mensaje a todos los clientes
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    this._socket = IO.io('http://192.168.0.122:3000/', {
//    this._socket = IO.io('http://localhost:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

 /*// para escuchar un evento del servidor
    this._socket.on('nuevo-mensaje', (payload) {

       print("Recibiendo mensaje");

       print('Nombre: ' + payload['nombre']);
       print('Mensaje: ' + payload['mensaje']);
       print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay 2');
    });*/

// para dejar de escuchar los mensajes
 //   socket.off('nuevo-mensaje');

  }
}
