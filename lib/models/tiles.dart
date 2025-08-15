import 'package:flutter/material.dart';

class Tiles {
  final int x;
  final int y;
  int value;
  
  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<double> animatedValue;
  late Animation<double> scale;

  
  Tiles(this.x, this.y, this.value){
    resetAnimations();
  }
  
  void resetAnimations(){
    animatedX = AlwaysStoppedAnimation(x.toDouble());
    animatedY = AlwaysStoppedAnimation(y.toDouble());
    animatedValue = AlwaysStoppedAnimation(value.toDouble());
    scale = AlwaysStoppedAnimation(1.0);
  }

  appear(AnimationController controller) {}
  
 void moveTo(Animation<double> parent, int newX, int newY) {
  final curved = CurvedAnimation(parent: parent, curve: Curves.easeInOut);

  animatedX = Tween<double>(
    begin: x.toDouble(),
    end: newX.toDouble(),
  ).animate(curved);

  animatedY = Tween<double>(
    begin: y.toDouble(),
    end: newY.toDouble(),
  ).animate(curved);
}

 
}