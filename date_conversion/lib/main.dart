
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Time Calculator",
    home: Home(),
  ));
  
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  TextEditingController valueByHourController = TextEditingController();
  String result = "Informe seus dados";

  void resetFields(){
    hourController.text = "";
    minuteController.text = "00";
    valueByHourController.text = "";

    setState(() {
      result = "Informe seus dados";
    });
  }

  void calcular(){
    setState(() {
      double hora = double.parse(hourController.text);
      double minuto = double.parse(minuteController.text);
      double valor = double.parse(valueByHourController.text);

      if(minuto!=0){
        double aux = minuto/60;
        print(aux);
        hora = hora + aux;
      }

      print(hora * valor);

      result = "Resultado total é R\$ ${(hora * valor).toStringAsFixed(2)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: 
        AppBar(title: Text("Time Calculator"),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: 
            <Widget>[
              IconButton(
                icon: Icon(Icons.refresh), 
                onPressed: () {
                  resetFields();
                },
              )
            ]
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Horas",
                    labelStyle: TextStyle(
                      color: Colors.black
                    )
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 25.0
                  ),
                  controller: hourController,
                ),
                TextFormField(
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Minutos",
                    labelStyle: TextStyle(
                      color: Colors.black
                    )
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 25.0
                  ),
                  controller: minuteController,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Valor por hora",
                    labelStyle: TextStyle(
                      color: Colors.black
                    )
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 25.0
                  ),
                  controller: valueByHourController,
                ),
                Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 15.0),
                child:  Container(
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () {
                      calcular();
                    },//Calc Button Action
                    child: Text(
                      "Calcular",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0),
                    ),
                    color: Colors.green,
                  ),
                ),
              ),
              Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 25.0),
              )
              ],
            ),
          ),
        ),
    );
  }
}