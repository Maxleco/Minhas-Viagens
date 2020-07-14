import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore _db = Firestore.instance;

  _abrirMapa(String idViagem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Mapa(idViagem: idViagem),
      ),
    );
  }

  _excluirViagem(String idViagem) {
    _db.collection("viagens").document(idViagem).delete();
  }

  _adicionarLocal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Mapa(),
      ),
    );
  }

  _adicionarListenerViagens() async {
    final stream = _db.collection("viagens").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Viagens"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              Widget defaultWidget;
              if (snapshot.connectionState == ConnectionState.waiting) {
                defaultWidget = Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasError) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Error ao carregar Viagens!",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                QuerySnapshot querySnapshot = snapshot.data;
                if (querySnapshot != null &&
                    querySnapshot.documents.length == 0) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        "Nenhuma Viagem encontradsa :(",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                List<DocumentSnapshot> viagens =
                    querySnapshot.documents.toList();
                defaultWidget = ListView.builder(
                  itemCount: viagens.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot viagem = viagens[index];
                    String titulo = viagem["titulo"];
                    String idViagem = viagem.documentID;
                    return Card(
                      child: ListTile(
                        onTap: () => _abrirMapa(idViagem),
                        title: Text(titulo),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            _excluirViagem(idViagem);
                          },
                        ),
                      ),
                    );
                  },
                );
              } else {
                defaultWidget = Container();
              }
              return defaultWidget;
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF0066cc),
        onPressed: () {
          _adicionarLocal();
        },
      ),
    );
  }
}
