import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/message_item.dart';
import 'package:wishmap/common/reqCode.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import '../ViewModel.dart';
import '../interface_widgets/sq_checkbox.dart';
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
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tgController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  static const List<String> allowToEdit = [
    "Введите имя, фамилию",
    "Выберите дату рождения",
    "Выберите ваш пол",
    "Введите ваш e-mail",
    "Введите пароль"
  ];

  List<String> messagesReg = ["Введите имя, фамилию"];
  List<String> messagesAuth = ["Введите email"];

  bool inputEnabled = true;
  bool allowChangingDatas = false;
  bool isAuth = true;
  bool isPassRestore = false;
  bool isPassChecked = false;

  String name = "";
  DateTime? birthday;
  bool? male;
  String login = '';
  String password = "";

  AppViewModel? vm;

  List<String> days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> months =
      List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> years = List.generate(90, (index) => (1950 + index).toString());

  String selectedDay = '01';
  String selectedMonth = '01';
  String selectedYear = '1990';

  @override
  void initState() {
    _phoneController.addListener(() {
      if (_phoneController.text.isNotEmpty &&
          !_phoneController.text.startsWith("+"))
        _phoneController.text = "+${_phoneController.text}";
      if (_phoneController.text.length > 1 &&
          !_phoneController.text
              .contains(RegExp("^[0-9]\$"), _phoneController.text.length - 1))
        _phoneController.text = _phoneController.text
            .substring(0, _phoneController.text.length - 1);
    });
    super.initState();
  }

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
                      /*const SizedBox(height: 16),
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
                                        await vm?.register(ProfileData(name: name, surname: 'surname', birtday: birthday??DateTime.now(), male: man??true, email: login, ), AuthData(login: login, password: password));
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
                                final flag = index-1>0&&!isAuth?allowToEdit.contains(messagesReg[index-1]):false;
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
                                WidgetsBinding.instance.addPostFrameCallback((_){
                                  _scrollController.jumpTo(
                                      _scrollController.position.maxScrollExtent);
                                });
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
                      )*/
                      Text(
                        isPassRestore?'Dосстановление пароля':isAuth ? 'Авторизация' : 'Регистрация',
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                          child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (isPassRestore) ...[
                                      const Text(
                                        "Пароль",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        obscuringCharacter: '_',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: "Пароль",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
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
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Повторите пароль",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _repPassController,
                                        obscureText: true,
                                        obscuringCharacter: '_',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: "Пароль",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Введите пароль повтроно';
                                          }

                                          return null; // Возвращаем null в случае успешной валидации
                                        },
                                      ),
                                    ] else if (!isAuth) ...[
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Имя",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _nameController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        // Черный текст ввода
                                        decoration: InputDecoration(
                                          hintText: "Введите имя",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text("Фамилия",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _surnameController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        // Черный текст ввода
                                        decoration: InputDecoration(
                                          hintText: "Введите фамилию",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Отчество",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _lastnameController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        // Черный текст ввода
                                        decoration: InputDecoration(
                                          hintText: "Введите отчество",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Дата рождения",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  iconSize: 0,
                                                  items:
                                                      days.map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text("  $value",
                                                          textAlign:
                                                              TextAlign.center),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? val) {
                                                    setState(() {
                                                      selectedDay = val!;
                                                    });
                                                  },
                                                  value: selectedDay,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Container(
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  iconSize: 0,
                                                  items: months
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text("  $value",
                                                          textAlign:
                                                              TextAlign.center),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? val) {
                                                    setState(() {
                                                      selectedMonth = val!;
                                                    });
                                                  },
                                                  value: selectedMonth,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Container(
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  iconSize: 0,
                                                  items:
                                                      years.map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(" $value",
                                                          textAlign:
                                                              TextAlign.center),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? val) {
                                                    setState(() {
                                                      selectedYear = val!;
                                                    });
                                                  },
                                                  value: selectedYear,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Пол",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 8),
                                      SquareCheckbox("Мужской",
                                          state: male == true, (state) {
                                        setState(() {
                                          male = true;
                                        });
                                      }),
                                      SquareCheckbox("Женский",
                                          state: male == false, (state) {
                                        setState(() {
                                          male = false;
                                        });
                                      }),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Номер телефона",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _phoneController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        // Черный текст ввода
                                        keyboardType: TextInputType.phone,
                                        maxLength: 12,
                                        decoration: InputDecoration(
                                          hintText: "+7(999) 999-99-99",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Telegram",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextField(
                                        controller: _tgController,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        // Черный текст ввода
                                        decoration: InputDecoration(
                                          hintText: "@example",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if(!isPassRestore)...[const SizedBox(height: 16),
                                    const Text(
                                      "Email",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _loginController,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      onChanged: (text) {
                                        if (text.contains(" ")) {
                                          _loginController.text =
                                              text.replaceAll(" ", "");
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: "E-mail",
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
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
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Пароль",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      obscuringCharacter: '_',
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        hintText: "Пароль",
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
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
                                    if (!isAuth&&!isPassRestore) ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Повторите пароль",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: _repPassController,
                                        obscureText: true,
                                        obscuringCharacter: '_',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        decoration: InputDecoration(
                                          hintText: "Пароль",
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: const BorderSide(
                                              width: 0,
                                              style: BorderStyle.none,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Введите пароль повтроно';
                                          }

                                          return null; // Возвращаем null в случае успешной валидации
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 10.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                              color: isChecked
                                                  ? Colors.blue
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.blue,
                                                  width: 2.0),
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
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Text("Запомнить меня")
                                      ],
                                    ),],
                                    const SizedBox(height: 10.0),
                                    SizedBox(
                                        width: double.infinity,
                                        child: ColorRoundedButton(
                                            //-!-!-!temp data's!-!-!-!
                                            isPassRestore?"Изменить":isAuth
                                                ? 'Войти'
                                                : 'Зарегистрироваться',
                                            () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if(isPassRestore){
                                              /*TODO*/
                                            }
                                            else if (isAuth) {
                                              String login =
                                                  _loginController.text;
                                              String password =
                                                  _passwordController.text;
                                              try {
                                                vm?.authData = AuthData(
                                                    login: login,
                                                    password: password);
                                                setState(() {
                                                  isInLoading = true;
                                                });
                                                final authresult = await vm?.signIn(
                                                    login, password);
                                                if(authresult!=null) {
                                                  setState(() {
                                                    isInLoading=false;
                                                  });
                                                  return;
                                                }
                                                BlocProvider.of<NavigationBloc>(
                                                        context)
                                                    .removeLastFromBS();
                                                BlocProvider.of<NavigationBloc>(
                                                        context)
                                                    .add(
                                                        NavigateToCardsScreenEvent());
                                              } catch (ex) {
                                                setState(() {
                                                  isInLoading = false;
                                                });
                                              }
                                            } else {
                                              String name =
                                                  _nameController.text;
                                              String surname =
                                                  _surnameController.text;
                                              String lastname =
                                                  _lastnameController.text;
                                              String phone =
                                                  _phoneController.text;
                                              String tg = _tgController.text;
                                              String login =
                                                  _loginController.text;
                                              String password =
                                                  _passwordController.text;
                                              String repPass =
                                                  _repPassController.text;
                                              if (password == repPass) {
                                                await vm?.register(
                                                    ProfileData(
                                                        name: name,
                                                        surname: surname,
                                                        birtday: birthday ??
                                                            DateTime.now(),
                                                        male: male ?? true,
                                                        email: login,
                                                        thirdname: lastname,
                                                        phone: phone,
                                                        tg: tg),
                                                    AuthData(
                                                        login: login,
                                                        password: password));
                                                BlocProvider.of<NavigationBloc>(
                                                        context)
                                                    .removeLastFromBS();
                                                BlocProvider.of<NavigationBloc>(
                                                        context)
                                                    .add(
                                                        NavigateToCardsScreenEvent());
                                              } else {
                                                _showError(
                                                    "Пароли не совпадают");
                                              }
                                            }
                                          }
                                        })),
                                    if (isInLoading)
                                      const LinearProgressIndicator(),
                                    SizedBox(height: isInLoading ? 7.0 : 10.0),
                                    SizedBox(
                                        width: double.infinity,
                                        child: ColorRoundedButton(
                                            isAuth
                                                ? 'Регистрация'
                                                : 'Авторизация', () {
                                          setState(() {
                                            isAuth = !isAuth;
                                            isPassRestore=false;
                                          });
                                        })),
                                    const SizedBox(height: 10.0),
                                    InkWell(
                                      onTap: () async {
                                          final restorationEmail =
                                              await showModalBottomSheet<String>(
                                                    backgroundColor: AppColors
                                                        .backgroundColor,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ReqCodeWidget();
                                                    },
                                                  );
                                        if(restorationEmail!=null)vm?.sendRestorationEmail(restorationEmail);
                                      },
                                      child: const Center(
                                          child: Text('Восстановить пароль')),
                                    )
                                  ],
                                ),
                              ))),
                      const SizedBox(height: 10.0)
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
      } else if (!isPassChecked) {
        if (_messageController.text.isNotEmpty)
          messagesReg.add(_messageController.text);
        messagesReg.add("Пароли не совпадают, попробуйте еще раз");
      } else {
        _messageController.clear();
        messagesReg.add("Проверьте введенные данные и подтвердите");
      }
    } else {
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
        vm?.authData = AuthData(login: login, password: password);
        setState(() {
          isInLoading = true;
        });
        final result = await vm?.signIn(login, password);
        if (result == null) {
          BlocProvider.of<NavigationBloc>(context).removeLastFromBS();
          BlocProvider.of<NavigationBloc>(context)
              .add(NavigateToCardsScreenEvent());
        } else {
          login = "";
          password = "";
          messagesAuth
              .add("${result.replaceAll("Exception: ", "")}, введите email");
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
