import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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

class NavigateToSimpleTasksScreenEvent extends NavigationEvent {}

class NavigateToWishesScreenEvent extends NavigationEvent {}

class NavigateToAimsScreenEvent extends NavigationEvent {}

class NavigateToProfileScreenEvent extends NavigationEvent {}

class NavigateToTaskCreateScreenEvent extends NavigationEvent {
  int parentAimId = 0;
  bool isSimple;
  String type;
  NavigateToTaskCreateScreenEvent(this.parentAimId, {this.isSimple = false, this.type = ''});
}

class NavigateToTaskEditScreenEvent extends NavigationEvent {
  int taskId = 0;
  NavigateToTaskEditScreenEvent(this.taskId);
}

class NavigateToMainSphereEditScreenEvent extends NavigationEvent {}

class NavigateToDiaryScreenEvent extends NavigationEvent {}

class NavigateToDiaryEditScreenEvent extends NavigationEvent {
  int id = 0;
  NavigateToDiaryEditScreenEvent(this.id);
}

class NavigateToGalleryScreenEvent extends NavigationEvent {}

class NavigateToAlarmScreenEvent extends NavigationEvent {}
class NavigateToAlarmSettingsScreenEvent extends NavigationEvent {
  int id = 0;
  NavigateToAlarmSettingsScreenEvent(this.id);
}

class NavigateToQRScreenEvent extends NavigationEvent {}

class NavigateToPersonalSettingsScreenEvent extends NavigationEvent {}
class NavigateToMainSettingsScreenEvent extends NavigationEvent {}
class NavigateToSoundsSettingsScreenEvent extends NavigationEvent {}
class NavigateToQuestionsScreenEvent extends NavigationEvent {}
class NavigateToProposalScreenEvent extends NavigationEvent {}
class NavigateToContactScreenEvent extends NavigationEvent {}
class NavigateToLockSettingsScreenEvent extends NavigationEvent {}

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

class NavigationSimpleTasksScreenState extends NavigationState {}

class NavigationWishesScreenState extends NavigationState {}

class NavigationAimsScreenState extends NavigationState {}

class NavigationProfileScreenState extends NavigationState {}

class NavigationTaskCreateScreenState extends NavigationState {
  int parentAimId=0;
  bool isSimple;
  String type;
  NavigationTaskCreateScreenState(this.parentAimId, {this.isSimple= false, this.type = ''});
}

class NavigationTaskEditScreenState extends NavigationState {
  int aimId = 0;
  NavigationTaskEditScreenState(this.aimId);
}

class NavigationMainSphereEditScreenState extends NavigationState {}

class NavigationDiaryScreenState extends NavigationState {}

class NavigationDiaryEditScreenState extends NavigationState {
  int id = 0;
  NavigationDiaryEditScreenState(this.id);
}

class NavigationGalleryScreenState extends NavigationState {}

class NavigationAlarmScreenState extends NavigationState {}
class NavigationAlarmSettingsScreenState extends NavigationState {
  int id = 0;
  NavigationAlarmSettingsScreenState(this.id);
}


class NavigationQRScreenState extends NavigationState {}

class NavigationPersonalSettingsScreenState extends NavigationState {}
class NavigationMainSettingsScreenState extends NavigationState {}
class NavigationSoundsSettingsScreenState extends NavigationState {}
class NavigationQuestionsSettingsScreenState extends NavigationState {}
class NavigationProposalScreenState extends NavigationState {}
class NavigationContactScreenState extends NavigationState {}
class NavigationLockSettingsScreenState extends NavigationState {}


class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationMainScreenState()) {
    on<NavigateToAuthScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationAuthScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToMainScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationMainScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToCardsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationCardsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToWishScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationWishScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToAimCreateScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationAimCreateScreenState(parentCircleId: event.circleId));
      emit(_navigationHistory.last);
    });

    on<NavigateToAimEditScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationAimEditScreenState(event.aimId));
      emit(_navigationHistory.last);
    });

    on<NavigateToTasksScreenEvent>((event, emit) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationTasksScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToSimpleTasksScreenEvent>((event, emit) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationSimpleTasksScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToWishesScreenEvent>((event, emit) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationWishesScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToAimsScreenEvent>((event, emit) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationAimsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToProfileScreenEvent>((event, emit) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
      _navigationHistory.add(NavigationProfileScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToTaskCreateScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationTaskCreateScreenState(event.parentAimId, isSimple: event.isSimple, type: event.type));
      emit(_navigationHistory.last);
    });

    on<NavigateToTaskEditScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationTaskEditScreenState(event.taskId));
      emit(_navigationHistory.last);
    });

    on<NavigateToMainSphereEditScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationMainSphereEditScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToDiaryScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationDiaryScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToDiaryEditScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationDiaryEditScreenState(event.id));
      emit(_navigationHistory.last);
    });

    on<NavigateToGalleryScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationGalleryScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToQRScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationQRScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToPersonalSettingsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationPersonalSettingsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToMainSettingsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationMainSettingsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToSoundsSettingsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationSoundsSettingsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToQuestionsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationQuestionsSettingsScreenState());
      emit(_navigationHistory.last);
    });
    on<NavigateToProposalScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationProposalScreenState());
      emit(_navigationHistory.last);
    });
    on<NavigateToContactScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationContactScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToAlarmSettingsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationAlarmSettingsScreenState(event.id));
      emit(_navigationHistory.last);
    });
    on<NavigateToLockSettingsScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationLockSettingsScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateToAlarmScreenEvent>((event, emit) {
      _navigationHistory.add(NavigationAlarmScreenState());
      emit(_navigationHistory.last);
    });

    on<NavigateBackEvent>((event, emit) {
      emit(_navigationHistory.last);
    });
  }
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

  void clearHistory() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.clear();
      _navigationHistory.add(NavigationMainScreenState());
    }
  }

  @override
  Future<void> close() {
    _backPressController.close();
    return super.close();
  }
}