import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int squaresPerRow = 20;
  final int squaresPerCol = 20;
  final squareSize = 20.0;
  final textStyle = const TextStyle(fontSize: 24);
  final snakeColor = Colors.green;
  final foodColor = Colors.red;

  List<int> snake = [45, 65, 85, 105];
  int food = 320;
  String direction = "up";
  bool isPlaying = false;
  late Timer _timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    generateNewFood();
  }

  void generateNewFood() {
    final random = Random();
    food = random.nextInt(squaresPerRow * squaresPerCol);

    while (snake.contains(food)) {
      food = random.nextInt(squaresPerRow * squaresPerCol);
    }
  }

  void startGame() {
    isPlaying = true;
    snake = [45, 65, 85, 105];
    direction = "up";
    score = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      moveSnake();
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case "left":
          if (snake.last % squaresPerRow > 0) {
            snake.add(snake.last - 1);
          }
          break;
        case "right":
          if ((snake.last + 1) % squaresPerRow > 0) {
            snake.add(snake.last + 1);
          }
          break;
        case "up":
          if (snake.last - squaresPerRow >= 0) {
            snake.add(snake.last - squaresPerRow);
          }
          break;
        case "down":
          if (snake.last + squaresPerRow < (squaresPerRow * squaresPerCol)) {
            snake.add(snake.last + squaresPerRow);
          }
          break;
        default:
      }
      if (snake.last == food) {
        score += 10;
        generateNewFood();
      } else {
        snake.removeAt(0);
      }
      if (checkForGameOver()) {
        _timer.cancel();
        isPlaying = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Game Over'),
              content: Text("Score: $score"),
              actions: [
                TextButton(
                  child: const Text('Restart'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  bool checkForGameOver() {
    var snakeFullBody = List<int>.from(snake.getRange(0, snake.length - 1));
    return snakeFullBody.contains(snake.last);
  }

  void changeDirection(String newDirection) {
    if (direction == "up" && newDirection == "down" ||
        direction == "down" && newDirection == "up" ||
        direction == "left" && newDirection == "right" ||
        direction == "right" && newDirection == "left") {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != "up" && details.delta.dy > 0) {
                  changeDirection("down");
                } else if (direction != "down" && details.delta.dy < 0) {
                  changeDirection("up");
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != "left" && details.delta.dx > 0) {
                  changeDirection("right");
                } else if (direction != "right" && details.delta.dx < 0) {
                  changeDirection("left");
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: squaresPerRow * squaresPerCol,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: squaresPerRow,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (snake.contains(index)) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: snakeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else if (index == food) {
                      return Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: foodColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Score: $score", style: textStyle),
                if (!isPlaying)
                  ElevatedButton(
                    onPressed: () {
                      startGame();
                    },
                    child: const Text("Start"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
