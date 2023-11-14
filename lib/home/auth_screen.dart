import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/navigation/navigation_block.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ViewModel.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreen_State createState() => _AuthScreen_State();
}

class _AuthScreen_State extends State<AuthScreen> {
  bool isAuth = true;
  bool isChecked = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    return Scaffold(
      body: SafeArea(child:Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ValueListenableBuilder<AuthData?>(
            valueListenable: Provider.of<AppViewModel>(context).authDataNotifier,
            builder: (context, authData, child){

              _loginController.text = authData != null ? authData.login : '';
              _passwordController.text = authData != null ? authData.password : '';

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    isAuth?'Авторизация':'Регистрация',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                      child: Form(
                    key: _formKey,
                    child: Column(children: [
                      if(!isAuth) ...[TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Имя",
                          fillColor: Colors.black12,
                          filled: true,),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Введите имя';
                          }
                          if (value.length < 2 || value.length > 32) {
                            return 'Имя не может иметь такую длину';
                          }
                          return null; // Возвращаем null в случае успешной валидации
                        },
                      ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _surnameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Фамилия",
                            fillColor: Colors.black12,
                            filled: true,),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Введите фамилию';
                            }
                            if (value.length < 2 || value.length > 32) {
                              return 'Фамилия не может иметь такую длину';
                            }
                            return null; // Возвращаем null в случае успешной валидации
                          },
                        ), const SizedBox(height: 20.0),],
                      TextFormField(
                        controller: _loginController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "E-mail",
                          fillColor: Colors.black12,
                          filled: true,),
                        validator: (value){
                          final RegExp emailRegExp = RegExp(
                            r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.\w{2,})$',
                          );

                          if (value!.isEmpty) {
                            return 'Введите email';
                          }
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Введите корректный email';
                          }
                          return null; // Возвращаем null в случае успешной валидации
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Пароль",
                            fillColor: Colors.black12,
                            filled: true),
                        validator: (value){
                          if (value!.isEmpty) {
                            return 'Введите пароль';
                          }
                          if (value.contains(' ')) {
                            return 'Пароль не должен содержать пробелы';
                          }
                          if (value.length < 6) {
                            return 'Пароль должен содержать не менее 6 символов';
                          }
                          return null;
                        },
                      ),
                      if(!isAuth) ...[const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _repPassController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Пароль",
                            fillColor: Colors.black12,
                            filled: true,),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Введите пароль повтроно';
                            }

                            return null; // Возвращаем null в случае успешной валидации
                          },
                        ),],
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isChecked = !isChecked;
                              });
                            },
                            child: Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: isChecked ? Colors.blue : Colors.white,
                                border: Border.all(color: Colors.blue, width: 2.0),
                              ),
                              child: isChecked
                                  ? const Icon(
                                Icons.check,
                                size: 18.0,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 5,),
                          const Text("Запомнить меня")
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(//-!-!-!temp data's!-!-!-!
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if(isAuth) {
                                  String login = _loginController.text;
                                  String password = _passwordController.text;
                                  try{
                                    await appViewModel.signIn(login, password);
                                    print("sgnin");
                                    BlocProvider.of<NavigationBloc>(context)
                                        .removeLastFromBS();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToCardsScreenEvent());
                                    print("open cards");
                                  }catch(ex){}
                                }else{
                                  String name = _nameController.text;
                                  String surname = _surnameController.text;
                                  String login = _loginController.text;
                                  String password = _passwordController.text;
                                  String repPass = _repPassController.text;
                                  if(password==repPass) {
                                    await appViewModel.register(ProfileData(name: name, surname: surname), AuthData(login: login, password: password));
                                    BlocProvider.of<NavigationBloc>(context)
                                        .removeLastFromBS();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToCardsScreenEvent());
                                  }else{
                                    _showError("Пароли не совпадают");
                                  }
                                }
                              }
                            },
                            child: Text(isAuth?'Войти':'Зарегистрироваться'),
                          )),
                      const SizedBox(height: 10.0),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isAuth = !isAuth;
                              });
                            },
                            child: Text(isAuth?'Регистрация':'Авторизация'),
                          )),
                      const SizedBox(height: 10.0),
                      const Text('Восстановить пароль')
                    ],),)),
                  const SizedBox(height: 10.0)
                ],
              );
            },
          )
        ),
      ),
    ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3), // Установите желаемую продолжительность отображения
      ),
    );
  }
}
