import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class RepaintBoundaryPage extends StatefulWidget {
  @override
  _RepaintBoundaryPageState createState() => _RepaintBoundaryPageState();
}

class _RepaintBoundaryPageState extends State<RepaintBoundaryPage> {
  StreamController _oneStreamController = StreamController();
  StreamController _twoStreamController = StreamController();
  StreamController _threeStreamController = StreamController();
  StreamController _bottomStreamController = StreamController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              _oneStreamController.add(0);
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                'repaint one',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _twoStreamController.add(0);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: Colors.white,
              child: Text(
                'two',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _threeStreamController.add(0);
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                'three',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _bottomStreamController.add(0);
            },
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Text(
                'bottom',
                style: TextStyle(fontSize: 11, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: RepaintBoundary(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: _bottomStreamController.stream,
            builder: (_, __) {
              return CustomPaint(
                painter: MyPainter(),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    RepaintBoundary(
                      child: Container(
                        height: 100,
                        width: BoxConstraints.expand().maxWidth,
                        child: StreamBuilder(
                          stream: _oneStreamController.stream,
                          builder: (_, __) {
                            return CustomPaint(
                              painter: MyPainter(),
                              child: Center(
                                child: Text(
                                  'one RepaintBoundart',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    RepaintBoundary(
                      child: Container(
                        height: 100,
                        width: BoxConstraints.expand().maxWidth,
                        child: StreamBuilder(
                          stream: _twoStreamController.stream,
                          builder: (_, __) {
                            return CustomPaint(
                              painter: MyPainter(),
                              child: Center(
                                child: Text(
                                  'two RepaintBoundart',
                                  style: TextStyle(fontSize: 30),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 100,
                      width: BoxConstraints.expand().maxWidth,
                      child: StreamBuilder(
                        stream: _threeStreamController.stream,
                        builder: (_, __) {
                          return CustomPaint(
                            painter: MyPainter(),
                            child: Center(
                              child: Text(
                                'three without RepaintBoundart',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    Text(
                      'bottom RepaintBoundart',
                      style: TextStyle(fontSize: 30),
                    ),
                    Spacer(),
                  ],
                ),
              );
            },
          ),
        )),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  paint(Canvas canvas, Size size) {
    Random random = Random();
    Color color = Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 1);
    Paint paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
