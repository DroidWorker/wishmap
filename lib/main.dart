import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishmap/common/initial_onboarding.dart';
import 'package:wishmap/common/passed_onboarding.dart';
import 'package:wishmap/home/aim_create.dart';
import 'package:wishmap/home/aimedit_screen.dart';
import 'package:wishmap/home/alarm_screen.dart';
import 'package:wishmap/home/alarm_setting_screen.dart';
import 'package:wishmap/home/cards_screen.dart';
import 'package:wishmap/home/diary_screen.dart';
import 'package:wishmap/home/diaryedit_screen.dart';
import 'package:wishmap/home/gaery_screen.dart';
import 'package:wishmap/home/lockscreen.dart';
import 'package:wishmap/home/mainsphereedit_screen.dart';
import 'package:wishmap/home/my_knwlgs.dart';
import 'package:wishmap/home/my_testing.dart';
import 'package:wishmap/home/mytasks_screen.dart';
import 'package:wishmap/home/settings/main_settings.dart';
import 'package:wishmap/home/settings/personal_settings.dart';
import 'package:wishmap/home/settings/promocodes_screen.dart';
import 'package:wishmap/home/settings/proposal_scren.dart';
import 'package:wishmap/home/settings/q_screen.dart';
import 'package:wishmap/home/taskcreate_screen.dart';
import 'package:wishmap/home/todo_screen.dart';
import 'package:wishmap/home/wish_screen.dart';
import 'package:wishmap/provider/audio_manager.dart';
import 'package:wishmap/res/colors.dart';
import 'package:wishmap/services/reminder_service.dart';
import 'package:wishmap/testModule/adminPanel/CalculationResultScreen.dart';
import 'package:wishmap/testModule/testingEngine/ViewModel.dart';
import 'package:wishmap/testModule/testingEngine/pages/kin_screen.dart';
import 'package:wishmap/testModule/testingEngine/pages/main_page.dart';
import 'package:wishmap/testModule/testingEngine/pages/module.dart';
import 'package:wishmap/testModule/testingEngine/pages/report1.dart';
import 'package:wishmap/testModule/testingEngine/pages/reportInfoScreen.dart';
import 'ViewModel.dart';
import 'common/error_widget.dart';
import 'dialog/bottom_sheet_notify.dart';
import 'firebase_options.dart';
import 'home/my_simple_tasks_screen.dart';
import 'home/myaims_screen.dart';
import 'home/mywishes_screen.dart';
import 'home/notify_alarm_screen.dart';
import 'home/profile_screen.dart';
import 'home/settings/contact_screen.dart';
import 'home/settings/lock_settings_screen.dart';
import 'home/settings/sounds_setting.dart';
import 'home/taskedit_screen.dart';
import 'navigation/navigation_block.dart';
import 'home/main_screen.dart';
import 'home/auth_screen.dart';

import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late BuildContext mainContext;
late NavigationBloc globalNavigationBloc;

void main() async {
  globalNavigationBloc = NavigationBloc();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _requestPermissions(flutterLocalNotificationsPlugin);
  await FlutterDownloader.initialize(debug: false);
  await AndroidAlarmManager.initialize();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  final appViewModel = AppViewModel();
  await appViewModel.init();
  final tvm = TestViewModel();
  await tvm.init();

  NotificationResponse? initialNotificationResponse;

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) =>
        _handleNotificationResponse(response, appViewModel, tvm),
  );

  // Проверка, было ли приложение запущено через уведомление
  initialNotificationResponse =
      (await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails())
          ?.notificationResponse;

  int? alarmId;
  int? taskId;

  if (initialNotificationResponse?.payload?.contains("alarm") == true) {
    final id = int.parse(initialNotificationResponse!.payload!.split("|")[1]);
    alarmId = id ~/ 100;
    appViewModel.getLastObjectsForAlarm();
  } else if (initialNotificationResponse?.payload?.contains("WishMap://task") ==
      true) {
    taskId = int.parse(initialNotificationResponse!.payload!.split("id=")[1]);
    appViewModel.currentTask = null;
    appViewModel.startAppFromTask(taskId);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppViewModel>(
          create: (context) => appViewModel,
        ),
        ChangeNotifierProvider<TestViewModel>(
          create: (context) => tvm,
        ),
        BlocProvider<NavigationBloc>(create: (context) {
          mainContext = context;
          final appViewModel = context.read<AppViewModel>();
          return (appViewModel.profileData != null &&
                  appViewModel.profileData!.id.isNotEmpty)
              ? (appViewModel.testPassed
                  ? (globalNavigationBloc..add(NavigateToCardsScreenEvent()))
                  : (globalNavigationBloc
                    ..add(NavigateToCardsScreenEvent())
                    ..add(NavigateToMyKnwlgsScreenEvent())
                    ..add(NavigateToPassedOnboardingScreenEvent())
                    ..add(NavigateToMyTestingScreenEvent())
                    ..add(NavigateToInitialOnboardingScreenEvent())))
              : (globalNavigationBloc..add(NavigateToAuthScreenEvent()));
        }),
      ],
      child: MyApp(taskId: taskId, alarmId: alarmId),
    ),
  );
}

Future<void> _requestPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  try {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  } catch (e) {
    print('Error while requesting permissions: $e');
  }
}

/*
* Future<void> _handleNotificationResponse( NotificationResponse response, AppViewModel vm, TestViewModel tvm) async { AudioPlayerManager().stop(); if (response.payload?.contains("alarm") == true) { final id = int.parse(response.payload!.split("|")[1]); _runAppWithAlarm(id ~/ 100, vm, tvm); } else if (response.payload?.contains("WishMap://task") == true) { _runAppWithTask(response, vm, tvm); } }*/
Future<void> _handleNotificationResponse(NotificationResponse response,
    AppViewModel appViewModel, TestViewModel tvm) async {
  print("bbbggggg - $mainContext");
  if (response.payload?.contains("alarm") == true) {
    final id = int.parse(response.payload!.split("|")[1]);
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => NotifyAlarmScreen(() {}, id ~/ 100)),
      (route) => false,
    );
    } else if (response.payload?.contains("WishMap://task") == true) {
      print("bbbggggg2222");
      final taskId = int.parse(response.payload!.split("id=")[1]);
      if(navigatorKey.currentState!=null) {
        final navContext = navigatorKey.currentState!.context;
        BlocProvider.of<NavigationBloc>(navContext)
            .add(NavigateToTaskEditScreenEvent(taskId));
      }else {
        globalNavigationBloc
            .add(NavigateToTaskEditScreenEvent(taskId));
      }
    /*navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TaskEditScreen(aimId: taskId)),
          (route) => false,
    );*/
  }
}

void _runAppWithAlarm(int alarmId, AppViewModel vm, TestViewModel tvm) async {
  vm.getLastObjectsForAlarm();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<AppViewModel>(
        create: (context) => vm,
      ),
      ChangeNotifierProvider<TestViewModel>(
        create: (context) => tvm,
      ),
      BlocProvider<NavigationBloc>(
        create: (context) {
          return NavigationBloc();
        },
        child: MyApp(alarmId: alarmId),
      ),
    ]),
  );
}

void _runAppWithTask(
    NotificationResponse response, AppViewModel vm, TestViewModel tvm) async {
  final taskId = int.parse(response.payload!.split("id=")[1]);
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<AppViewModel>(
        create: (context) => vm,
      ),
      ChangeNotifierProvider<TestViewModel>(
        create: (context) => tvm,
      ),
      BlocProvider<NavigationBloc>(
        create: (context) {

          final appViewModel = context.read<AppViewModel>();
          appViewModel.currentTask = null;
          appViewModel.startAppFromTask(taskId);
          return NavigationBloc()
            ..add((appViewModel.profileData != null &&
                    appViewModel.profileData!.id.isNotEmpty)
                ? NavigateToTaskEditScreenEvent(taskId)
                : NavigateToAuthScreenEvent());
        },
        child: MyApp(taskId: taskId),
      ),
    ]),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  int? alarmId;
  int? taskId;

  MyApp({super.key, this.alarmId, this.taskId});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppViewModel? vm;
  Timer? _timer;
  bool isMessageShown = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (vm?.allowSkipAuth == true) {
        vm?.allowSkipAuth = false;
      } else {
        vm?.lockState = true;
      }
    }
    if (state == AppLifecycleState.hidden) {
      if (vm?.autoLogout == true) {
        BlocProvider.of<NavigationBloc>(context).clearHistory();
        BlocProvider.of<NavigationBloc>(context)
            .add(NavigateToAuthScreenEvent());
        vm?.signOut();
      }
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            fontFamily: 'Gilroy',
            bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Colors.black.withOpacity(0))),
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
            print(
                "fatal error: ${errorDetails.exception} /n ${errorDetails.stack}");
            return CustomError(errorDetails: errorDetails);
          };
          return widget!;
        },
        home: widget.alarmId != null
            ? NotifyAlarmScreen((() {
                setState(() {
                  widget.alarmId = null;
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigateToCardsScreenEvent());
                });
                //SystemNavigator.pop();
              }), widget.alarmId!)
            : widget.taskId != null
                ? TaskEditScreen(
                    aimId: widget.taskId!,
                    onClose: () {
                      setState(() {
                        vm?.currentTask = null;
                        vm?.startAppFromTask(widget.taskId!);
                        widget.taskId = null;
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigateToTaskEditScreenEvent(-1));
                      });
                    },
                  )
                : BlocBuilder<NavigationBloc, NavigationState>(
                    builder: (context, state) {
                    _startPeriodicMessage(context);
                    return Consumer<AppViewModel>(
                      builder: (context, appViewModel, child) {
                        vm ??= appViewModel;
                        final me = appViewModel.messageError;
                        if (me.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showError(context, me, important: vm!.important);
                          });
                        }
                        return WillPopScope(
                          onWillPop: () async {
                            final shouldPop = await context
                                .read<NavigationBloc>()
                                .handleBackPress();
                            return shouldPop;
                          },
                          child:
                              appViewModel.lockEnabled && appViewModel.lockState
                                  ? LockScreen()
                                  : _buildScreenForState(state),
                        );
                      },
                    );
                  }));
  }

  _startPeriodicMessage(BuildContext c) async {
    vm?.promocodeMessageActive = await vm?.hasActivePromocode(null) ?? false;
    _timer = Timer.periodic(const Duration(minutes: 30), (t) {
      if (vm?.promocodeMessageActive == true) {
        return;
      }
      if (!isMessageShown &&
          BlocProvider.of<NavigationBloc>(context).state
              is! NavigationAuthScreenState) {
        showModalBottomSheet<void>(
          backgroundColor: AppColors.backgroundColor,
          context: c,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return NotifyBS("", "Подпишись на тг канал", 'OK', onOk: () async {
              final url = 'tg://resolve?domain=${vm?.static["tg"]}';
              final uri = Uri.parse(url);
              Navigator.pop(context, 'OK');
              if (await canLaunchUrl(uri)) {
                launchUrl(uri);
              }
              isMessageShown = false;
            });
          },
        ).then((val) {
          isMessageShown = false;
        });
        isMessageShown = true;
      }
    });
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
    } else if (state is NavigationSimpleTasksScreenState) {
      return const SimpleTasksScreen();
    } else if (state is NavigationWishesScreenState) {
      return WishesScreen();
    } else if (state is NavigationAimsScreenState) {
      return const AimsScreen();
    } else if (state is NavigationProfileScreenState) {
      return const ProfileScreen();
    } else if (state is NavigationTaskCreateScreenState) {
      return TaskScreen(
          parentAimId: state.parentAimId,
          isSimpleTask: state.isSimple,
          simpleParentType: state.type);
    } else if (state is NavigationTaskEditScreenState) {
      return TaskEditScreen(aimId: state.aimId);
    } else if (state is NavigationMainSphereEditScreenState) {
      return const MainSphereEditScreen();
    } else if (state is NavigationDiaryScreenState) {
      return DiaryScreen();
    } else if (state is NavigationDiaryEditScreenState) {
      return DiaryEditScreen(diaryId: state.id);
    } else if (state is NavigationGalleryScreenState) {
      return const GalleryScreen();
    } else if (state is NavigationMainSettingsScreenState) {
      return MainSettings();
    } else if (state is NavigationPersonalSettingsScreenState) {
      return PersonalSettings();
    } else if (state is NavigationSoundsSettingsScreenState) {
      return SoundsSettings();
    } else if (state is NavigationQuestionsSettingsScreenState) {
      return QScreen();
    } else if (state is NavigationProposalScreenState) {
      return ProposalScreen();
    } else if (state is NavigationContactScreenState) {
      return ContactScreen();
    } else if (state is NavigationAlarmSettingsScreenState) {
      return AlarmSettingScreen(state.id);
    } else if (state is NavigationLockSettingsScreenState) {
      return LockSettingsScreen();
    } else if (state is NavigationTodoScreenState) {
      return TodoScreen();
    } else if (state is NavigationPromocodesScreenState) {
      return const PromocodesScreen();
    } else if (state is NavigationInitialOnboardingScreenState) {
      return InitialOnboardingScreen();
    } else if (state is NavigationPassedOnboardingScreenState) {
      return PassedOnboardingScreen();
    } else if (state is NavigationAlarmScreenState) {
      return AlarmScreen();
    } else if (state is NavigationTestScreenState) {
      return const MainPage();
    } else if (state is NavigationAdminPanelScreenState) {
      return CalculationStepsScreen();
    } else if (state is NavigationKinScreenState) {
      return KinScreen();
    } else if (state is NavigationModuleScreenState) {
      return const Module1();
    } else if (state is NavigationReport1ScreenState) {
      return Report1();
    } else if (state is NavigationReportInfoScreenScreenState) {
      return ReportInfoScreen(
        state.sphere,
        state.index,
        key: UniqueKey(),
      );
    } else if (state is NavigationMyTestingScreenState) {
      return MyTestingScreen();
    } else if (state is NavigationMyKnwlgsScreenState) {
      return MyKnwlgsScreen();
    } else {
      return Container(); // По умолчанию или для других состояний.
    }
  }

  void _showError(BuildContext context, String message,
      {bool important = false}) {
    important
        ? showModalBottomSheet<void>(
            backgroundColor: AppColors.backgroundColor,
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return NotifyBS("Внимание", message, 'OK',
                  onOk: () => Navigator.pop(context, 'OK'));
            },
          )
        : ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              content:
                  Text(message, style: const TextStyle(color: Colors.black)),
              duration: const Duration(seconds: 3),
            ),
          );
  }
}
