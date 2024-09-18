import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:local_auth/local_auth.dart';
import 'package:wishmap/data/models.dart';

import '../ViewModel.dart';
import '../common/numbutton_simplewidget.dart';
import '../res/colors.dart';

class LockScreen extends StatefulWidget {
  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen> {
  late AppViewModel vm;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.addListener(() {
      if (controller.text.length == 4) {
        if (lp?.password == controller.text) {
          vm.lockState = false;
        } else {
          controller.text = '';
        }
      }
    });
    super.initState();
  }

  LockParams? lp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<AppViewModel>(builder: (context, appVM, child) {
        vm = appVM;
        lp = vm.lockParams;
        return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/keyimg.png'),
                          const Text("Пин-код", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
                          const Text("Для входа в приложение необходимо ввести пин-код", textAlign: TextAlign.center,),
                          TextField(
                            controller: controller,
                            style: const TextStyle( fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            obscuringCharacter: "•",
                            enabled: false,
                            showCursor: false,
                            decoration: InputDecoration(
              hintText: "Введите пароль",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  width: 1,
                  color: AppColors.etGrey
                ),
              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("1"),
                    onTap: () {
                      controller.text += "1";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("2"),
                    onTap: () {
                      controller.text += "2";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("3"),
                    onTap: () {
                      controller.text += "3";
                    }),
              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("4"),
                    onTap: () {
                      controller.text += "4";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("5"),
                    onTap: () {
                      controller.text += "5";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("6"),
                    onTap: () {
                      controller.text += "6";
                    }),
              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("7"),
                    onTap: () {
                      controller.text += "7";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("8"),
                    onTap: () {
                      controller.text += "8";
                    }),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("9"),
                    onTap: () {
                      controller.text += "9";
                    }),
              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      width: 50,
                      height: 50,
                      child: const Center(
                          child: Icon(Icons.backspace, color: Colors.white))),
                  onTap: () {
                    controller.text = controller.text
                        .substring(0, controller.text.length - 1);
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    child: getButton("0"),
                    onTap: () {
                      controller.text += "0";
                    }),
              ),
              (lp?.allowFingerprint == true)
                  ? Expanded(
                    child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            width: 50,
                            height: 50,
                            child: const Center(
                                child: Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                              size: 45,
                            ))),
                        onTap: () async {
                          final LocalAuthentication auth =
                              LocalAuthentication();
                          final bool canAuthenticateWithBiometrics =
                              await auth.canCheckBiometrics;
                          if (canAuthenticateWithBiometrics) {
                            final bool didAuthenticate = await auth.authenticate(
                                localizedReason:
                                    'Для разблокировки пройдите аутентификацию',
                                options: const AuthenticationOptions(
                                    biometricOnly: true));
                            if (didAuthenticate) {
                              vm.lockState = false;
                              vm.allowSkipAuth = true;
                            }
                          }
                        },
                      ),
                  )
                  : const Expanded(child: SizedBox()),
                            ],
                          ),
                          const SizedBox(height: 5),
                          InkWell(
              onTap: () {
                showModalBottomSheet<void>(
                  backgroundColor: AppColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            "для восстановления пароля переустановите приложение и авторизуйтесь", textAlign: TextAlign.center,));
                  },
                );
              },
              child: const Text("Сбросить пароль",
                  style: TextStyle(decoration: TextDecoration.underline))),
                          const SizedBox(height: 16)
                        ],
                      ),
            ));
      }),
    );
  }
}
