import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Entrar"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignupScreen())
              );
            }, 
            child: Text(
              "CRIAR CONTA", 
              style: TextStyle(fontSize: 15.0, color: Colors.white),
            ),
          )
        ],
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {

          if(model.isLoading){
            return Center(child: CircularProgressIndicator());
          }
            
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "E-mail"
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if(text.isEmpty || !text.contains("@")) return "E-mail inválido";
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "Senha"
                  ),
                  obscureText: true,
                  validator: (text) {
                    if(text.isEmpty) return "Senha inválida";
                    if(text.length < 6) return "Necessário que senha tenha mais de 6 caracteres";
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                      onPressed: (){
                        if(_emailController.text.isEmpty){
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Insira seu e-mail para recuperação"),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            )
                          );
                        }else{
                          model.recoverPassword(_emailController.text);
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Confira seu e-mail"),
                              backgroundColor: Theme.of(context).primaryColor,
                              duration: Duration(seconds: 2),
                            )
                          );
                        }
                      }, 
                      child: Text(
                      "Esqueci minha senha", 
                      textAlign: TextAlign.right,
                    ),
                    padding: EdgeInsets.zero,
                  )
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    onPressed: (){
                      if(_formKey.currentState.validate()){

                      }
                      model.signIn(
                        email: _emailController.text,
                        password: _passwordController.text,
                        onSuccess: _onSuccess,
                        onFail: _onFail
                      );
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(
                        fontSize: 18.0
                      ),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          );
        },
      )
    );
  }
  void _onSuccess(){
    Navigator.of(context).pop();
  }

  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text("Falha ao Entrar"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      )
    );
  }
}