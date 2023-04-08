// import 'dart:js';
import 'dart:math';
// import 'package:path/path.dart';
import 'package:flutter/material.dart';

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>(List<BrickObjectPos>.from([]));
//provide access to otrher objects
  GlobalKey<_TetrisWidgetState> keyGlobal = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double sizePerSquare = 40;
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
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Colors.red[900]!,
                                            ),
                                          ),
                                          onPressed: () {
                                            print("Reset"); //not in production
                                          },
                                          child: Text("Score: ${null ?? 0}"),
                                        ),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateColor.resolveWith(
                                              (states) => Colors.red[900]!,
                                            ),
                                          ),
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
                      //Set Tetris widget here
                      child: LayoutBuilder(builder: (context, constraints) {
                        return TetrisWidget(
                            //sent size
                            constraints.biggest,
                            key: keyGlobal,
                            sizePerSquare: sizePerSquare, //size per box brick
                            //Make callback for next brick show after generate on widget
                            setNextBrick:
                                (List<BrickObjectPos> brickObjectPos) {
                          brickObjectPosValue.value = brickObjectPos;
                          //Notify the client when the object may have change
                          brickObjectPosValue.notifyListeners();
                        });
                      }),
                    ))
                  ],
                );
              },
            ),
          )),
    );
  }
}

class TetrisWidget extends StatefulWidget {
  // const TetrisWidget(Size biggest, {super.key, required Null Function(List<BrickObjectPos> brickObjectPos) setNextBrick});
  final Size size;
  final double? sizePerSquare;
  Function(List<BrickObjectPos> brickObjectPos)? setNextBrick;

  TetrisWidget(this.size, {Key? key, this.setNextBrick, this.sizePerSquare})
      : super(key: key);

  @override
  State<TetrisWidget> createState() => _TetrisWidgetState();
}

class _TetrisWidgetState extends State<TetrisWidget>
    with SingleTickerProviderStateMixin {
  //set animation & controller animation
  late Animation<double> animation;
  late AnimationController animationController;

  //declare all parameter
  late Size sizeBox;

//all brick generated will saved here
  ValueNotifier<List<BrickObjectPos>> brickObjectPosValue =
      ValueNotifier<List<BrickObjectPos>>([]);

  //for point alredy done
  ValueNotifier<List<BrickObjectPosDone>> donePointsValue =
      ValueNotifier<List<BrickObjectPosDone>>([]);

//our index point array for base or walls
  late List<int> levelBases;
  ValueNotifier<int> animationPosTickValue = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    //calculatesize box base size box tetris
    calculateSizeBox();

    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    //begin & end property
    animation = Tween<double>(begin: 0, end: 1).animate(animationController)
      ..addListener(animationLoop);

    animationController.forward();
  }

  calculateSizeBox() {
    //sizebox to calculate overall size wich needed for our tetris take place
    sizeBox = Size(
      (widget.size.width ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
      (widget.size.height ~/ widget.sizePerSquare!) * widget.sizePerSquare!,
    );

    //calculate bases level in game
    //this one calculate bottom level
    levelBases = List.generate(sizeBox.width ~/ widget.sizePerSquare!, (index) {
      return (((sizeBox.height ~/ widget.sizePerSquare!) - 1) *
              (sizeBox.width ~/ widget.sizePerSquare!)) +
          index;
    });

    //calculate left base wall
    levelBases
        .addAll(List.generate(sizeBox.height ~/ widget.sizePerSquare!, (index) {
      return index * (sizeBox.width ~/ widget.sizePerSquare!);
    }));
  }

  pauseGame() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
              children: [
                const Text("Pause Game"),
                ElevatedButton(onPressed: () {}, child: const Text("Resume"))
              ],
            ));
  }

  resetGame() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SimpleDialog(
              children: [
                Text("Reset Game"),
                ElevatedButton(
                    onPressed: () {
                      donePointsValue.value = [];
                      donePointsValue.notifyListeners();
                      brickObjectPosValue.value = [];
                      brickObjectPosValue.notifyListeners();
                      Navigator.of(context).pop();
                    },
                    child: Text("Reset"))
              ],
            ));
  }

  animationLoop() {
    //check brick length more that 1 for ready current & future brick
    if (animation.isCompleted && brickObjectPosValue.value.length > 1) {
      print("nice run ");
      animationController.reset();
      animationController.forward();
    } else {
      // randomBrick(start: true);
    }
  }

  randomBrick({
    start = false,
  }) {
    //start true means to generate 2 random brick, if false we just generate one on time
    brickObjectPosValue.value.add(getNewBrickPos());

    if (start) {
      brickObjectPosValue.value.add(getNewBrickPos());
    }
    widget.setNextBrick!.call(brickObjectPosValue.value);
    brickObjectPosValue.notifyListeners();
  }

  BrickObjectPos getNewBrickPos() {
    return BrickObjectPos(
      size: Size.square(widget.sizePerSquare!),
      sizeLayout: sizeBox,
      color:
          Colors.primaries[Random().nextInt(Colors.primaries.length)].shade800,
      rotation: Random().nextInt(4),
      offset: Offset(widget.sizePerSquare! * 4, -widget.sizePerSquare! * 3),
      shapeEnum:
          BrickShapeEnum.values[Random().nextInt(BrickShapeEnum.values.length)],
    );
  }

  @override
  void dispose() {
    animation.removeListener(animationLoop);
    // the object is no longer usable
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: null,
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
