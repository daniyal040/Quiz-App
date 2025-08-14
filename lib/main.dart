import 'dart:async';
import 'package:flutter/material.dart';
import 'quiz_brain.dart';

QuizBrain quizBrain = QuizBrain();

void main() => runApp(Quizzler());

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Icon> scoreKeeper = [];
  int userScore = 0;
  int timeLeft = 15;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    quizBrain.shuffleQuestions(); // shuffle once at start
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 15;

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          t.cancel();
          checkAnswer(null);
        }
      });
    });
  }

  void checkAnswer(bool? userPickedAnswer) {
    bool correctAnswer = quizBrain.getCorrectAnswer(0);
    timer?.cancel();

    setState(() {
      if (userPickedAnswer == null) {
        scoreKeeper.add(Icon(Icons.timer_off, color: Colors.yellow));
      } else if (userPickedAnswer == correctAnswer) {
        userScore++;
        scoreKeeper.add(Icon(Icons.check, color: Colors.green));
      } else {
        scoreKeeper.add(Icon(Icons.close, color: Colors.red));
      }

      if (quizBrain.getCurrentQuestionNumber() <
          quizBrain.questionBank.length - 1) {
        quizBrain.nextQuestion();
        startTimer();
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Quiz Finished'),
            content: Text(
                'Your score is $userScore / ${quizBrain.questionBank.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    quizBrain.reset();
                    scoreKeeper.clear();
                    userScore = 0;
                    startTimer();
                  });
                },
                child: Text('Restart'),
              ),
            ],
          ),
        );
      }
    });
  }

  double getProgress() {
    return (quizBrain.getCurrentQuestionNumber() + 1) /
        quizBrain.questionBank.length;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(
          value: getProgress(),
          backgroundColor: Colors.white24,
          color: Colors.lightBlueAccent,
          minHeight: 8,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $userScore / ${quizBrain.questionBank.length}',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              Text(
                'Time Left: $timeLeft',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                quizBrain.getQuestionText(0),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                'True',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () {
                checkAnswer(true);
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'False',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: () {
                checkAnswer(false);
              },
            ),
          ),
        ),
        Row(children: scoreKeeper),
      ],
    );
  }
}
