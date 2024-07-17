import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/home/aim_create.dart';
import 'package:wishmap/home/aimedit_screen.dart';
import 'package:wishmap/home/alarm_screen.dart';
import 'package:wishmap/home/alarm_setting_screen.dart';
import 'package:wishmap/home/cards_screen.dart';
import 'package:wishmap/home/diary_screen.dart';
import 'package:wishmap/home/diaryedit_screen.dart';
import 'package:wishmap/home/gaery_screen.dart';
import 'package:wishmap/home/mainsphereedit_screen.dart';
import 'package:wishmap/home/mytasks_screen.dart';
import 'package:wishmap/home/qrCheck_screen.dart';
import 'package:wishmap/home/settings/main_settings.dart';
import 'package:wishmap/home/settings/personal_settings.dart';
import 'package:wishmap/home/taskcreate_screen.dart';
import 'package:wishmap/home/wish_screen.dart';
import 'package:wishmap/services/reminder_service.dart';
import 'package:workmanager/workmanager.dart';
import 'ViewModel.dart';
import 'common/error_widget.dart';
import 'firebase_options.dart';
import 'home/my_simple_tasks_screen.dart';
import 'home/myaims_screen.dart';
import 'home/mywishes_screen.dart';
import 'home/profile_screen.dart';
import 'home/settings/sounds_setting.dart';
import 'home/taskedit_screen.dart';
import 'navigation/navigation_block.dart';
import 'home/main_screen.dart';
import 'home/auth_screen.dart';

import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Permission.scheduleExactAlarm.isDenied.then((value){
    if (value) {
      Permission.scheduleExactAlarm.request();
    }
  });
  // Инициализация плагина загрузки
  await FlutterDownloader.initialize(debug: true);
  final appViewModel = AppViewModel();
  await appViewModel.init();

  tz.initializeTimeZones();
  await AndroidAlarmManager.initialize();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload == "alarm") {
        runApp(MyApp(alarmScreen: true));
      }else if(response.payload?.contains("WishMap://task")==true){
        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final appViewModel = AppViewModel();
        await appViewModel.init();

        tz.initializeTimeZones();

        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) async {
            if (response.payload == "alarm") {
              runApp(MyApp(alarmScreen: true));
            }else if(response.payload?.contains("WishMap://task")==true){

            }
          },
        );

        runApp(
          ChangeNotifierProvider(
            create: (context) => appViewModel,
            child: BlocProvider<NavigationBloc>(
              create: (context) {
                final appViewModel = context.read<AppViewModel>();
                appViewModel.getTask(int.parse(response.payload!.split("id=")[1]));
                return NavigationBloc()..add((appViewModel.profileData!=null&&appViewModel.profileData!.id.isNotEmpty)?NavigateToTasksScreenEvent():NavigateToAuthScreenEvent());
              },
              child: MyApp(),
            ),
          ),
        );
      }
    },
  );
  _requestPermissions(flutterLocalNotificationsPlugin);
  tz.initializeTimeZones();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appViewModel,
      child: BlocProvider<NavigationBloc>(
          create: (context) {
            final appViewModel = context.read<AppViewModel>();
            return NavigationBloc()..add((appViewModel.profileData!=null&&appViewModel.profileData!.id.isNotEmpty)?NavigateToCardsScreenEvent():NavigateToAuthScreenEvent());
          },
        child: MyApp(),
      ),
    ),
  );
}

Future<void> _requestPermissions(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  try {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  } catch (e) {
    print('Error while requesting permissions: $e');
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


class MyApp extends StatefulWidget {
  bool alarmScreen;
  MyApp({this.alarmScreen = false});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context) {

          return MaterialApp(
            theme: ThemeData(
              fontFamily: 'Gilroy',
              bottomSheetTheme:  BottomSheetThemeData(
                backgroundColor: Colors.black.withOpacity(0)
              )
            ),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: const [
                Locale('ru', ''),
              ],
              onGenerateRoute: (settings) {
                if (settings.name == '/task') {
                  // Extract id parameter from URL
                  final String id = settings.arguments.toString().split('?id=')[1];
                  return MaterialPageRoute(
                    builder: (context) => TaskEditScreen(aimId: int.parse(id)),
                  );
                }
                return null;
              },
            title: 'wishMap',
              builder: (BuildContext context, Widget? widget) {
                ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                  print("fatal error: ${errorDetails.exception} /n ${errorDetails.stack}");
                  return CustomError(errorDetails: errorDetails);
                };
                return widget!;
              },
            home: widget.alarmScreen ? NotifyAlarmScreen(((){
              SystemNavigator.pop();
            })) : BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state)
          {
            return Consumer<AppViewModel>(
              builder: (context, appViewModel, child) {
                if (appViewModel.messageError.text.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showError(context, appViewModel.messageError.text);
                    appViewModel.messageError.text = '';
                  });
                }
                return WillPopScope(
                  onWillPop: () async {
                    final shouldPop = await context.read<NavigationBloc>()
                        .handleBackPress();
                    return shouldPop;
                  },
                  child: _buildScreenForState(state),
                );
              },
            );
          })
          );
  }

  Widget _buildScreenForState(NavigationState state) {
    if (state is NavigationMainScreenState) {
      return MainScreen();
    } else if (state is NavigationAuthScreenState) {
      return AuthScreen();
    } else if (state is NavigationCardsScreenState) {
      return CardsScreen();
    } else if (state is NavigationWishScreenState) {
      return WishScreen();
    } else if (state is NavigationAimCreateScreenState) {
      return AimScreen(parentCircleId: state.parentCircleId);
    } else if (state is NavigationAimEditScreenState) {
      return AimEditScreen(aimId: state.aimId);
    } else if (state is NavigationTasksScreenState) {
      return const TasksScreen();
    }else if (state is NavigationSimpleTasksScreenState) {
      return const SimpleTasksScreen();
    } else if (state is NavigationWishesScreenState) {
      return WishesScreen();
    } else if (state is NavigationAimsScreenState) {
      return const AimsScreen();
    } else if (state is NavigationProfileScreenState) {
      return const ProfileScreen();
    } else if (state is NavigationTaskCreateScreenState) {
      return TaskScreen(parentAimId: state.parentAimId, isSimpleTask: state.isSimple, simpleParentType: state.type);
    } else if (state is NavigationTaskEditScreenState) {
      return TaskEditScreen(aimId: state.aimId);
    } else if (state is NavigationMainSphereEditScreenState) {
      return const MainSphereEditScreen();
    }  else if (state is NavigationDiaryScreenState) {
      return DiaryScreen();
    } else if (state is NavigationDiaryEditScreenState) {
      return DiaryEditScreen(diaryId: state.id);
    } else if (state is NavigationGalleryScreenState) {
      return const GalleryScreen();
    } else if (state is NavigationQRScreenState) {
      return QRCheckScreen();
    } else if (state is NavigationMainSettingsScreenState) {
      return MainSettings();
    } else if (state is NavigationPersonalSettingsScreenState) {
      return PersonalSettings();
    }else if (state is NavigationSoundsSettingsScreenState) {
      return SoundsSettings();
    }else if (state is NavigationAlarmSettingsScreenState) {
      return AlarmSettingScreen(state.id);
    } else if (state is NavigationAlarmScreenState) {
      return AlarmScreen();
    } else {
      return Container(); // По умолчанию или для других состояний.
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class NotifyAlarmScreen extends StatelessWidget {
  final Function() onClose;
  const NotifyAlarmScreen(this.onClose, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Логика для отключения будильника
            onClose();
          },
          child: const Text('Turn off Alarm'),
        ),
      ),
    );
  }
}
