import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tile2048/const/colors.dart';
import 'package:tile2048/models/tiles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: '2048',
      home: TwentyFortyEight(),

    );
  }
}

class TwentyFortyEight extends StatefulWidget {
  @override
  TwentyFortyEightState createState() => TwentyFortyEightState();
}

class TwentyFortyEightState extends State<TwentyFortyEight> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  List<List<Tiles>> grid = 
    List.generate(4, (y) => List.generate(4, (x) => Tiles(x, y, 0)));
  Iterable<Tiles> get flattenedGrid => grid.expand((e) => e);
  Iterable<List<Tiles>> get cols => 
  List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));


  @override
  void initState(){
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    grid[1][2].value = 4;
    grid[3][2].value = 16;

    flattenedGrid.forEach((element) => element.resetAnimations());
  }
    
  
  @override
  Widget build(BuildContext context){
    double gridsize = MediaQuery.of(context).size.width - 16 *2;
    double tileSize = (gridsize - 4.0*2)/4;
    List<Widget> stackItems = [];
    stackItems.addAll(flattenedGrid.map((e) => Positioned(
      left: e.x * tileSize,
      top: e.y *tileSize,
      width: tileSize,
      height: tileSize,
      child: Center(
          child: Container(
        width: tileSize - 4.0 * 2,
        height: tileSize -4.0 *2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: lightBrown),
        )),
    )));

      stackItems.addAll(flattenedGrid.map((e) => AnimatedBuilder(
        animation: controller, 
        builder:(context, child) => e.animatedValue.value == 0 
        ? SizedBox()
        : Positioned(
            left: e.x * tileSize,
            top: e.y *tileSize,
            width: tileSize,
            height: tileSize,
            child: Center(
                child: Container(
              width: tileSize - 4.0 * 2,
              height: tileSize -4.0 *2,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: numTileColor[e.animatedValue.value]),
            child: Center(
              child: Text('${e.animatedValue.value.round()}', 
              style: TextStyle(
              color:  e.animatedValue.value <= 4
                ?greyText
                : Colors.white,
              fontSize: 35, 
              fontWeight: FontWeight.w900
            ))
        )),
    )))));

    return Scaffold(
      backgroundColor: tan,
      body: Center(
        child: Container (
        width: gridsize,
        height: gridsize,
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: darkBrown,
        ),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            double velocityY = details.velocity.pixelsPerSecond.dy;
            if (velocityY < -250 && canSwipeUp()){
              doSwipe(swipeUp);
            } else if(velocityY >  250 && canSwipeDown()){
              //swipe down
            }
          },
          onHorizontalDragEnd: (details){
            double velocityX = details.velocity.pixelsPerSecond.dx;
            if (velocityX < -1000 && canSwipeLeft()){
              //swipe l3r5
            } else if(velocityX > 1000 && canSwipeRight()){
              //swipe right
            }
          },
          child: Stack(
          children: stackItems,
        )
      )
      )

    ));
  }

  void doSwipe(void Function() swipeFn){
    setState((){
      swipeFn();
      // new tile addded
      controller.forward (from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipeUp() => cols.any(canSwipe);
  bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tiles> tiles){
    for (int i = 0; i < tiles.length; i++){
      if(tiles.skip(i+1).any((e) => e.value != 0)){
        return true;
      }
      else{
        
       Tiles nextNonZero = tiles.skip(i + 1)
         .firstWhere(
          (element) => element.value != 0,
        orElse: () => Tiles(-1, -1, -1), // dummy tile
         );

        if (nextNonZero.value != -1 && nextNonZero.value == tiles[i].value) {
          return true;
        }
      }
    }
    return false;

  }
  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
  void swipeUp() => cols.forEach(mergeTiles);
  void swipeDown() => cols.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tiles> tiles){
    for(int i=0; i < tiles.length; i++){
      Iterable<Tiles> toCheck=
      tiles.skip(i).skipWhile((value) => value.value == 0);
      if (toCheck.isNotEmpty){
        Tiles t = toCheck.first;
        Tiles merge = toCheck.skip(1).firstWhere((t) => t.value != 0, orElse: () => Tiles (-1, -1, -1));
          if (merge != (-1, -1, -1));
      }
    }
  } 
}