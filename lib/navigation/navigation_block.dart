import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishmap/data/models.dart';

abstract class NavigationEvent {}

class NavigateBackEvent extends NavigationEvent {}

class NavigateToAuthScreenEvent extends NavigationEvent {}

class NavigateToMainScreenEvent extends NavigationEvent {}

class NavigateToCardsScreenEvent extends NavigationEvent {}

class NavigateToSpheresOfLifeScreenEvent extends NavigationEvent {}

class NavigateToWishScreenEvent extends NavigationEvent {}

class NavigateToAimCreateScreenEvent extends NavigationEvent {
  int circleId = 0;
  NavigateToAimCreateScreenEvent(this.circleId);
}

class NavigateToAimEditScreenEvent extends NavigationEvent {
  int aimId = 0;
  NavigateToAimEditScreenEvent(this.aimId);
}

class NavigateToTasksScreenEvent extends NavigationEvent {}

class NavigateToWishesScreenEvent extends NavigationEvent {}

class NavigateToAimsScreenEvent extends NavigationEvent {}

class NavigateToProfileScreenEvent extends NavigationEvent {}

class NavigateToTaskCreateScreenEvent extends NavigationEvent {}

class NavigateToTaskEditScreenEvent extends NavigationEvent {}

class NavigateToMainSphereEditScreenEvent extends NavigationEvent {}

abstract class NavigationState {}

class NavigationAuthScreenState extends NavigationState {}

class NavigationMainScreenState extends NavigationState {}

class NavigationCardsScreenState extends NavigationState {}

class NavigationSpheresOfLifeScreenState extends NavigationState {}

class NavigationWishScreenState extends NavigationState {}

class NavigationAimCreateScreenState extends NavigationState {
  int parentCircleId=0;
  NavigationAimCreateScreenState({required this.parentCircleId});
}

class NavigationAimEditScreenState extends NavigationState {
  int aimId=0;
  NavigationAimEditScreenState(this.aimId);
}

class NavigationTasksScreenState extends NavigationState {}

class NavigationWishesScreenState extends NavigationState {}

class NavigationAimsScreenState extends NavigationState {}

class NavigationProfileScreenState extends NavigationState {}

class NavigationTaskCreateScreenState extends NavigationState {}

class NavigationTaskEditScreenState extends NavigationState {}

class NavigationMainSphereEditScreenState extends NavigationState {}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationCardsScreenState());

  final List<NavigationState> _navigationHistory = [NavigationCardsScreenState()];

  final _backPressController = StreamController<bool>();

  Stream<bool> get backPressStream => _backPressController.stream;

  Future<bool> handleBackPress() async {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      _backPressController.add(false); // Отправить событие "назад" в поток
      add(NavigateBackEvent()); // Добавить событие для навигации назад
      return false; // Не закрывать приложение
    } else {
      _backPressController.add(true); // Разрешить закрытие приложения
      return true; // Закрыть приложение
    }
  }

  void removeLastFromBS() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
    }
  }

  @override
  Future<void> close() {
    _backPressController.close();
    return super.close();
  }

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigateToAuthScreenEvent) {
      _navigationHistory.add(NavigationAuthScreenState());
    } else if (event is NavigateToMainScreenEvent) {
      _navigationHistory.add(NavigationMainScreenState());
    } else if (event is NavigateToCardsScreenEvent) {
      _navigationHistory.add(NavigationCardsScreenState());
    } else if (event is NavigateToSpheresOfLifeScreenEvent) {
      _navigationHistory.add(NavigationSpheresOfLifeScreenState());
    } else if (event is NavigateToWishScreenEvent) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationWishScreenState());
    } else if (event is NavigateToAimCreateScreenEvent) {
      _navigationHistory.add(NavigationAimCreateScreenState(parentCircleId: event.circleId));
    } else if (event is NavigateToAimEditScreenEvent) {
      _navigationHistory.add(NavigationAimEditScreenState(event.aimId));
    } else if (event is NavigateToTasksScreenEvent) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationTasksScreenState());
    } else if (event is NavigateToWishesScreenEvent) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationWishesScreenState());
    } else if (event is NavigateToAimsScreenEvent) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationAimsScreenState());
    } else if (event is NavigateToProfileScreenEvent) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationProfileScreenState());
    } else if (event is NavigateToTaskCreateScreenEvent) {
      _navigationHistory.add(NavigationTaskCreateScreenState());
    } else if (event is NavigateToTaskEditScreenEvent) {
      _navigationHistory.add(NavigationTaskEditScreenState());
    } else if (event is NavigateToMainSphereEditScreenEvent) {
      _navigationHistory.add(NavigationMainSphereEditScreenState());
    } else if(event is NavigateBackEvent) {
      yield _navigationHistory.last;
    }

    yield _navigationHistory.last;
  }
}