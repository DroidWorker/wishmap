import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/interface_widgets/colorButton.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../navigation/navigation_block.dart';
import '../../res/colors.dart';

class ContactScreen extends StatelessWidget {
  TextEditingController phone = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    phone.addListener((){
      if(phone.text.isNotEmpty&&!phone.text.startsWith("+"))phone.text="+${phone.text}";
      if(phone.text.length>1&&!phone.text.contains(RegExp("^[0-9]\$"), phone.text.length-1))phone.text=phone.text.substring(0, phone.text.length-1);
    });
    return Scaffold(
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // the '2023' part
                          ),
                          icon: const Icon(Icons.keyboard_arrow_left,
                              size: 28, color: AppColors.gradientStart),
                          onPressed: () {
                            BlocProvider.of<NavigationBloc>(context).handleBackPress();
                          }),
                      const Text("Обращение",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(width: 30)
                    ],
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 96),
                            const Text(
                                "Связаться с нами:",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 15),
                            const Text(
                                "Выберите способ связи",
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 55),
                            Row(children: [
                              Expanded(
                                child: ColorRoundedButton("Gmail", (){
                                  final Uri params = Uri(
                                    scheme: 'mailto',
                                    path: 'abcd@gmail.com',
                                    query: 'subject=report',
                                  );
                                  final url = params.toString();
                                  final urlPath = Uri.parse(url);
                                  launchUrl(urlPath);
                                }),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ColorRoundedButton("Telegram", () async {
                                  const url = 'tg://resolve?domain=telegram';
                                  final uri = Uri.parse(url);
                                  if(await canLaunchUrl(uri)){
                                    launchUrl(uri);
                                  }
                                }),
                              )
                            ],)
                            /*const SizedBox(height: 15),
                            TextField(
                              maxLength: 12,
                              minLines: 1,
                              maxLines: 1,
                              controller: phone,
                              keyboardType: TextInputType.phone,
                              onTap: () async {
                        
                              },
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                border:  const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                counterText: "",
                                filled: true, // Заливка фона
                                fillColor: Colors.white,
                                hintText: 'Номер телефона', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              maxLength: 60,
                              minLines: 1,
                              maxLines: 1,
                              controller: name,
                              keyboardType: TextInputType.name,
                              onTap: () async {
                        
                              },
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                border:  const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                counterText: "",
                                filled: true, // Заливка фона
                                fillColor: Colors.white,
                                hintText: 'Имя', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              maxLength: 512,
                              minLines: 5,
                              maxLines: 20,
                              controller: comment,
                              onTap: () async {
                        
                              },
                              style: const TextStyle(color: Colors.black), // Черный текст ввода
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                border:  const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                counterText: "",
                                filled: true, // Заливка фона
                                fillColor: Colors.white,
                                hintText: 'Комментарий', // Базовый текст
                                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Полупрозрачный черный базовый текст
                              ),
                            ),
                            const SizedBox(height: 12),
                            ColorRoundedButton("Оставить заявку", () {
                              showModalBottomSheet<void>(
                                backgroundColor: AppColors.backgroundColor,
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext c) {
                                  return NotifyBS('Отправлено', "", 'OK', onOk: () {
                                    BlocProvider.of<NavigationBloc>(context)
                                        .handleBackPress();
                                    Navigator.pop(c, 'OK');
                                  });
                                },
                              );
                            }),
                            const SizedBox(height: 10),
                            Center(child: InkWell(
                              onTap: (){
                                showModalBottomSheet<void>(
                                  backgroundColor: AppColors.backgroundColor,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,"),
                                    );
                                  },
                                );
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(text: "оформляя заявку вы даете согласие на обработку", style: TextStyle(color: Colors.black54)),
                                      TextSpan(text: " персональных данных", style: TextStyle(color: AppColors.blueTextColor)),
                                    ],
                                  )
                              ),
                            ))*/
                          ],
                        ),
                      ))
                ],
              ),
            )));
  }
}
