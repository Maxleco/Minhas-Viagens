import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  String idViagem;
  Mapa({this.idViagem});
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  Firestore _db = Firestore.instance;
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(41.890434, 12.491855),
    zoom: 18,
  );

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarMarcador(LatLng latLng) async {
    List<Placemark> listEnderecos = await Geolocator().placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    if (listEnderecos != null && listEnderecos.length > 0) {
      Placemark endereco = listEnderecos[0];
      String rua = endereco.thoroughfare;
      Marker marker = Marker(
        markerId: MarkerId("Marcador-${latLng.latitude}|${latLng.longitude}"),
        position: latLng,
        infoWindow: InfoWindow(title: rua),
      );
      //Add Viagem ao FireStore
      Map<String, dynamic> viagem = {
        "titulo": rua,
        "latitude": latLng.latitude,
        "longitude": latLng.longitude,
      };
      setState(() {
        _marcadores.add(marker);
        _db.collection("viagens")
          .add(viagem);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _posicaoCamera,
      ),
    );
  }

  _adicionarListenerLocalizacao() {
    final geolocator = Geolocator();
    final locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    geolocator.getPositionStream(locationOptions).listen(
      (Position position) {
        setState(() {
          _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
          );
          _movimentarCamera();
        });
      },
    );
  }

  void _recuperaViagemById(String idViagem) async {
    if(idViagem != null){
      DocumentSnapshot documentSnapshot = await _db
        .collection("viagens")
        .document(idViagem)
        .get();
      final dados = documentSnapshot.data;
      String titulo = dados["titulo"];
      LatLng latLng = LatLng(dados["latitude"], dados["longitude"]);
      setState(() {
        Marker marker = Marker(
          markerId: MarkerId("Marcador-${latLng.latitude}|${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: titulo),
        );  
        _marcadores.add(marker); 
        _posicaoCamera = CameraPosition(
          target: latLng,
          zoom: 18,
        );  
        _movimentarCamera();  
      });
    }
    else{
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    super.initState();    
    _recuperaViagemById(widget.idViagem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa"),
      ),
      body: Container(
        child: GoogleMap(
          initialCameraPosition: _posicaoCamera,
          mapType: MapType.normal,
          markers: _marcadores,
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
