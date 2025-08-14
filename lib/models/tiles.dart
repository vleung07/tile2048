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
    animatedX = AlwaysStoppedAnimation(this.x.toDouble());
    animatedY = AlwaysStoppedAnimation(this.y.toDouble());
    animatedValue = AlwaysStoppedAnimation(this.value.toDouble());
    scale = AlwaysStoppedAnimation(1.0);
  }
}