import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constant/constant.dart';
import '../mainpages/home_routes.dart';
import 'auth_services.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailField.dispose();
    passwordField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            elevation: 8,
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Selamat Datang'),
            ),
          ),
          SliverFillRemaining(
            child: Container(
              decoration: const BoxDecoration(
                  gradient:
                      LinearGradient(begin: Alignment.bottomCenter, colors: [
                lPrimaryColor,
                mPrimaryColor,
                nPrimaryColor,
              ])),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 120,
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Bank Sampah Pontianak',
                                style: CustomBS.titleBar,
                              ))),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: emailField,
                          decoration: const InputDecoration(
                            hintText: "email@mail.com",
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email Harus Diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 35),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: passwordField,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "password",
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password Harus Diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 35),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.4,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                        child: MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  isLoading = true;
                                });
                                bool result = await AuthServices.signIn(
                                    emailField.text, passwordField.text);
                                if (result) {
                                  Fluttertoast.showToast(
                                      msg: 'Selamat Datang',
                                      gravity: ToastGravity.CENTER_RIGHT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.teal);
                                  emailField.clear();
                                  passwordField.clear();
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeRoutePage(selected: 0),
                                    ),
                                  );
                                }
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: const Text("Login")),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 35),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.4,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.white,
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() {
                                isLoading = true;
                              });
                              bool result = await AuthServices.signUp(
                                  emailField.text, passwordField.text);
                              if (result) {
                                Fluttertoast.showToast(
                                    msg: 'Registrasi Berhasil. Silahkan Login',
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green);
                                emailField.clear();
                                passwordField.clear();
                              }
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: const Text("Register"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
