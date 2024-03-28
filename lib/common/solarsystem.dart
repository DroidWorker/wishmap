import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishmap/ViewModel.dart';
import 'package:wishmap/data/models.dart';
import 'dart:math';
import 'package:flutter/physics.dart';

import '../data/static.dart';
import '../data/static_affirmations_women.dart';
import '../navigation/navigation_block.dart';

class CircleWidget extends StatefulWidget {
  final itemId;
  final Circle circle;
  final double size;
  final Pair center;
  final Function(double) onRotate;
  final Function(DragEndDetails) onEndRotate;
  final Function(int id, int itemId) startMoving;
  final Function(int id, int parentId) doubleTap;

  CircleWidget({Key? key,required this.itemId, required this.circle, required this.size, required this.center, required this.onRotate, required this.onEndRotate, required this.startMoving, required this.doubleTap}) : super(key: key);

  @override
  _CircleWidgetState createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget>{
  double startAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.startMoving(widget.circle.id, widget.itemId);
      },
      onDoubleTap: (){
        widget.doubleTap(widget.circle.id, widget.circle.parentId);
      },
      onPanStart: (details) {
        final centerX = widget.center.key;
        final centerY = widget.center.value;
        startAngle = atan2(details.globalPosition.dy - centerY, details.globalPosition.dx - centerX);
      },
      onPanUpdate: (details) {
        final centerX = widget.center.key;
        final centerY = widget.center.value;
        final currentAngle = atan2(details.globalPosition.dy - centerY, details.globalPosition.dx - centerX);

        double difference = (currentAngle - startAngle + pi) % (2 * pi) - pi;
        final angleChange = difference < -pi ? difference + 2 * pi : difference;

        startAngle = currentAngle;
        widget.onRotate(angleChange);
      },
      onPanEnd: (details) {
        widget.onEndRotate(details);
      },
      child: Container(
        width: widget.circle.radius.toDouble(),
        height: widget.circle.radius.toDouble(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.circle.isActive?widget.circle.color:const Color.fromARGB(255, 217, 217, 217),
        ),
        child: Stack(
          children: [
            Center( // Используйте Center, чтобы разместить текст по центру
                child: AutoSizeText(
                  widget.circle.text,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                )
            ),
            if(widget.circle.isChecked)Align(
              alignment: Alignment.topRight,
              child: Image.asset('assets/icons/wish_done.png', width: 20, height: 20),
            )
          ],
        )
      ),
    );
  }
}
class CircularDraggableCircles extends StatefulWidget {
  List<Circle> circles;
  bool clearData = true;
  double size;
  Pair center;

  CircularDraggableCircles({super.key, required this.circles, required this.size, required this.center,this.clearData=true});

  @override
  CircularDraggableCirclesState createState() => CircularDraggableCirclesState();
}

class CircularDraggableCirclesState extends State<CircularDraggableCircles> with TickerProviderStateMixin {
  AppViewModel? vm;

  List<MainCircle> centralCircles = [];

  int plusId = -1;//used for insert sphere in selected place
  
  List<Offset> circlePositions = [];
  List<double> circleRotations = [];
  List<Offset> plusesPositions = [];
  List<double> plusesRotations = [];

  int circlesHash = 0;

  int rotationCounter = 0;

  double lastRotation = 0.0;
  double lastdirection = 0.0;
  double inertia = 0.0;
  late AnimationController ctrl;

  double widgetTop = 0.0;
  double widgetLeft = 0.0;
  double alphaAnimValue = 1.0;
  double textAlphaAnimValue = 1.0;
  late Animation<double> AlphaAnimation;
  late Animation<double> SHAlphaAnimation;
  late Animation<double> ReverceAlphaAnimation;
  late AnimationController movingController;
  late AnimationController afterMovingController;
  late AnimationController showHideController;
  bool animationDirectionForward = true;
  //late Size screenSize;

  bool allowClick = true;

  Size getScreenSize(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.size;
  }

  @override
  void initState() {
    super.initState();
    print("iniiiiiiiiiit");
    var firstCercle = vm?.mainScreenState?.allCircles.firstWhere((element) => element.id==0);
    if(firstCercle!=null)vm?.mainCircles=[MainCircle(id: 0, coords: Pair(key:0.0,value:0.0), text: firstCercle.text, color: firstCercle.color)];
    ctrl = AnimationController.unbounded(vsync: this);
    movingController = AnimationController.unbounded(vsync: this);
    afterMovingController = AnimationController.unbounded(vsync: this);
    showHideController = AnimationController.unbounded(vsync: this);
    final angleBetween = 2*pi/widget.circles.length;
    plusesPositions.clear();
    plusesRotations.clear();
    final centerX = widget.center.key-40;
    final centerY = widget.center.value-40;
    for (int i = 0; i < widget.circles.length; i++) {
      widget.circles[i].radius=(widget.size*0.2).toInt();
      circleRotations.add(2 * pi * i / widget.circles.length);
      plusesRotations.add((2 * pi * i / widget.circles.length) + angleBetween / 2);
      final x = (centerX + (widget.size/2-40) * cos(circleRotations[i]))+(80-widget.circles[i].radius)/2;
      final y = (centerY + (widget.size/2-40) * sin(circleRotations[i]))+(80-widget.circles[i].radius)/2;
      final px = centerX + (widget.size/2-40) * cos(plusesRotations[i]);
      final py = centerY + (widget.size/2-40) * sin(plusesRotations[i]);
      circlePositions.add(Offset(x, y));
      if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive)plusesPositions.add(Offset(px, py));
    }
    if(widget.circles.isEmpty){
      final px = widget.center.key-40 + (widget.size/2-40) * cos(1);
      final py = widget.center.value-40 + (widget.size/2-40) * sin(1);
      if(centralCircles.isEmpty||(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive))plusesPositions.add(Offset(px,py));
      plusesRotations.add(1);
    }
    //screenSize = getScreenSize(this as BuildContext);
    movingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Длительность анимации
    );
    afterMovingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Длительность анимации
    );
    showHideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Длительность анимации
    );
    AlphaAnimation = Tween(begin: 1.0, end: 0.0).animate(movingController);
    SHAlphaAnimation = Tween(begin: 1.0, end: 0.0).animate(showHideController);
    ReverceAlphaAnimation = Tween(begin: 0.0, end: 1.0).animate(afterMovingController);
    movingController.addStatusListener(animStatusListener);

    SHAlphaAnimation.addListener(() {
      setState(() {
        alphaAnimValue = SHAlphaAnimation.value;
      });
    });

    showHideController.addStatusListener((status) {
      if(status==AnimationStatus.completed){
        int circleid = vm!.mainScreenState!.allCircles.isNotEmpty?vm!.mainScreenState!.allCircles.map((circle) => circle.id).reduce((value, element) => value > element ? value : element)+1:-101;
        int prevId = -1;
        int nextId = -1;
        if(plusId>=0){
          if(widget.circles.length>plusId+1){
            //если количество свер на окружности больше чем количество плюсов и это не последняя  сфера в базе
            //(если сфера вставляется не последней)
            /*prevId = widget.circles[plusId].id;
            nextId = widget.circles[plusId+1].id;*/
            prevId = widget.circles[plusId].id;
            final nextIndex = vm?.mainScreenState?.allCircles.indexWhere((element) => element.id == widget.circles[plusId].id)??-1;
            nextId = (nextIndex!=-1)? vm?.mainScreenState?.allCircles[nextIndex+1].id??-1: -1;
            //..circleid = (widget.circles[plusId+1].id-widget.circles[plusId].id)~/2+widget.circles[plusId].id;
          }else if(widget.circles.length==plusId+1){
            //если сера вставляется в конец(что = вставке в начало)
            prevId = vm?.mainScreenState?.allCircles.where((element) => element.id == widget.circles[plusId].id).firstOrNull?.id??-1;
            nextId = -1;
            //circleid = ((((widget.circles[plusId].id+10000)~/10000)*10000)-widget.circles[plusId].id)~/2+widget.circles[plusId].id;
          }else{
            //сли создается на чистой окружности
            prevId = -1;
            nextId = -1;
            //circleid = vm!.mainScreenState!.allCircles.isNotEmpty?((vm!.mainScreenState!.allCircles.last.id) ~/ 10000) * 10000 + 10000:-101;
          }
        }
        if(widget.circles.isNotEmpty)plusId++;
        vm?.cachedImages.clear();
        vm?.createNewSphereWish(WishData(id: circleid, prevId: prevId, nextId: nextId, parentId: centralCircles.last.id, text: "Новое желание", description: "", affirmation: (defaultAffirmations.join("|").toString()), color: Colors.red), true);
        widget.circles.insert(plusId, Circle(id: circleid, parentId: centralCircles.last.id, prevId: prevId, nextId: nextId, text: "Новое желание", color: Colors.red, radius: (widget.size*0.2).toInt(), isChecked: false));
        plusId=-1;
        circlePositions.clear();
        circleRotations.clear();
        plusesPositions.clear();
        plusesRotations.clear();
        final angleBetween = 2*pi/widget.circles.length;
        final centerX = widget.center.key-40;
        final centerY = widget.center.value-40;
        for (int i = 0; i < widget.circles.length; i++) {
          widget.circles[i].radius=(widget.size*0.2).toInt();
          circleRotations.add(2 * pi * i / widget.circles.length);
          plusesRotations.add((2 * pi * i / widget.circles.length) + angleBetween / 2);
          final x = (centerX + (widget.size/2-40) * cos(circleRotations[i]))+(80-widget.circles[i].radius)/2;
          final y = (centerY + (widget.size/2-40) * sin(circleRotations[i]))+(80-widget.circles[i].radius)/2;
          final px = centerX + (widget.size/2-40) * cos(plusesRotations[i]);
          final py = centerY + (widget.size/2-40) * sin(plusesRotations[i]);
          circlePositions.add(Offset(x, y));
          if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive)plusesPositions.add(Offset(px, py));
        }
        var diametr = (widget.size*0.2).toInt();
        if(widget.circles.length>8&&widget.circles.length<=16){
          for(int i = 0; i < widget.circles.length; i++){
            if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/2*(cos(circleRotations[i]))).toInt().abs();}
            else{widget.circles[i].radius=(widget.size*0.15).toInt();}
          }
        }else if(widget.circles.length>16){
          for(int i = 0; i < widget.circles.length; i++){
            if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/2*(cos(circleRotations[i]))).toInt().abs();}
            else{widget.circles[i].radius=(widget.size*0.07).toInt();}
          }
        }
        showHideController.reverse();
      }
    });
  }
  @override
  void dispose() {
    ctrl.dispose();
    movingController.dispose();
    afterMovingController.dispose();
    showHideController.dispose();
    super.dispose();
  }
  void startInertia(double velocity) {
    ctrl.animateWith(
      FrictionSimulation(
        0.03, // Коэффициент трения
        ctrl.value,
        velocity / 70, // Скорость инерции
      ),
    );
  }

  void initAnim(int id, int itemId){https://drive.google.com/file/d/1QdsM-FHXSbf8tl9zTUkETXqL6pscM7Mh/view?usp=drive_link
    final initialTop = animationDirectionForward?widget.center.value-centralCircles.last.radius:widget.circles[itemId].radius*-0.5;//centralCircles.last.coords.value;
    final initialLeft = animationDirectionForward?widget.center.key-centralCircles.last.radius:widget.center.key * 2 - centralCircles.last.radius*1.5;//centralCircles.last.coords.key;
    final finalTop = animationDirectionForward?widget.circles[itemId].radius*-0.5:widget.center.value-centralCircles[centralCircles.length-2].radius;
    final finalRight = animationDirectionForward?widget.center.key * 2 - centralCircles.last.radius*1.5:widget.center.key-centralCircles[centralCircles.length-2].radius;

    final radiusToCenterInitialTop = animationDirectionForward?circlePositions[itemId].dy:widget.center.value - centralCircles[0].radius;
    final radiusToCenterInitialLeft = animationDirectionForward?circlePositions[itemId].dx:widget.center.key - centralCircles[0].radius;
    final radiusToCenterFinalTop = animationDirectionForward?widget.center.value - centralCircles[0].radius:circlePositions[itemId].dy;
    final radiusToCenterFinalLeft = animationDirectionForward?widget.center.key - centralCircles[0].radius:circlePositions[itemId].dx;
    //duplicate clicked sphere
    if(animationDirectionForward) {
      centralCircles.add(MainCircle(id: id,
          coords: Pair(key: circlePositions[itemId].dx,
              value: circlePositions[itemId].dy),
          text: widget.circles[itemId].text,
          textSize: 24,
          color: widget.circles[itemId].color,
          radius: centralCircles[0].radius,
          isActive: widget.circles[itemId].isActive,
          isChecked: widget.circles[itemId].isChecked));
      if (centralCircles.length > 2) {
        centralCircles[centralCircles
            .length - 3].isVisible = false;
      }
      AlphaAnimation = Tween(begin: 1.0, end: 0.0).animate(movingController);
      ReverceAlphaAnimation = Tween(begin: 0.0, end: 1.0).animate(afterMovingController);
    }else{
      AlphaAnimation = Tween(begin: 0.0, end: 1.0).animate(movingController);
      ReverceAlphaAnimation = Tween(begin: 1.0, end: 0.0).animate(afterMovingController);
    }

    // Создаем анимацию перемещения виджета
    final Vanimation = Tween(
        begin: initialTop, end: finalTop).animate(
      CurvedAnimation(
        parent: movingController,
        // controller - это объект AnimationController
        curve: Curves
            .easeInOut, // Вы можете выбрать другую кривую анимации
      ),
    );
    final Hanimation = Tween(
        begin: initialLeft, end: finalRight).animate(
      CurvedAnimation(
        parent: movingController,
        // controller - это объект AnimationController
        curve: Curves
            .easeInOut, // Вы можете выбрать другую кривую анимации
      ),
    );
    final radiusToCenterVanimation = Tween(
        begin: radiusToCenterInitialTop,
        end: radiusToCenterFinalTop).animate(
      CurvedAnimation(
        parent: movingController,
        // controller - это объект AnimationController
        curve: Curves
            .easeInOut, // Вы можете выбрать другую кривую анимации
      ),
    );
    final radiusToCenterHanimation = Tween(
        begin: radiusToCenterInitialLeft,
        end: radiusToCenterFinalLeft).animate(
      CurvedAnimation(
        parent: movingController,
        // controller - это объект AnimationController
        curve: Curves
            .easeInOut, // Вы можете выбрать другую кривую анимации
      ),
    );
    // Добавляем слушателя анимации для обновления состояния и перерисовки виджета
    Vanimation.addListener(() {
      if(centralCircles.length>1) {
        setState(() {
        centralCircles[centralCircles
            .length - 2].coords.value =
            Vanimation.value;
      });
      }
    });
    Hanimation.addListener(() {
      if(centralCircles.length>1) {
        setState(() {
        centralCircles[centralCircles
            .length - 2].coords.key =
            Hanimation.value;
      });
      }
    });
    radiusToCenterVanimation.addListener(() {
        setState(() {
        centralCircles[centralCircles
            .length - 1].coords.value =
            radiusToCenterVanimation.value;
      });
    });
    radiusToCenterHanimation.addListener(() {
      setState(() {
        centralCircles[centralCircles
            .length - 1].coords.key =
            radiusToCenterHanimation.value;
      });
    });
    AlphaAnimation.addListener(() {
      setState(() {
        alphaAnimValue = AlphaAnimation.value;
        textAlphaAnimValue = AlphaAnimation.value;
      });
    });
    ReverceAlphaAnimation.addListener(() {
      setState(() {
        alphaAnimValue = ReverceAlphaAnimation.value;
      });
    });
  }

  void animStatusListener(status){
    if (status == AnimationStatus.completed) {
      if(animationDirectionForward){
        widget.circles = vm?.openSphere(centralCircles.last.id)??[];
        circlePositions.clear();
        circleRotations.clear();
        plusesPositions.clear();
        plusesRotations.clear();
        if(widget.circles.isEmpty){
          final px = widget.center.key-40 + (widget.size/2-40) * cos(1);
          final py = widget.center.value-40 + (widget.size/2-40) * sin(1);
          if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive)plusesPositions.add(Offset(px,py));
          plusesRotations.add(1);
        }
        final angleBetween = 2*pi/widget.circles.length;
        final centerX = widget.center.key-40;
        final centerY = widget.center.value-40;
        for (int i = 0; i < widget.circles.length; i++) {
          widget.circles[i].radius=(widget.size*0.2).toInt();
          circleRotations.add(2 * pi * i / widget.circles.length);
          plusesRotations.add((2 * pi * i / widget.circles.length) + angleBetween / 2);
          final x = (centerX + (widget.size/2-40) * cos(circleRotations[i]))+(80-widget.circles[i].radius)/2;
          final y = (centerY + (widget.size/2-40) * sin(circleRotations[i]))+(80-widget.circles[i].radius)/2;
          final px = centerX + (widget.size/2-40) * cos(plusesRotations[i]);
          final py = centerY + (widget.size/2-40) * sin(plusesRotations[i]);
          circlePositions.add(Offset(x, y));
          if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive)plusesPositions.add(Offset(px, py));
        }
        afterMovingController.reset();
        afterMovingController.forward();
        allowClick=true;
        print("alloew click - true1");
      }else{{
        if(centralCircles.length>2){
          centralCircles[centralCircles.length-3].isVisible = true;
        }
        setState(() {
          circlesHash=0;
          centralCircles.removeLast();
          allowClick=true;
          print("alloew click - true2");
        });
      }}
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild widget");
    vm = Provider.of<AppViewModel>(context);
    if(centralCircles.isEmpty||widget.clearData) {
      centralCircles = List<MainCircle>.from(vm!.mainCircles);
      if(centralCircles.length==1)textAlphaAnimValue = 1;
      widget.clearData=false;
    }

    final radius = MediaQuery.of(context).size.width*0.15;
    for (int i = 0; i<centralCircles.length; i++) {
      centralCircles[i].radius= radius;
      if (centralCircles[i].coords.key == 0.0 ||
          centralCircles[i].coords.value == 0.0) {
        centralCircles[i].coords = Pair(
            key: widget.center.key - centralCircles[i].radius,
            value: widget.center.value - centralCircles[i].radius);
      }
    }

    var newHash = 0;
    widget.circles.forEach((element) {
      newHash+=element.id;
    });
    if(newHash!= circlesHash) {
      var diametr = (widget.size*0.2).toInt();
      if(widget.circles.length>8&&widget.circles.length<=16&&circleRotations.length==widget.circles.length){
        for(int i = 0; i < widget.circles.length; i++){
          //if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/3.7*(cos(circleRotations[i]))).toInt().abs();}
          /*else{*/widget.circles[i].radius=(widget.size*0.15).toInt();//}
        }
      }else if(widget.circles.length>16){
        for(int i = 0; i < widget.circles.length; i++){
          if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/2*(cos(circleRotations[i]))).toInt().abs();}
          else{widget.circles[i].radius=(widget.size*0.07).toInt();}
        }
      }
      circleRotations.clear();
      plusesRotations.clear();
      circlePositions.clear();
      plusesPositions.clear();
      final angleBetween = 2 * pi / widget.circles.length;
      final centerX = widget.center.key-40;
      final centerY = widget.center.value-40;

      for (int i = 0; i < widget.circles.length; i++) {
        circleRotations.add(2 * pi * i / widget.circles.length);
        plusesRotations.add((2 * pi * i / widget.circles.length) + angleBetween / 2);
        if(widget.circles.length>8&&widget.circles.length<=16){
          //if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/3.7*(cos(circleRotations[i]))).toInt().abs();}
          /*else{*/widget.circles[i].radius=(widget.size*0.15).toInt();//}
        }else if(widget.circles.length>16){
            if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/2*(cos(circleRotations[i]))).toInt().abs();}
            else{widget.circles[i].radius=(widget.size*0.07).toInt();}
        } else{
          widget.circles[i].radius=(widget.size*0.2).toInt();
        }
        final x = (centerX + (widget.size/2-40) * cos(circleRotations[i]))+(80-widget.circles[i].radius)/2;
        final y = (centerY + (widget.size/2-40) * sin(circleRotations[i]))+(80-widget.circles[i].radius)/2;
        final px = centerX + (widget.size/2-40) * cos(plusesRotations[i]);
        final py = centerY + (widget.size/2-40) * sin(plusesRotations[i]);
        circlePositions.add(Offset(x, y));
        if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive)plusesPositions.add(Offset(px, py));
      }
      if(widget.circles.isEmpty){
        final px = widget.center.key-40 + (widget.size/2-40) * cos(1);
        final py = widget.center.value-40 + (widget.size/2-40) * sin(1);
        if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked&&centralCircles.last.isActive){plusesPositions.add(Offset(px,py));
        plusesRotations.add(1);}
      }
      circlesHash = newHash;
    }
    else{
      for(int i = 0; i<widget.circles.length; i++){
        if(widget.circles.length>8){
          widget.circles[i].radius=(widget.size*0.15).toInt();
        } else{
          widget.circles[i].radius=(widget.size*0.2).toInt();
        }
      }
    }

    final appViewModel = Provider.of<AppViewModel>(context);
    return Container(
     child:AnimatedBuilder(
          animation: ctrl,
          builder: (context, child) {
            final newRotation = ctrl.value - lastRotation;
            lastRotation = ctrl.value;
            if (ctrl.isAnimating) {
              _updateCircleRotation(
                newRotation, widget.size, widget.center, widget.size / 2,
                isAnim: true);
            }
            var lcent =  widget.center.key + 40 - widget.size / 2;
            var tcent = widget.center.value + 40 - widget.size / 2;
            return Stack(
              children: [
                Positioned(
                  left: lcent,
                  top: tcent,
                  child:
                  Container(
                    width: widget.size - 80, // Ширина контейнера
                    height: widget.size - 80, // Высота контейнера
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey, width: 2)
                    ),
                    child: const SizedBox(),
                  ),),
                if(centralCircles.length>1)Positioned(
                    left: widget.center.key+10,
                    bottom: widget.center.value,
                    width: centralCircles[centralCircles.length-2].coords.key-widget.center.key+50,
                    height: widget.center.value-centralCircles[centralCircles.length-2].coords.value-50,
                    child: CustomPaint(
                      painter: LinePainter(),
                    ),
                ),
                ...plusesPositions
                    .asMap()
                    .entries
                    .map((e) {
                  return Positioned(
                      left: plusesPositions[e.key].dx + 25,
                      top: plusesPositions[e.key].dy + 25,
                      child:
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(10), // Увеличьте внешний отступ, чтобы увеличить область срабатывания
                          child: Container(
                            width: 10, // Ширина контейнера
                            height: 10, // Высота контейнера
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                            child: const Center(
                              child: Text("+", style: TextStyle(fontSize: 8, color: Colors.white),),
                            ),
                          ),
                        ),
                        onTap: () {
                          print("onplustap");
                          if(centralCircles.last.id==0){
                            appViewModel.hint = textNewI[Random().nextInt(18)];
                          }else if(centralCircles.last.id<900){
                            appViewModel.hint = textNewSphere[Random().nextInt(18)];
                          }
                          if(widget.circles.length<12) {
                            plusId= e.key;
                            showHideController.reset();
                            showHideController.forward();
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("максимальное количество сфер - 12"),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      )
                  );
                }
                ),
                ...widget.circles
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final circle = entry.value;
                  return Positioned(
                      left: circlePositions[index].dx,
                      top: circlePositions[index].dy,
                      child: AnimatedBuilder(
                        animation: AlphaAnimation,
                        builder: (context, child) {
                          return Opacity(
                              opacity: alphaAnimValue,
                              child: CircleWidget(
                                  itemId: index,
                                  circle: circle,
                                  size: widget.size,
                                  center: widget.center,
                                  onRotate: (angle) {
                                    print("oncircletap0");
                                    lastdirection = angle;
                                    _updateCircleRotation(
                                        angle, widget.size, widget.center,
                                        (widget.size) / 2);
                                  },
                                  onEndRotate: (details) {
                                    print("oncircletap1");
                                    startInertia(
                                        ((details.velocity.pixelsPerSecond.dx +
                                            details.velocity.pixelsPerSecond.dy)
                                            .abs() / 2) *
                                            (lastdirection < 0 ? (-1) : 1));
                                    /*rotationCounter++;
                                    if(rotationCounter==5){
                                      rotationCounter=0;
                                      if(centralCircles.last.id==0) {
                                        appViewModel.hint = "Это анимация, которая призвана показать, как сферы вашей жизни словно вращаются по внешней орбите, в центре которой ваше 'Я'";
                                      } else if(centralCircles.last.id < 900)appViewModel.hint = "Это анимация, которая призвана показать, как желания вашей жизни словно вращаются по внешней орбите, в центре которой определенная сфера жизни";
                                      else appViewModel.hint = "Это анимация, которая призвана показать, как желания вашей жизни словно вращаются по внешней орбите, в центре которой желание побольше";
                                    }*/
                                  },
                                  startMoving: (id, itemId) {
                                    print("oncircletap2 - $allowClick");
                                    if(allowClick) {
                                      print(
                                          "allow stat change false - start moving");
                                      allowClick = false;
                                      animationDirectionForward = true;
                                      initAnim(id, itemId);
                                      if (!widget.circles[itemId].isActive) {
                                        itemId < 900
                                            ? appViewModel.hint =
                                        textSphereActualize[Random().nextInt(5)]
                                            :
                                        appViewModel.hint =
                                        textWishActualize[Random().nextInt(15)];
                                      } else {
                                        appViewModel.hint =
                                        "Ты в карте сферы. Сфера — это целая область жизни. Если ты хочешь развить данную сферу, задай себе вопрос: “что я хочу изменить в этой сфере, каковы мои желания?”. Отвечая на этот вопрос, создавай желания, исполнение которых качественно изменит данную сферу. Создавай, выбирай аффирмации и управляй своим будущим. Чтобы создать желание, просто нажми «+» на орбите, что вокруг сферы.";
                                      }
                                      // Запускаем анимацию
                                      movingController
                                          .reset();
                                      movingController
                                          .forward();
                                    }
                                  },
                                  doubleTap: (id, parentId){
                                    print("oncircletap3");
                                    appViewModel.mainCircles = centralCircles;
                                    if(allowClick&&!entry.value.isActive&&!entry.value.isChecked&&(appViewModel.settings.fastActMainSphere||appViewModel.settings.fastActSphere||appViewModel.settings.fastActWish)){
                                      if(id==0){
                                        if(appViewModel.settings.fastActMainSphere){
                                          appViewModel.activateSphereWish(id, true);
                                          widget.circles.where((element) => element.id==id).firstOrNull?.isActive=true;
                                          setState(() { });
                                        }else appViewModel.addError("Режим быстрой актуализации отключен в настройках");
                                      }else if(parentId==0){
                                        if(appViewModel.settings.fastActSphere){
                                          appViewModel.activateSphereWish(id, true);
                                          widget.circles.where((element) => element.id==id).firstOrNull?.isActive=true;
                                          setState(() { });
                                        }else appViewModel.addError("Режим быстрой актуализации едоступен");
                                      }else if(parentId!=0){
                                       if(appViewModel.settings.fastActWish&&(centralCircles.lastOrNull?.isActive==true||(appViewModel.mainScreenState!.allCircles.firstWhereOrNull((element) => element.id==parentId)?.parenId==0&&appViewModel.settings.sphereActualizingMode==1)||(appViewModel.settings.wishActualizingMode==1&&(appViewModel.settings.sphereActualizingMode==1||appViewModel.isParentSphereActive(id))))){
                                         appViewModel.activateSphereWish(id, true);
                                         widget.circles.where((element) => element.id==id).firstOrNull?.isActive=true;
                                         centralCircles.forEach((element) {element.isActive=true;});
                                         appViewModel.mainCircles = centralCircles;
                                         setState(() { });
                                       }else appViewModel.addError("Актуализация невозможна");
                                      }
                                    }else{
                                      appViewModel.cachedImages.clear();
                                      appViewModel.wishScreenState = null;
                                      appViewModel.startWishScreen(
                                          entry.value.id, 0, false);
                                      appViewModel.mainCircles = centralCircles;
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigateToWishScreenEvent());
                                    }
                                  },
                              )
                          );
                        },
                      )
                  );
                }).toList(),
                ...centralCircles
                    .asMap()
                    .entries
                    .where((entry) {
                  return entry.value
                      .isVisible; // Фильтруем элементы по условию isVisible
                }).map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  return Positioned(
                      left: value.coords.key,
                      top: value.coords.value,
                      child: GestureDetector(
                        child: Container(
                            width: value.radius * 2,
                            height: value.radius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: value.isActive?value.color:const Color.fromARGB(255, 217, 217, 217),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 5,),
                                      AutoSizeText(
                                        value.text,
                                        maxLines: 1,
                                        minFontSize: 14,
                                        style: const TextStyle(color: Colors.white, fontSize: 24),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],),
                                ),
                                if(value.isChecked)Align(
                                  alignment: Alignment.topRight,
                                  child: Image.asset('assets/icons/wish_done.png', width: 25, height: 25),
                                )
                              ],
                            )
                        ),
                        onDoubleTap: () async {
                          print("oncentralcircletap");
                          if(allowClick){
                            /*if(appViewModel.settings.fastActMainSphere){
                              await appViewModel.activateSphereWish(0, true, updateScreen: true).then((value) {
                                setState(() {
                                  widget.circles = appViewModel.currentCircles;
                                  centralCircles = appViewModel.mainCircles;
                                });
                              });
                            }*/
                              final id = centralCircles[index].id;
                              final parentId = appViewModel.mainScreenState!.allCircles.firstWhereOrNull((element) => element.id==id)?.parenId;
                              if(id==0){
                                if(appViewModel.settings.fastActMainSphere&&centralCircles[index].isActive==false){
                                  appViewModel.activateSphereWish(id, true);
                                  widget.circles.where((element) => element.id==id).firstOrNull?.isActive=true;
                                  centralCircles.firstOrNull?.isActive=true;
                                  appViewModel.mainCircles = centralCircles;
                                  setState(() { });
                                }else {
                                  appViewModel.cachedImages.clear();
                                  appViewModel.startMainsphereeditScreen();
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToMainSphereEditScreenEvent());
                                }
                              }else if(parentId==0){
                                if(appViewModel.settings.fastActSphere&&centralCircles[index].isActive==false){
                                  appViewModel.activateSphereWish(id, true);
                                  centralCircles.forEach((element) {element.isActive=true;});
                                  appViewModel.mainCircles = centralCircles;
                                  setState(() { });
                                }else {
                                  appViewModel.cachedImages.clear();
                                  appViewModel.wishScreenState = null;
                                  appViewModel.startWishScreen(
                                      centralCircles[index].id, 0, false);
                                  appViewModel.mainCircles = centralCircles;
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToWishScreenEvent());
                                };
                              }else if(parentId!=0){
                                if(centralCircles[index].isActive==false&&centralCircles[index].isChecked==false&&appViewModel.settings.fastActWish&&(centralCircles[centralCircles.length-2].isActive==true||(appViewModel.mainScreenState!.allCircles.firstWhereOrNull((element) => element.id==parentId)?.parenId==0&&appViewModel.settings.sphereActualizingMode==1)||(appViewModel.settings.wishActualizingMode==1&&appViewModel.isParentSphereActive(id))||(appViewModel.settings.sphereActualizingMode==1&&appViewModel.settings.wishActualizingMode==1))){
                                  appViewModel.activateSphereWish(id, true);
                                  widget.circles.where((element) => element.id==id).firstOrNull?.isActive=true;
                                  centralCircles.forEach((element) {element.isActive=true;});
                                  appViewModel.mainCircles = centralCircles;
                                  setState(() { });
                                }else {
                                  appViewModel.cachedImages.clear();
                                  appViewModel.wishScreenState = null;
                                  appViewModel.startWishScreen(
                                      centralCircles[index].id, 0, false);
                                  appViewModel.mainCircles = centralCircles;
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigateToWishScreenEvent());
                                }
                              }
                            }
                        },
                        onTap: () {
                          print("oncentralcircletap - $allowClick");
                          if(allowClick) {
                            print("allow stat change false - central circle tap");
                            allowClick = false;
                            if (centralCircles.length - 1 != index) {
                              animationDirectionForward = false;
                              widget.circles = vm?.openSphere(value.id) ?? [];
                              circleRotations.clear();
                              circlePositions.clear();
                              plusesPositions.clear();
                              plusesRotations.clear();
                              final angleBetween = 2 * pi /
                                  widget.circles.length;
                              for (int i = 0; i < widget.circles.length; i++) {
                                widget.circles[i].radius =
                                    (widget.size * 0.2).toInt();
                                final x = widget.center.key - 40 +
                                    (widget.size - widget.circles[i].radius) /
                                        2 *
                                        cos(2 * pi * i / widget.circles.length);
                                final y = widget.center.value - 40 +
                                    (widget.size - widget.circles[i].radius) /
                                        2 *
                                        sin(2 * pi * i / widget.circles.length);
                                circlePositions.add(Offset(x, y));
                                circleRotations.add(
                                    2 * pi * i / widget.circles.length);
                                final px = widget.center.key - 40 +
                                    (widget.size - widget.circles[i].radius) /
                                        2 *
                                        cos((2 * pi * i /
                                            widget.circles.length) +
                                            angleBetween / 2);
                                final py = widget.center.value - 40 +
                                    (widget.size - widget.circles[i].radius) /
                                        2 *
                                        sin((2 * pi * i /
                                            widget.circles.length) +
                                            angleBetween / 2);
                                plusesPositions.add(Offset(px, py));
                                plusesRotations.add(
                                    (2 * pi * i / widget.circles.length) +
                                        angleBetween / 2);
                              }
                              initAnim(centralCircles.last.id,
                                  widget.circles.indexWhere((element) =>
                                  element
                                      .id == centralCircles.last.id));
                              movingController.reset();
                              movingController.forward();
                            } else if (centralCircles[index].id == 0) {
                              appViewModel.cachedImages.clear();
                              appViewModel.startMainsphereeditScreen();
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToMainSphereEditScreenEvent());
                            } else {
                              appViewModel.cachedImages.clear();
                              appViewModel.wishScreenState = null;
                              appViewModel.startWishScreen(
                                  centralCircles[index].id, 0, false);
                              appViewModel.mainCircles = centralCircles;
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigateToWishScreenEvent());
                            }
                          }
                        },
                      )
                  );
                }).toList()
              ],
            );
          },
        )
    );
  }
  void stateSnapshot(){
    vm?.mainCircles = centralCircles;
  }

  void _updateCircleRotation(double newRotation, double size, Pair center, double radius, {bool isAnim = false}) {
    print("invoked update rotation");

    final centerX = widget.center.key-40;
    final centerY = widget.center.value-40;
    final radiusminusforty = (radius-40);
    final offset = widget.circles.isNotEmpty?(80-widget.circles.first.radius)/2:0;
    for (int i = 0; i < widget.circles.length; i++) {

      // Вычисляем новый угол поворота, учитывая старый угол и новый угол
      circleRotations[i] = (circleRotations[i] + newRotation);
      plusesRotations[i] = (plusesRotations[i] + newRotation);

      // Вычисляем новые координаты на основе нового угла поворота, радиуса и центральных координат
      final newX = (centerX + radiusminusforty * cos(circleRotations[i]))+offset;
      final newY = (centerY + radiusminusforty * sin(circleRotations[i]))+offset;
      final newPlusX = centerX + radiusminusforty * cos(plusesRotations[i]);
      final newPlusY = centerY + radiusminusforty * sin(plusesRotations[i]);

      // Обновляем позицию каждой окружности и угол поворота
      circlePositions[i] = Offset(newX, newY);
      if(centralCircles.isNotEmpty&&!centralCircles.last.isChecked)plusesPositions[i] = Offset(newPlusX, newPlusY);
    }

    //var diametr = (widget.size*0.2).toInt();
    if(widget.circles.length>8){
      for(int i = 0; i < widget.circles.length; i++){
        //if (circleRotations[i]%(2*pi) >= pi && circleRotations[i]%(2*pi) <= 2*pi){widget.circles[i].radius=diametr-(diametr/3.7*(cos(circleRotations[i]))).toInt().abs();}
        /*else*/widget.circles[i].radius=(widget.size*0.15).toInt();
      }
    }
    // Вызываем setState, чтобы обновить виджет
    if(!isAnim)setState(() {});
  }

}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final start = Offset(0, size.height);
    final end = Offset(size.width, 0);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

