import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/home/aim_create.dart';
import 'package:wishmap/home/aimedit_screen.dart';
import 'package:wishmap/home/cards_screen.dart';
import 'package:wishmap/home/mainsphereedit_screen.dart';
import 'package:wishmap/home/mytasks_screen.dart';
import 'package:wishmap/home/taskcreate_screen.dart';
import 'package:wishmap/home/wish_screen.dart';
import 'package:wishmap/provider/provider.dart';
import 'ViewModel.dart';
import 'firebase_options.dart';
import 'home/myaims_screen.dart';
import 'home/mywishesScreen.dart';
import 'home/profile_screen.dart';
import 'home/spheresoflife_screen.dart';
import 'home/taskedit_screen.dart';
import 'navigation/navigation_block.dart';
import 'home/main_screen.dart';
import 'home/auth_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appViewModel = AppViewModel();
  await appViewModel.init();
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
          return MaterialApp(
            title: 'wishMap',
            home: BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state)
          {
            return Consumer<AppViewModel>(
              builder: (context, appViewModel, child) {
                if (appViewModel.messageError.text.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showError(context, appViewModel.messageError.text);
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
    } else if (state is NavigationSpheresOfLifeScreenState) {
      return const SpheresOfLifeScreen();
    } else if (state is NavigationWishScreenState) {
      return WishScreen();
    } else if (state is NavigationAimCreateScreenState) {
      return AimScreen(parentCircleId: state.parentCircleId);
    } else if (state is NavigationAimEditScreenState) {
      return AimEditScreen(aimId: state.aimId);
    } else if (state is NavigationTasksScreenState) {
      return const TasksScreen();
    } else if (state is NavigationWishesScreenState) {
      return WishesScreen();
    } else if (state is NavigationAimsScreenState) {
      return const AimsScreen();
    } else if (state is NavigationProfileScreenState) {
      return const ProfileScreen();
    } else if (state is NavigationTaskCreateScreenState) {
      return TaskScreen(parentAimId: state.parentAimId);
    } else if (state is NavigationTaskEditScreenState) {
      return TaskEditScreen(aimId: state.aimId);
    } else if (state is NavigationMainSphereEditScreenState) {
      return const MainSphereEditScreen();
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