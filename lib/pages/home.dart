import 'dart:io';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_names/provider/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
/*    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 3),
    Band(id: '3', name: 'Heroes del Silencia', votes: 15),
    Band(id: '4', name: 'Bon Jovi', votes: 2),*/
  ];

  @override
  void initState() {

// se inicia el socket del servidor
    final socketService = Provider.of<SocketService>(context, listen: false);

// aqui recibo las bandas activas desde el servidor
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

// para quitar el codigo del initState
  _handleActiveBands ( dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

// para refrescar la pantalla
    setState(() {});
  }

  @override
  void dispose() {

// esto para dejar de escuchar desde el servidor cuando se cierre la app
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // para llamar al provider
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                  ?  Icon(Icons.check_circle, color: Colors.blue[300],)
                  : Icon(Icons.offline_bolt, color: Colors.red,)
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, i) => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

// para mostrar las bandas
  Widget _bandTile(Band band) {
// llamar al servidor
    final socketService = Provider.of<SocketService>(context, listen: false);

    // con esto se puede mover el texto para eliminarlo
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,

      // llamar el borrado en el server
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),

      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Borrar banda",
              style: TextStyle(color: Colors.white),
            ),
          )),
      child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: TextStyle(fontSize: 20),
          ),

// para votar a una banda
          onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),

      ),
    );
  }

// para agregar una nueva banda
  addNewBand() {
    final textController = new TextEditingController();

// para validar si es Android
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text('Nueva banda'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text("Add"),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
              ),
            ],
          ),
      );
    }

// para validar si es Android
    if (!Platform.isAndroid) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
              title: Text("New band name"),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Add"),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text("Dismiss"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    }
  }

// para diferenciar entre IOS y Android el Dialog
  void addBandToList(String name) {
    if (name.length > 1) {
      // para agregar una nueva banda
// llamar al servidor
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

// para mostrar la grafica de los votos
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
        dataMap.putIfAbsent(band.name, () => band.votes.toDouble() );
    });

    List<Color> colorList = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ];

    return Container(
      padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 180,
 //       child: PieChart(dataMap: dataMap));
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
//          chartLegendSpacing: 32.0,
//          chartRadius: MediaQuery.of(context).size.width / 2.7,
          showChartValuesInPercentage: true,
          showChartValues: true,
          showChartValuesOutside: false,
          chartValueBackgroundColor: Colors.grey[200],
          colorList: colorList,
          showLegends: true,
          legendPosition: LegendPosition.right,
          decimalPlaces: 0,
//          showChartValueLabel: true,
          initialAngle: 0,
/*
          chartValueStyle: defaultChartValueStyle.copyWith(
            color: Colors.blueGrey[900].withOpacity(0.9),
          ),
*/
          chartType: ChartType.ring,
        ),
    );
  }
}
