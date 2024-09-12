import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/common/gradientText.dart';
import 'package:wishmap/data/models.dart';
import 'package:wishmap/data/static_affirmations_men.dart';

import '../ViewModel.dart';
import '../interface_widgets/outlined_button.dart';
import '../res/colors.dart';

Future<void> showOverlayedMissionScreen(BuildContext context,
    int totalRepeatCount, int type) async {
  Completer<void> completer = Completer<void>();
  OverlayEntry? overlayEntry;

  var myOverlay = MissionScreen(totalRepeatCount, type, () {
    overlayEntry?.remove();
    completer.complete();
  });

  overlayEntry = OverlayEntry(
    builder: (context) => myOverlay,
  );

  Overlay.of(context).insert(overlayEntry);
  return completer.future;
}

class MissionScreen extends StatefulWidget {

  int totalRepeatCount;
  int type = 0;

  Function() onClose;

  MissionScreen(this.totalRepeatCount, this.type, this.onClose, {super.key});

  @override
  MissionScreenState createState() => MissionScreenState();
}

class MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late AppViewModel vm;
  int currentRepeatCount = 0;
  Uint8List? image;
  List<List<String>> affirmations = [];

  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;

  List<WishItem> wishes = [];
  WishItem? currentWish;
  List<TaskItem> tasks = [];
  TaskItem? currentTask;

  String lastDirection = "";

  @override
  void initState() {
    currentRepeatCount = widget.totalRepeatCount;
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addListener(() {
      setState(() {
        if (_controller.isAnimating) _offset = _animation.value;
      });
    });
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed &&
          (_offset.dx > 400 || _offset.dx < -400 || _offset.dy < -650)) {
        _offset = Offset.zero;
        if (currentRepeatCount > 1) {
          currentRepeatCount--;
          // Создаем новый стек после завершения анимации
          image = null;
          await _generateNewStack();
          setState(() {});
        } else {
          widget.onClose();
        }
      }
    });

    if (widget.type == 2) {
      final affs = IMenAffirmations;
      final List<String> selectedAfss = [];
      for (var i = 0; i < 5; i++) {
        selectedAfss.add(affs[Random().nextInt(affs.length)]);
      }
      affirmations.add(selectedAfss);
    }
  }

  Future<void> _generateNewStack() async {
    if (widget.type == 0) {
      if (vm.wishItems.isNotEmpty) {
        currentRepeatCount = currentRepeatCount<vm.wishItems.length?currentRepeatCount:vm.wishItems.length;
        final rand = Random().nextInt(vm.wishItems.length);
        currentWish = vm.wishItems[rand];
        vm.wishItems.removeAt(rand);
        image = await vm.getWishImage(currentWish!.id);
      }
    } else {
      if (vm.taskItems.isNotEmpty) {
        currentRepeatCount = currentRepeatCount<vm.taskItems.length?currentRepeatCount:vm.taskItems.length;
        final rand = Random().nextInt(vm.taskItems.length);
        currentTask = vm.taskItems[rand];
        vm.taskItems.removeAt(rand);
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    _startOffset = details.globalPosition;
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
        _offset = details.globalPosition - _startOffset;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final direction = velocity.dx > 0 ? "right" : "left";
    if (velocity.dx.abs() < velocity.dy.abs() &&
        velocity.dy < 0) {
      lastDirection = "top";
    } else {
      lastDirection = direction;
    }

    // Анимированный возврат на место
    _controller.reset();
    _animation = Tween<Offset>(
      begin: _offset,
      end: lastDirection != "top" ? (((_offset.dx).abs()) < 100
          ? Offset.zero
          : Offset((_offset.dx < 0 ? -1 : 1) * 500, 0)) : (_offset.dy < 250
          ? Offset(_offset.dx, -700)
          : Offset.zero),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();

    if (widget.type == 0) {
      if (lastDirection == "right" && currentWish != null) {
        if (currentWish!.isActive==false) {
          vm.activateSphereWish(currentWish!.id, true);
        } else if(currentWish!.isChecked==false) {
          vm.updateWishStatus(currentWish!.id, true);
        } else {
          vm.hideSphereWish(currentWish!.id, true, true);
        }
      } else if (lastDirection == "top" && currentWish != null) {
        vm.deleteSphereWish(currentWish!.id, null, null);
      }
    } else if (widget.type == 1) {
      if (lastDirection == "right" && currentTask != null) {
        if (currentTask!.isActive==false) {
          //vm.activateTask(currentTask!.id, true);
        } else {
          vm.updateTaskStatus(currentTask!.id, true);
        }
      } else if (lastDirection == "top" && currentTask != null) {
        vm.deleteTask(currentTask!.id, currentTask!.parentId);
      }
    }
  }

  void autoSwipe(String direction) {
    _controller.reset();
    _animation = Tween<Offset>(
      begin: _offset,
      end: direction != "top" ? (direction == "left"
          ? const Offset(-500, 0)
          : const Offset(500, 0)) : (Offset(_offset.dx, -700)),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();

    if (widget.type == 0) {
      if (direction == "right" && currentWish != null) {
        if (currentWish!.isActive==false) {
          vm.activateSphereWish(currentWish!.id, true);
        } else if(currentWish!.isChecked==false) {
          vm.updateWishStatus(currentWish!.id, true);
        } else {
          vm.hideSphereWish(currentWish!.id, true, true);
        }
      } else if (direction == "top" && currentWish != null) {
        vm.deleteSphereWish(currentWish!.id, null, null);
      }
    } else if (widget.type == 1) {
      if (direction == "right" && currentTask != null) {
        if (currentTask!.isActive==false) {
          //vm.activateTask(currentTask!.id, true);
        } else {
          vm.updateTaskStatus(currentTask!.id, true);
        }
      } else if (direction == "top" && currentTask != null) {
        vm.deleteTask(currentTask!.id, currentTask!.parentId);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<AppViewModel>(
            builder: (context, appVM, child) {
              vm = appVM;
              if (widget.type == 0) {
                if (currentWish == null && appVM.wishItems.isNotEmpty) {
                  currentRepeatCount = currentRepeatCount<vm.wishItems.length?currentRepeatCount:vm.wishItems.length;
                  final rand = Random().nextInt(vm.wishItems.length);
                  currentWish = vm.wishItems[rand];
                  vm.wishItems.removeAt(rand);
                  vm.getWishImage(currentWish!.id).then((v){
                    setState(() {
                      image = v;
                    });
                  });
                }
              } else if (widget.type == 1) {
                if (currentTask == null && appVM.taskItems.isNotEmpty) {
                  currentRepeatCount = currentRepeatCount<vm.taskItems.length?currentRepeatCount:vm.taskItems.length;
                  final rand = Random().nextInt(vm.taskItems.length);
                  currentTask = vm.taskItems[rand];
                  vm.taskItems.removeAt(rand);
                }
              }
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: (widget.type == 0) ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(
                                  Icons.keyboard_arrow_left, size: 28,
                                  color: AppColors.gradientStart),
                              onPressed: () {
                                widget.onClose();
                              }
                          ),
                          const SizedBox(width: 40, height: 40,)
                        ],
                      ),
                      GradientText(currentRepeatCount.toString(),
                        gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd
                            ]
                        ),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 32),
                      ),
                      LinearProgressIndicator(value: 1 -
                          (currentRepeatCount / widget.totalRepeatCount)),
                      const SizedBox(height: 16),
                      Expanded(child:
                      GestureDetector(
                        onPanStart: _onPanStart,
                        onPanEnd: _onPanEnd,
                        onPanUpdate: _onPanUpdate,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(offset: _offset,
                              child: child,
                            );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              image != null ?
                              AnimatedSwitcher(
                                duration: const Duration(seconds: 1),
                                child: Image.memory(image!, fit: BoxFit.cover)
                              ) :
                              Image.asset("assets/icons/vodopad_inactive.png",
                                  fit: BoxFit.cover),
                              Center(child: Image.asset(
                                  currentWish?.isActive==false?'assets/icons/unactual.png':currentWish?.isChecked==true?'assets/icons/done_outlined.png':'assets/icons/actual.png', height: 90,
                                  width: 90)),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("удалить", style: TextStyle(
                                        color: AppColors.greytextColor)),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        children: [
                                          const Expanded(
                                            child: Text('Не трогать',
                                                style: TextStyle(
                                                    color: AppColors.greytextColor)),
                                          ),
                                          Image.asset(
                                              'assets/icons/hand.png', height: 44,
                                              width: 44),
                                          Expanded(
                                            child: Text(currentWish?.isActive==false?'Актуально':currentWish?.isChecked==false?'Выполнено':'Скрыть',
                                                style: const TextStyle(color: AppColors.greytextColor), textAlign: TextAlign.right,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      ),
                      const SizedBox(height: 16),
                      Text(currentWish != null ? appVM.getPath(
                          currentWish!.id, "w") : "", style: const TextStyle(
                          color: AppColors.greytextColor)),
                      GradientText(
                        currentWish?.text.replaceAll("HEADERSIMPLETASKHEADER", "") ?? "", gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd
                          ]
                      ),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 28),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(onTap: () {
                            autoSwipe("left");
                          },
                              child: Image.asset(
                                  currentWish?.isActive==false?'assets/icons/unactual.png':currentWish?.isChecked==true?'assets/icons/done_outlined.png':'assets/icons/actual.png', height: 52,
                                  width: 52)),
                          InkWell(onTap: () {
                            autoSwipe("top");
                          },
                              child: SvgPicture.asset(
                                  'assets/icons/circle_trash.svg', height: 52,
                                  width: 52)),
                          InkWell(onTap: () {
                            autoSwipe("right");
                          },
                              child: Image.asset(
                                  currentWish?.isActive==false?'assets/icons/actual.png':currentWish?.isChecked==false?'assets/icons/done_outlined.png':'assets/icons/wish_hidden.png', height: 52,
                                  width: 52))
                        ],
                      )
                    ],
                  ) : (widget.type == 1) ?
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // the '2023' part
                              ),
                              icon: const Icon(Icons.keyboard_arrow_left,
                                  size: 28, color: AppColors.gradientStart),
                              onPressed: () {
                                widget.onClose();
                              }
                          ),
                          const SizedBox(width: 40, height: 40,)
                        ],
                      ),
                      GradientText(currentRepeatCount.toString(),
                        gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd
                            ]
                        ),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 32),
                      ),
                      LinearProgressIndicator(value: 1 -
                          (currentRepeatCount / widget.totalRepeatCount)),
                      const SizedBox(height: 16),
                      Expanded(child:
                      GestureDetector(
                        onPanStart: _onPanStart,
                        onPanEnd: _onPanEnd,
                        onPanUpdate: _onPanUpdate,
                        child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Transform.translate(offset: _offset,
                                child: child,
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(color: AppColors.grey)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    currentTask?.isChecked == true ? Image
                                        .asset(
                                        "assets/icons/task_checked_outlined.png",
                                        height: 84, width: 84) : currentTask
                                        ?.isActive == false ? Image.asset(
                                        "assets/icons/task_unactual_outlined.png",
                                        height: 84, width: 84) : currentTask
                                        ?.isActive == true
                                        ? Image.asset(
                                        "assets/icons/task_actual_outlined.png",
                                        height: 84, width: 84)
                                        : const SizedBox(),
                                    const SizedBox(height: 40),
                                    Text(currentTask != null ? appVM.getPath(
                                        currentTask!.id, "t") : "",
                                      style: const TextStyle(
                                          color: AppColors.greytextColor),),
                                    GradientText(
                                      currentTask?.text.replaceAll('HEADERSIMPLETASKHEADER', '') ?? "Loading...",
                                      gradient: const LinearGradient(
                                          colors: [
                                            AppColors.gradientStart,
                                            AppColors.gradientEnd
                                          ]
                                      ),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 28),
                                    ),
                                    const SizedBox(height: 60),
                                    const Text("Удалить", style: TextStyle(
                                        color: AppColors.greytextColor)),
                                    Row(mainAxisAlignment: MainAxisAlignment
                                        .spaceAround,
                                      children: [
                                        const Expanded(
                                          child: Text("Не трогать",
                                              style: TextStyle(color: AppColors
                                                  .greytextColor)),
                                        ),
                                        Image.asset(
                                          'assets/icons/hand.png', height: 44,
                                          width: 44,
                                          color: AppColors.greytextColor,),
                                        Expanded(
                                          child: Text(currentTask?.isChecked == false &&
                                              currentTask?.isActive == false
                                              ? "Не трогать"
                                              : currentTask?.isChecked == true
                                              ? "Не трогать"
                                              : "Выполнено", style: const TextStyle(
                                              color: AppColors.greytextColor), textAlign: TextAlign.right),
                                        )
                                      ],),
                                    const SizedBox(height: 16)
                                  ],
                                )
                            )
                        ),
                      ),
                      ),
                      const SizedBox(height: 33),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(onTap: () {
                            autoSwipe("left");
                          },
                              child: SvgPicture.asset(
                                  'assets/icons/circle_close.svg', height: 52,
                                  width: 52)),
                          InkWell(onTap: () {
                            autoSwipe("top");
                          },
                              child: SvgPicture.asset(
                                  'assets/icons/circle_trash.svg', height: 52,
                                  width: 52)),
                          InkWell(
                              onTap: () {
                                autoSwipe("right");
                              },
                              child: currentTask?.isChecked == false &&
                                  currentTask?.isActive == false ? const SizedBox(width: 52) : currentTask
                                  ?.isChecked == true ? const SizedBox(width: 52) : Image
                                  .asset(
                                  'assets/icons/task_checked_outlined.png',
                                  height: 52, width: 52)

                          )
                        ],
                      )
                    ],
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize
                                    .shrinkWrap, // the '2023' part
                              ),
                              icon: const Icon(Icons.keyboard_arrow_left,
                                  size: 28, color: AppColors.gradientStart),
                              onPressed: () {
                                widget.onClose();
                              }
                          ),
                          const SizedBox(width: 40, height: 40,)
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("Выберите аффирмацию дня", style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700)),
                      const Text("Аффирмация будет указана в “Я”",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greytextColor)),
                      const SizedBox(height: 16),
                      const Text(
                          "Аффирмации - прикладной инструмент для достижения мечты или цели. Служит для повторения с целью изменить наше мышление и отношение к жизни",
                          style: TextStyle(
                              fontSize: 12, color: AppColors.greytextColor)),
                      const SizedBox(height: 32),
                      ListView.builder(shrinkWrap: true,
                          itemCount: affirmations.last.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                appVM.updateMainSphereAffirmation(
                                    affirmations.last[index]);
                                widget.onClose();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(color: Colors.white,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8, 8, 16, 8),
                                      child: Container(
                                        height: 40, width: 40,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                7),
                                            color: AppColors.strangeBgColor),
                                        child: Center(child: Text(
                                            IMenEmoji[Random().nextInt(
                                                IMenEmoji.length)])),
                                      ),
                                    ),
                                    Expanded(child: Text(
                                        "\"${affirmations.last[index]}\"",
                                        maxLines: 3,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)))
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: () {
                          final affs = IMenAffirmations;
                          final List<String> selectedAfss = [];
                          for (var i = 0; i < 5; i++) {
                            selectedAfss.add(affs[Random().nextInt(
                                affs.length)]);
                          }
                          setState(() {
                            affirmations.add(selectedAfss);
                          });
                        },
                        child: const GradientText(
                            "Сменить аффирмации", gradient: LinearGradient(
                            colors: [AppColors.gradientStart, AppColors
                                .gradientEnd
                            ]
                        )),
                      ),
                      const Spacer(),
                      OutlinedGradientButton("Назад", () {
                        if (affirmations.length > 1) {
                          setState(() {
                            affirmations.removeLast();
                          });
                        }
                      })
                    ],
                  ),
                ),
              );
            })
    );
  }
}