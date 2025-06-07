import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';
import 'package:wishmap/interface_widgets/sq_checkbox.dart';

import '../../ViewModel.dart';
import '../../data/models.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class PersonalSettings extends StatefulWidget{

  @override
  PersonalSettingsState createState() => PersonalSettingsState();
}

class PersonalSettingsState extends State<PersonalSettings>{
  TextEditingController _name = TextEditingController();
  TextEditingController _sname = TextEditingController();
  TextEditingController _lname = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _tg = TextEditingController();

  List<String> days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> years = List.generate(90, (index) => (1950 + index).toString());

  String selectedDay = '1';
  String selectedMonth = '1';
  String selectedYear = '1990';

  bool? male;
  bool ppd = true;

  ProfileData? pd;

  @override
  void initState() {
    _name.addListener((){
      pd?.name=_name.text;
    });
    _sname.addListener((){
      pd?.surname=_sname.text;
    });
    _lname.addListener((){
      pd?.thirdname=_lname.text;
    });
    _phone.addListener((){
      if(_phone.text.isNotEmpty&&!_phone.text.startsWith("+"))_phone.text="+${_phone.text}";
      if(_phone.text.length>1&&!_phone.text.contains(RegExp("^[0-9]\$"), _phone.text.length-1))_phone.text=_phone.text.substring(0, _phone.text.length-1);
      pd?.phone=_phone.text;

    });
    _tg.addListener((){
      pd?.tg=_tg.text;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appViewModel = Provider.of<AppViewModel>(context);
    if(pd == null) {
      pd = appViewModel.profileData?.copy();
      _name.text = pd?.name??"ошибка";
      _sname.text = pd?.surname??"ошибка";
      _lname.text = pd?.thirdname??"ошибка";
      _phone.text = pd?.phone??"ошибка";
      _email.text = pd?.email??"ошибка";
      _tg.text = pd?.tg??"ошибка";
      if(pd!=null)selectedDay = pd!.birtday.day.toString().padLeft(2, "0");
      if(pd!=null)selectedMonth = pd!.birtday.month.toString().padLeft(2, "0");
      if(pd!=null)selectedYear = pd!.birtday.year.toString().padLeft(2, "0");
      male = pd!.male;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                      ),
                      icon: const Icon(Icons.keyboard_arrow_left, size: 28, color: AppColors.gradientStart),
                      onPressed: () {
                        appViewModel.mainCircles.clear();
                        if(appViewModel.mainScreenState!=null)appViewModel.startMainScreen(appViewModel.mainScreenState!.moon);
                        BlocProvider.of<NavigationBloc>(context).handleBackPress();
                      }
                  ),
                  const Text("Личные данные", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 10,),
              const Text("Имя", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _name,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите имя",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Фамилия", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _sname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите фамилию",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Отчество", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _lname,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "Введите отчество",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Дата рождения", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          iconSize: 0,
                          items: days.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("  $value", textAlign: TextAlign.center),
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
                  const SizedBox(width: 3,),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          iconSize: 0,
                          items: months.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text("  $value", textAlign: TextAlign.center),
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
                  const SizedBox(width: 3,),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: DropdownButtonHideUnderline(child: DropdownButton(
                        iconSize: 0,
                        items: years.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(" $value", textAlign: TextAlign.center),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          setState(() {
                            selectedYear = val!;
                          });
                        },
                        value: selectedYear,
                        borderRadius: BorderRadius.circular(8),
                      ),
                                        ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text("Пол", style: TextStyle(fontWeight:FontWeight.w600),),
              const SizedBox(height: 8),
              SquareCheckbox("Мужской", state: male==true, (state){
                setState(() {
                  male = true;
                  pd!.male = true;
                });
              }),
              SquareCheckbox("Женский", state: male==false, (state){
                setState(() {
                  male = false;
                  pd!.male = false;
                });
              }),
              const SizedBox(height: 16),
              const Text("Номер телефона", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _phone,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                keyboardType: TextInputType.phone,
                maxLength: 12,
                decoration: InputDecoration(
                  hintText: "+7(999) 999-99-99",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("E-Mail", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                enabled: false,
                decoration: InputDecoration(
                  hintText: "example@exmp.ru",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Telegram", style: TextStyle(fontWeight: FontWeight.w600),),
              const SizedBox(height: 4),
              TextField(
                controller: _tg,
                style: const TextStyle(color: Colors.black), // Черный текст ввода
                decoration: InputDecoration(
                  hintText: "@example",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:const EdgeInsets.fromLTRB(10,0,10,0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SquareCheckbox("Я согласен (-а) на обработку персональных данных", state: true, textStyle: const TextStyle(fontSize: 10, decoration: TextDecoration.underline),(state){
                setState(() {});
                showModalBottomSheet<void>(
                  backgroundColor: AppColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Согласие на обработку персональных данных", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18)),
                          Text('''Политика индивидуального предпринимателя Попова Александра Петровича в отношении обработки персональных данных
                            (утверждена «27» апреля 2025 г.)

                              1. Общие положения
                              1.1. Настоящая Политика Индивидуального предпринимателя Попова Александра Петровича (ОГРНИП 317502700029527) в отношении обработки персональных данных (далее — Политика, Оператор) разработана во исполнение требований п. 2 ч. 1 ст. 18.1 Федерального закона от 27.07.2006 № 152‑ФЗ «О персональных данных» (далее — Закон о ПД) и определяет порядок обработки и защиты персональных данных пользователей мобильного приложения «The Self» (далее — Приложение).
                    1.2. Политика действует в отношении всех персональных данных (ПДн), которые Оператор получает от физических лиц при использовании Приложения и связанных с ним сервисов.
                    1.3. Настоящая Политика публикуется в свободном доступе в сети Интернет в разделе «Политика конфиденциальности» Приложения и на сайте Оператора (если имеется).
                    1.4. Основные понятия, используемые в Политике, интерпретируются в соответствии с Законом о ПД.

                    2. Цели, состав и правовые основания обработки персональных данных
                    2.1. Оператор обрабатывает ПДн исключительно для:
                    • регистрации учетной записи пользователя и последующей авторизации через направляемую на e‑mail ссылку;
                    • предоставления доступа к функционалу Приложения;
                    • осуществления обратной связи и технической поддержки через указанный пользователем Telegram‑аккаунт или иные контактные данные;
                    • соблюдения требований российского законодательства.

                    2.2. При регистрации в Приложении пользователь может по своему усмотрению предоставить следующие данные:
                    E‑mail (обязательно) — создание учётной записи, направление письма со ссылкой для входа;
                    Пароль (обязательно) — безопасный доступ к аккаунту;
                    Ф. И. О. — необязательно, для персонализации обращения;
                    Возраст — необязательно, статистика, адаптация контента;
                    Номер телефона — необязательно, дополнительный способ связи;
                    Telegram‑аккаунт — необязательно, канал поддержки пользователей;
                    Гендер — необязательно, статистика.

                    2.3. Пользователь предоставляет ПДн путём заполнения соответствующих форм внутри Приложения.
                    2.4. Правовым основанием обработки является согласие субъекта ПДн, выражаемое путём проставления галочки «Я согласен с Политикой конфиденциальности и Пользовательским соглашением» при регистрации, а также заключение лицензионного Пользовательского соглашения.

                    3. Условия и способы обработки
                    3.1. Все ПДн хранятся и обрабатываются в облачной базе данных Google Firebase (проект расположен в регионе/eu‑central) с применением автоматизированных методов.
                    3.2. Передача ПДн третьим лицам не осуществляется, за исключением:
                    • случаев, прямо предусмотренных законодательством РФ;
                    • привлечения подрядчиков, обеспечивающих функционирование Приложения (Firebase, Google Cloud), при условии заключения с ними договора о конфиденциальности.
                    3.3. Срок хранения ПДн — до момента удаления учётной записи пользователем или отзыва согласия, либо по достижении целей обработки.
                    3.4. Оператор применяет необходимые организационные и технические меры для защиты ПДн, включая аутентификацию по защищённому токену Firebase, шифрование канала TLS 1.3 и разграничение доступа по ролям.

                    4. Права субъектов персональных данных
                    Пользователь вправе:
                    • получать сведения об обработке своих ПДн;
                    • требовать уточнения, блокирования или удаления недостоверных либо избыточных данных;
                    • отзывать согласие на обработку ПДн путём направления запроса на e‑mail Оператора app.theself@gmail.com;
                    • обжаловать действия Оператора в Роскомнадзоре или суде.

                    5. Заключительные положения
                    5.1. Оператор вправе изменять настоящую Политику. Новая редакция вступает в силу с момента публикации, если иное не предусмотрено.
                    5.2. Контактные сведения Оператора для обращений субъектов ПДн:
                    E‑mail: app.theself@gmail.com
                    ИП Попов А. П., ОГРНИП 317502700029527, ИНН 502603504326
                    ''')
                        ],
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
              ColorRoundedButton("сохранить", (){
                if(pd!=null){
                  if(ppd) {
                    appViewModel.saveProfile(pd!);
                    appViewModel.profileData = pd;
                    BlocProvider.of<NavigationBloc>(context).handleBackPress();
                  }else{
                    appViewModel.addError("для продолжения необходимо согласие на обработку персональных данных");
                  }
                }else{
                  appViewModel.addError("Ошибка! данные не распознаны");
                }
              })
            ],
          ),
        )
      ),
    );
  }
}