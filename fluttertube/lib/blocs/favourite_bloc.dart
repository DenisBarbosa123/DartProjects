import 'dart:async';
import 'dart:convert';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fluttertube/models/video.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouriteBloc implements BlocBase {
  Map<String, Video> _favourites = {};

  final _favController = BehaviorSubject<Map<String, Video>>(seedValue: {});
  Stream<Map<String, Video>> get outFav => _favController.stream;

  FavouriteBloc() {
    SharedPreferences.getInstance().then((prefs){
      if(prefs.getKeys().contains("favourites")) {
        _favourites = json.decode(prefs.getString("favourites")).map(
            (key, value){
              return MapEntry(key, Video.fromJson(value));
            }
        ).cast<String, Video>();
        _favController.add(_favourites);
      }
    });
  }


  void toggleFavourite(Video video) {
    if(_favourites.containsKey(video.id)) _favourites.remove(video.id);
    else _favourites[video.id] = video;

    _favController.sink.add(_favourites);
    
    _saveFav();
  }
  
  void _saveFav(){
    SharedPreferences.getInstance().then(
        (prefs) {
          prefs.setString("favourites", json.encode(_favourites));
        }
    );
  }

  @override
  void dispose() {
    _favController.close();
  }

}