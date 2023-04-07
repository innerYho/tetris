import 'dart:math';

import 'package:flutter/material.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>(List<BrickObjectPos>.from([]));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.blue,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
//2 Columns 1: for action top, 2: for tetris build
                return Column(
                  children: [
                    Container(
                      //Split top 2 row
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: constraints.biggest.width / 2,
                              // color: Colors.red,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Score & line success

                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Score: ${null ?? 0}"),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Score: ${null ?? 0}"),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            print("Reset"); //not in production
                                          },
                                          child: Text("Score: ${null ?? 0}"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            print("Start"); //not in production
                                          },
                                          child: const Text("Start"),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                            Container(
                              width: constraints.biggest.width / 2,
                              color: Colors.yellowAccent,
                              child: Column(children: [
                                //Score & line success
                                const Text("Next : "),
                                //contain box show next tetris
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  child: ValueListenableBuilder(
                                    valueListenable: brickObjectPosValue,
                                    builder: (context,
                                        List<BrickObjectPos> value, child) {
                                      BrickShapeEnum tempShapeEnum =
                                          value.length > 0
                                              ? value.last.shapeEnum
                                              // Next shape
                                              // : BrickShapeEnum.Line;
                                              // : BrickShapeEnum.RLShape;
                                              : BrickShapeEnum.TShape;

                                      int rotation = value.length > 0
                                          ? value.last.rotation
                                          : 0;
                                      return BrickShape(
                                        BrickShapeStatic.getListBrickOnEnum(
                                            //check if got value take last array.. for out next brick down...
                                            tempShapeEnum,
                                            direction: rotation),
                                      );
                                    },
                                  ),
                                )
                              ]),
                            )
                          ]),
                    ),
                    Expanded(
                        child: Container(
                      width: double.maxFinite,
                      color: Colors.greenAccent,
                      child: const Text("Set Tetris widget here"),
                    ))
                  ],
                );
              },
            ),
          )),
    );
  }
}

//declare enum use for tetris brich shape
enum BrickShapeEnum { Square, LShape, RLShape, ZigZag, RZigzag, TShape, Line }

class BrickShapeStatic {
  static List<List<List<double>>> rotateLShape = [
    [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [1, 0, 0],
    ],
    [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 0],
    ],
  ];

  static List<List<List<double>>> rotateRLShape = [
    [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 0, 1],
    ],
    [
      [0, 1, 0],
      [0, 1, 0],
      [1, 1, 0],
    ],
  ];

  static List<List<List<double>>> rotateZigZag = [
    [
      [0, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 1, 0],
      [1, 1, 0],
      [1, 0, 0],
    ],
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 0, 1],
    ],
  ];

  static List<List<List<double>>> rotateRZigZag = [
    [
      [0, 0, 0],
      [0, 1, 1],
      [1, 1, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 0, 1],
    ],
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ],
    [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 0],
    ],
  ];

  static List<List<List<double>>> rotateTShape = [
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ],
    [
      [0, 1, 0],
      [0, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 0, 0],
      [1, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 1, 0],
      [1, 1, 0],
      [0, 1, 0],
    ],
  ];

  static List<List<List<double>>> rotateLine = [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
  ];

  //declare static class to get correct rotation
  static List<List<double>> getListBrickOnEnum(BrickShapeEnum shapeEnum,
      {int direction: 0}) {
    List<List<double>> shapeList;

    if (shapeEnum == BrickShapeEnum.Square) {
      shapeList = [
        [1, 1],
        [1, 1],
      ];
    } else if (shapeEnum == BrickShapeEnum.LShape) {
      shapeList = rotateLShape[direction];
    } else if (shapeEnum == BrickShapeEnum.RLShape) {
      shapeList = rotateRLShape[direction];
    } else if (shapeEnum == BrickShapeEnum.ZigZag) {
      shapeList = rotateZigZag[direction];
    } else if (shapeEnum == BrickShapeEnum.RZigzag) {
      shapeList = rotateRZigZag[direction];
    } else if (shapeEnum == BrickShapeEnum.TShape) {
      shapeList = rotateTShape[direction];
    } else if (shapeEnum == BrickShapeEnum.Line) {
      shapeList = rotateLine[direction];
    } else {
      shapeList = [];
    }
    return shapeList;
  }
}

//declare
class BrickObject {
  bool enable;
  BrickObject({this.enable = false});
}

//brick on done
class BrickObjectPosDone {
  Color? color;
  int index;

  BrickObjectPosDone(this.index, {this.color});
}

//BrickObjectPos
class BrickObjectPos {
  Offset offset;
  BrickShapeEnum shapeEnum;
  int rotation;
  bool isDone;
  Size? sizeLayout;
  Size? size;
  List<int> pointArray = [];
  Color color;

  BrickObjectPos(
      {this.size,
      this.sizeLayout,
      this.isDone = false,
      this.offset = Offset.zero,
      this.shapeEnum = BrickShapeEnum.Line,
      this.rotation = 0,
      this.color = Colors.amber}) {
    calculateHit();
  }

  setShape(BrickShapeEnum shapeEnum) {
    this.shapeEnum = shapeEnum;
    calculateHit();
  }

  calculateRotation(int flag) {
    rotation += flag;
    calculateHit();
  }

  calculateHit({Offset? predict}) {
    List<int> lists =
        BrickShapeStatic.getListBrickOnEnum(shapeEnum, direction: rotation)
            .expand((element) => element)
            .map((e) => e.toInt())
            .toList();

    List<int> tempPoint = lists
        .asMap()
        .entries //iterable
        .map((e) => calculateOffset(e, lists.length, predict ?? offset))
        .toList();

    if (predict != null) {
      return tempPoint;
    } else {
      pointArray = tempPoint;
    }
  }

  int calculateOffset(MapEntry<int, int> entry, int length, Offset offsetTemp) {
    int value = entry.value;
    if (size != null) {
      if (value == 0) {
        value = -99999;
      } else {
        double left = offsetTemp.dx / size!.width + entry.key % sqrt(length);
        double top = offsetTemp.dy / size!.height + entry.key % sqrt(length);

        int index =
            left.toInt() + (top * (sizeLayout!.width / size!.width)).toInt();

        value = (index).toInt();
      }
    }

    return value;
  }
}

class BrickShape extends StatefulWidget {
  List<List<double>> list;
  List? points;
  double sizePerSquare;
  Color? color;

  BrickShape(this.list,
      {Key? key, this.color, this.points, this.sizePerSquare: 20})
      : super(key: key);
  // const BrickShape({super.key});

  @override
  State<BrickShape> createState() => _BrickShapeState();
}

class _BrickShapeState extends State<BrickShape> {
  @override
  Widget build(BuildContext context) {
    //make the shape
    //calculate column numbre required
    int totalPointList = widget.list.expand((element) => element).length;

    int columnNum = (totalPointList ~/ widget.list.length);
    return Container(
      width: widget.sizePerSquare * columnNum,
      // color: Colors.black,
      child: GridView.builder(
        shrinkWrap: true, //return true or false
        itemCount: totalPointList,
        //make grid layout
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnNum,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return Offstage(
            offstage:
                widget.list.expand((element) => element).toList()[index] == 0,
            child: boxBrick(widget.color ?? Colors.cyan,
                text: widget.points?[index] ?? ''),
          );
        },
      ),
    );
  }
}

Widget boxBrick(Color color, {text: ""}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(width: 1),
    ),
  );
}
