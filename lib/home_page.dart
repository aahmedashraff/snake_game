import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';

import 'blank_pixel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SnakeDirection { up, down, left, right }

class _MyHomePageState extends State<MyHomePage> {
  //grid dimensions
  int rowSize = 10;
  int totalSquareNum = 100;

  bool gameHasStarted = false;

  final _nameController = TextEditingController();
  int currentScore = 0;
  //snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  //snake direction initially to the right
  var currentDirection = SnakeDirection.right;
  //food position
  int foodPos = 55;

  //highscore list

  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;
//submit score to firebase
  void submitScore() {
    //get access to collection
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      'name': _nameController.text,
      'score': currentScore,
    });
  }

  Future newGame() async {
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = SnakeDirection.right;
      gameHasStarted = false;
      currentScore = 0;
    });
  }

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('highscores')
        .orderBy('score', descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //start the game
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(
      const Duration(milliseconds: 200),
      (timer) {
        //keep the snake moving
        setState(() {
          moveSnake();
          if (gameOver()) {
            timer.cancel();
            //display msg to the user
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Game Over'),
                    content: Column(
                      children: [
                        Text('Your Score is: $currentScore'),
                        TextField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(hintText: 'Enter Name'),
                        ),
                      ],
                    ),
                    actions: [
                      MaterialButton(
                        onPressed: () {
                          submitScore();
                          Navigator.pop(context);
                          newGame();
                        },
                        color: Colors.pink,
                        child: const Text('Submit'),
                      ),
                    ],
                  );
                });
          }
        });
        //eat the food
      },
    );
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalSquareNum);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case SnakeDirection.right:
        {
          // if snake at right wall , need to re-adjust
          //add a new head
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }

          //remove the tail
        }
        break;

      case SnakeDirection.left:
        {
          //add a new head
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
          //remove the tail
        }
        break;
      case SnakeDirection.up:
        {
          //add a new head
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalSquareNum);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
          //remove the tail
        }
        break;
      case SnakeDirection.down:
        {
          //add a new head
          if (snakePos.last + rowSize > totalSquareNum) {
            snakePos.add(snakePos.last + rowSize - totalSquareNum);
          } else {
            snakePos.add(snakePos.last + rowSize);
          } //remove the tail
        }
        break;
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
            currentDirection != SnakeDirection.up) {
          currentDirection = SnakeDirection.down;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
            currentDirection != SnakeDirection.down) {
          currentDirection = SnakeDirection.up;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
            currentDirection != SnakeDirection.right) {
          currentDirection = SnakeDirection.left;
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
            currentDirection != SnakeDirection.left) {
          currentDirection = SnakeDirection.right;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          width: screenWidth > 400 ? 430 : screenWidth,
          child: Expanded(
            child: Column(
              children: [
                //score gird
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Current Score'),
                          Text(
                            currentScore.toString(),
                            style: const TextStyle(fontSize: 36),
                          ),
                        ],
                      ),
                      //user current score

                      //high scores
                      Expanded(
                        child: gameHasStarted
                            ? Container()
                            : FutureBuilder(
                                future: letsGetDocIds,
                                builder: (context, snapshot) {
                                  return ListView.builder(
                                    itemCount: highscore_DocIds.length,
                                    itemBuilder: (context, index) {
                                      return HighScoreTile(
                                          docId: highscore_DocIds[index]);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                //game grid
                Expanded(
                    flex: 3,
                    child: GestureDetector(
                      //moving up&down
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy > 0 &&
                            currentDirection != SnakeDirection.up) {
                          currentDirection = SnakeDirection.down;
                        } else if (details.delta.dy < 0 &&
                            currentDirection != SnakeDirection.down) {
                          currentDirection = SnakeDirection.up;
                        }
                      },
//moving left&right
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 0 &&
                            currentDirection != SnakeDirection.left) {
                          currentDirection = SnakeDirection.right;
                        } else if (details.delta.dx < 0 &&
                            currentDirection != SnakeDirection.right) {
                          currentDirection = SnakeDirection.left;
                        }
                      },
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalSquareNum,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: rowSize),
                        itemBuilder: (context, index) {
                          if (snakePos.contains(index)) {
                            return const SnakePixel();
                          } else if (foodPos == index) {
                            return const FoodPixel();
                          } else {
                            return const BlankPixel();
                          }
                        },
                      ),
                    )),
                //play button
                Expanded(
                  child: Center(
                    child: MaterialButton(
                      color: gameHasStarted ? Colors.grey : Colors.pink,
                      onPressed: gameHasStarted ? () {} : startGame,
                      child: const Text(
                        'play',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
