import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 3),
    Band(id: '3', name: 'Heroes del Silencia', votes: 15),
    Band(id: '4', name: 'Bon Jovi', votes: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTile(bands[i])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

// para mostrar las bandas
  Widget _bandTile(Band band) {
    // con esto se puede mover el texto para eliminarlo
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print("direction: $direction");
        // llamar el borrado en el server
      },
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
          onTap: () {
            print(band.name);
          }),
    );
  }

// para agregar una nueva banda
  addNewBand() {
    final textController = new TextEditingController();

// para validar si es Android
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
          );
        },
      );
    }

// para validar si es Android
    if (!Platform.isAndroid) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
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
            );
          });
    }
  }

// para diferenciar entre IOS y Android el Dialog
  void addBandToList(String name) {
    if (name.length > 1) {
      // podemos agregar
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
    }
    setState(() {});
    Navigator.pop(context);
  }
}
