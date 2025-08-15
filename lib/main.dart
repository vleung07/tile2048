import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tile2048/const/colors.dart';
import 'package:tile2048/models/tiles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: '2048',
      home: TwentyFortyEight(),

    );
  }
}

class TwentyFortyEight extends StatefulWidget {
  const TwentyFortyEight({super.key});

  @override
  TwentyFortyEightState createState() => TwentyFortyEightState();
}

class TwentyFortyEightState extends State<TwentyFortyEight> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  List<List<Tiles>> grid = 
    List.generate(4, (y) => List.generate(4, (x) => Tiles(x, y, 0)));
    List <Tiles> toAdd =[];
  Iterable<Tiles> get flattenedGrid => grid.expand((e) => e);
  Iterable<List<Tiles>> get cols => 
  List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));


  @override
  void initState(){
    super.initState();
    controller = 
      AnimationController(vsync: this, duration: Duration(milliseconds: 200));
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed){
          toAdd.forEach((e) {grid[e.y][e.x].value = e.value;}); 
       flattenedGrid.forEach((e)
        {e.resetAnimations();});
        toAdd.clear();
      }});

    grid[1][2].value = 4;

    grid[0][2].value = 4;
    grid [0][0].value=16;
    grid[3][2].value = 16;

    for (var element in flattenedGrid) {
      element.resetAnimations();
    }
  }



void addNewTile() {
  // Find all empty tiles
  List<Tiles> empty = flattenedGrid.where((e) => e.value == 0).toList();

  // If no empty tiles, exit early
  if (empty.isEmpty) {
    print("No empty tiles available.");
    return;
  }

  // Shuffle to randomize placement
  empty.shuffle();

  // Randomly choose between 2 and 4
  int value = Random().nextBool() ? 2 : 4;

  // Get the first empty tile safely
  Tiles? target = empty.first;

  if (target == null) {
    print("Unexpected null tile.");
    return;
  }

  // Create and animate the new tile
  Tiles newTile = Tiles(target.x, target.y, value);
  // Add to the list of tiles to be rendered
  toAdd.add(newTile);

  // Optional: Debug log
  print("Added tile with value $value at (${target.x}, ${target.y})");
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
              doSwipe(swipeDown);
            }
          },
          onHorizontalDragEnd: (details){
            double velocityX = details.velocity.pixelsPerSecond.dx;
            if (velocityX < -250 && canSwipeLeft()){
              doSwipe(swipeLeft);
            } else if(velocityX > 250 && canSwipeRight()){
              doSwipe(swipeRight);
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
      addNewTile();
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
        Tiles? merge = toCheck.skip(1).firstWhere((t) => t.value != 0, orElse: () => Tiles (-1, -1, -1));
          if (merge.x == -1 && merge.y == -1 && merge.value == -1) {
            merge = null;
            }
          if (tiles[i] != t || merge != null){
            int resultValue =  t.value;
            t.moveTo(controller, tiles[i].x, tiles[i].y);
            if  ((tiles[i] != t || merge != null) && merge != null && t.value == merge.value) {
              resultValue += merge.value;
              merge.moveTo(controller, tiles[i].x, tiles[i].y); 
              merge.value=0;
            }
            t.value=0;
            //tiles[i] = Tiles(tiles[i].x, tiles[i].y, resultValue);

            // if (merge != null) {
            //   merge.x = tiles[i].x;
            //   merge.y = tiles[i].y;
            // }

            tiles[i].value = resultValue;
            tiles[i].animatedValue = AlwaysStoppedAnimation(resultValue.toDouble());

          }
      }
      
    }
  } 
}