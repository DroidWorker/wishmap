import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/message_item.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import '../ViewModel.dart';
import '../navigation/navigation_block.dart';
import '../res/colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreen_State createState() => _AuthScreen_State();
}

class _AuthScreen_State extends State<AuthScreen> {
  bool isChecked = true;
  bool isInLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repPassController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  static const List<String> allowToEdit = ["Введите имя, фамилию", "Выберите дату рождения", "Выберите ваш пол", "Введите ваш e-mail", "Введите пароль"];

  List<String> messagesReg = ["Введите имя, фамилию"];
  List<String> messagesAuth = ["Введите email"];

  bool inputEnabled = true;
  bool allowChangingDatas = false;
  bool isAuth = true;
  bool isPassChecked = false;

  String name = "";
  DateTime? birthday;
  bool? man;
  String login = '';
  String password = "";

  AppViewModel? vm;

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<AppViewModel>(context);
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ValueListenableBuilder<AuthData?>(
                valueListenable:
                    Provider.of<AppViewModel>(context).authDataNotifier,
                builder: (context, authData, child) {
                  _loginController.text =
                      authData != null ? authData.login : '';
                  _passwordController.text =
                      authData != null ? authData.password : '';

                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: isAuth
                                ? messagesAuth.length
                                : messagesReg.length,
                            itemBuilder: (context, index) {
                              if (!isAuth &&
                                  messagesReg[index] ==
                                      'Выберите дату рождения') {
                                return MessageItem(
                                    index % 2 != 0, messagesReg[index],
                                    false,
                                    onAction: (date) {
                                  setState(() {
                                    birthday = DateTime.parse(date);
                                    messagesReg.add(birthday.toString());
                                    _messageController.clear();
                                    if(man==null){messagesReg.add("Выберите ваш пол");inputEnabled=false;}else{
                                      getNextMessage();
                                      inputEnabled=true;
                                    }
                                  });
                                });
                              } else if (!isAuth &&
                                  messagesReg[index] == 'Выберите ваш пол') {
                                return MessageItem(
                                    index % 2 != 0, messagesReg[index],
                                    false,
                                    onAction: (gender) {
                                  setState(() {
                                    man = bool.parse(gender);
                                    messagesReg
                                        .add(man! ? "Мужской" : "Женский");
                                    _messageController.clear();
                                    if(login.isEmpty){messagesReg.add("Введите ваш e-mail");}else{
                                      getNextMessage();
                                    }
                                    inputEnabled = true;
                                  });
                                });
                              } else if(!isAuth&&messagesReg[index]=="Проверьте введенные данные и подтвердите"){
                                return MessageItem(
                                    index % 2 != 0, messagesReg[index], false,
                                    onAction: (action) async {
                                      if(action=="registration"){
                                        messagesReg.add("Pегистрация...");
                                        await vm?.register(ProfileData(name: name, surname: 'surname'), AuthData(login: login, password: password));
                                        BlocProvider.of<NavigationBloc>(context)
                                            .removeLastFromBS();
                                        BlocProvider.of<NavigationBloc>(context)
                                            .add(NavigateToCardsScreenEvent());
                                      }else{
                                        setState(() {
                                          messagesReg.add("Хочу изменить данные");
                                          allowChangingDatas=true;
                                          messagesReg.add("Выберите сообщение которое необходимо изменить");
                                        });
                                      }
                                    });
                              }else {
                                final flag = index-1>0?allowToEdit.contains(messagesReg[index-1]):false;
                                return MessageItem(
                                    index % 2 != 0,
                                    isAuth
                                        ? messagesAuth[index]
                                        : messagesReg[index], allowChangingDatas&&flag, onTap: (){
                                      setState(() {
                                        if(index>0&&messagesReg[index-1]=="Введите имя, фамилию"){
                                          messagesReg.add("изменить имя, фамилию");
                                          _messageController.text=messagesReg[index];
                                          name="";
                                          messagesReg.add("Введите имя, фамилию");
                                        }else if(index>0&&messagesReg[index-1]=="Выберите дату рождения"){
                                          messagesReg.add("изменить дату рождения");
                                          _messageController.text=messagesReg[index];
                                          birthday=null;
                                          messagesReg.add("Выберите дату рождения");
                                        }else if(index>0&&messagesReg[index-1]=="Выберите ваш пол"){
                                          messagesReg.add("изменить пол");
                                          _messageController.text=messagesReg[index];
                                          man=null;
                                          messagesReg.add("Выберите ваш пол");
                                        }else if(index>0&&messagesReg[index-1]=="Введите ваш e-mail"){
                                          messagesReg.add("изменить email");
                                          _messageController.text=messagesReg[index];
                                          login="";
                                          messagesReg.add("Введите ваш e-mail");
                                        }else if(index>0&&messagesReg[index-1]=="Введите пароль"){
                                          messagesReg.add("изменить пароль");
                                          _messageController.text=messagesReg[index];
                                          password="";
                                          messagesReg.add("Введите пароль");
                                        }
                                        allowChangingDatas=false;
                                      });
                                },);
                              }
                            }),
                      ),
                      Row(children: [
                        Expanded(
                          child: ColorRoundedButton("Авторизация",
                              c: isAuth ? null : AppColors.grey, () {
                            if (!isAuth) {
                              setState(() {
                                isAuth = true;
                              });
                            }
                          }),
                        ),
                        Expanded(
                          child: ColorRoundedButton("Регистрация",
                              c: isAuth ? AppColors.grey : null, () {
                            if (isAuth) {
                              setState(() {
                                isAuth = false;
                              });
                            }
                          }),
                        )
                      ]),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              maxLength: 260,
                              minLines: 1,
                              maxLines: 5,
                              controller: _messageController,
                              enabled: inputEnabled,
                              onTap: () {},
                              style: const TextStyle(color: Colors.black),
                              // Черный текст ввода
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                counterText: "",
                                filled: true,
                                // Заливка фона
                                fillColor: Colors.white,
                                hintText: 'Введите...',
                                // Базовый текст
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(
                                        0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                if (_messageController.text.isEmpty) return;
                                setState(() {
                                  getNextMessage();
                                });
                                _scrollController.jumpTo(
                                    _scrollController.position.maxScrollExtent);
                              },
                              icon: const Icon(Icons.send))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                      text: "условия использования\n",
                                      style: TextStyle(
                                          color: AppColors.blueTextColor)),
                                  TextSpan(
                                      text: "\n",
                                      style: TextStyle(fontSize: 5)),
                                  TextSpan(
                                      text: "политика конфиденциальности",
                                      style: TextStyle(
                                          color: AppColors.blueTextColor))
                                ])),
                      )
                      /*Text(
                    isAuth?'Авторизация':'Регистрация',
                    style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                      child:Center(child:Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
                        onChanged: (text){
                          if(text.contains(" ")){
                            _loginController.text=text.replaceAll(" ", "");
                          }
                        },
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
                                    appViewModel.authData=AuthData(login: login, password: password);
                                    setState(() {
                                      isInLoading = true;
                                    });
                                    await appViewModel.signIn(login, password);
                                    BlocProvider.of<NavigationBloc>(context)
                                        .removeLastFromBS();
                                    BlocProvider.of<NavigationBloc>(context)
                                        .add(NavigateToCardsScreenEvent());
                                  }catch(ex){
                                    setState(() {
                                      isInLoading = false;
                                    });
                                  }
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
                      if(isInLoading) const LinearProgressIndicator(),
                      SizedBox(height: isInLoading?7.0:10.0),
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
                    ],),)))),
                  const SizedBox(height: 10.0)*/
                    ],
                  );
                },
              )),
        ));
  }

  getNextMessage() async {
    if (!inputEnabled) return;
    if (!isAuth) {
      if (name.isEmpty) {
        name = _messageController.text;
        messagesReg.add(_messageController.text);
        _messageController.clear();
        messagesReg.add("Выберите дату рождения");
        inputEnabled = false;
      } else if (login.isEmpty) {
        final RegExp emailRegExp = RegExp(
          r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.\w{2,})$',
        );
        if (!emailRegExp.hasMatch(_messageController.text)) {
          messagesReg.add(_messageController.text);
          messagesReg.add("Email введен неверно");
          return;
        }
        login = _messageController.text;
        messagesReg.add(_messageController.text);
        _messageController.clear();
        messagesReg.add("Введите пароль");
      } else if (password.isEmpty) {
        password = _messageController.text;
        messagesReg.add(_messageController.text);
        _messageController.clear();
        messagesReg.add("Повторите пароль");
      } else if (password == _messageController.text) {
        isPassChecked = true;
        messagesReg.add(_messageController.text);
        _messageController.clear();
        messagesReg.add("Проверьте введенные данные и подтвердите");
      } else if(!isPassChecked) {
        if(_messageController.text.isNotEmpty)messagesReg.add(_messageController.text);
        messagesReg.add("Пароли не совпадают, попробуйте еще раз");
      } else{
        _messageController.clear();
        messagesReg.add("Проверьте введенные данные и подтвердите");
      }
    }else{
      if (login.isEmpty) {
        final RegExp emailRegExp = RegExp(
          r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.\w{2,})$',
        );
        if (!emailRegExp.hasMatch(_messageController.text)) {
          messagesAuth.add(_messageController.text);
          messagesAuth.add("Email введен неверно");
          return;
        }
        login = _messageController.text;
        messagesAuth.add(_messageController.text);
        _messageController.clear();
        messagesAuth.add("Введите пароль");
      } else if (password.isEmpty) {
        password = _messageController.text;
        messagesAuth.add(_messageController.text);
        _messageController.clear();
        messagesAuth.add("Проверяю ввееденные данные...");
        vm?.authData=AuthData(login: login, password: password);
        setState(() {
          isInLoading = true;
        });
        final result = await vm?.signIn(login, password);
        if(result==null) {
          BlocProvider.of<NavigationBloc>(context)
              .removeLastFromBS();
          BlocProvider.of<NavigationBloc>(context)
              .add(NavigateToCardsScreenEvent());
        }else{
          login="";
          password="";
          messagesAuth.add("${result.replaceAll("Exception: ", "")}, введите email");
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
            seconds: 3), // Установите желаемую продолжительность отображения
      ),
    );
  }
}
