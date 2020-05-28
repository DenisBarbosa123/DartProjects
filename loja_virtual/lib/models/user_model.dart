import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';

class UserModel extends Model {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String,dynamic> userData = Map();
  bool isLoading = false;

  static UserModel of(BuildContext context) {
    return ScopedModel.of<UserModel>(context);
  }

  @override
  void addListener(listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signUp({@required Map<String, dynamic> userData, 
    @required String userPassword, 
      @required VoidCallback onSuccess, 
       @required VoidCallback onFail})
  {
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
      email: userData["email"], 
      password: userPassword).then((user) async {
        firebaseUser = user;
        onSuccess();
        await _saveUserData(userData);
        isLoading = false;
        notifyListeners();
      }).catchError((e) {
        print(e);
        onFail();
        isLoading = false;
        notifyListeners();
      });
    
  }

  Future<void> signIn({@required String email, 
    @required String password, 
      @required VoidCallback onSuccess, 
        @required VoidCallback onFail}) async 
  {
    isLoading = true;
    notifyListeners();
    
    _auth.signInWithEmailAndPassword(email: email, password: password).then((user) async {
      firebaseUser = user;
      await _loadCurrentUser();

      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      print(e);
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void recoverPassword(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  bool isLoggedIn(){
     return firebaseUser != null;
  }

  Future<Null>_saveUserData(Map<String, dynamic> userData) async{
    this.userData = userData;
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  Future<Null> _loadCurrentUser() async{
    if(firebaseUser == null){
     firebaseUser = await _auth.currentUser();
    }
    if(firebaseUser != null){
      if(userData["name"] == null){
        DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }
}