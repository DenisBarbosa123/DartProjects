import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;

  List<CartProduct> products = [];

  String coupomCode;
  int discountPercentage = 0;

  CartModel(this.user) {
    if(user.isLoggedIn()){
      _loadCartItems();
    }
  }

  bool isLoading = false;

  static CartModel of(BuildContext context) => ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);

    Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart")
    .add(cartProduct.toMap()).then((doc) {
      cartProduct.cid = doc.documentID;
    });

    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct){
    Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cid).delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity --;
    Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity ++;
    Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cid).updateData(cartProduct.toMap());

    notifyListeners();
  }
  
  void setCoupon(String couponCode, int discountPercentage){
    this.coupomCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  double getProductsPrice() {
    double price = 0.0;
    products.forEach((product) => {
      if(product.productData != null){
        price +=  product.quantity * product.productData.price
      }
    });
    return price;
  }

  double getShipPrice() {
    return 9.99;
  }

  double getDiscount() {
    return getProductsPrice() * discountPercentage / 100;
  }

  void updatePrices(){
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if(products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double productPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    DocumentReference refOrder = await Firestore.instance.collection("orders").add(
      {
        "clientId" : user.firebaseUser.uid,
        "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
        "shipPrice" : shipPrice,
        "productsPrice" : productPrice,
        "discount" : discount,
        "totalPrice" : productPrice - discount + shipPrice,
        "status" : 1
      }
    );

    await Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("orders")
    .document(refOrder.documentID).setData(
      {"orderId" : refOrder.documentID}
    );

    QuerySnapshot query = await Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart").getDocuments();

    query.documents.forEach((product) => {
      product.reference.delete()
    });

    products.clear();

    discountPercentage = 0;
    coupomCode = null;
    isLoading = false;
    notifyListeners();
    return refOrder.documentID;
  }

  Future<void> _loadCartItems() async {

    QuerySnapshot snapshot = await Firestore.instance.collection("users")
    .document(user.firebaseUser.uid).collection("cart").getDocuments();

    products = snapshot.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

}