// Ashley Adji
/* 
Final Project: 
An app that helps someone solve their first rubix cube start to finish. 
Uses a "flashcard" like style to teach you the notation and 
sequences of moves to make at certain sections.

Features:
- Multiple Routes (Notation and Move mode)
- Custom rubix cube images
- "Move" buttons that interact
- Timer for speed challenges
*/

import 'package:flutter/material.dart'; 
import "package:flutter_bloc/flutter_bloc.dart"; // for cubits information
import "dart:async";

import "notation_mode.dart";
import "moves_mode.dart";

void main() {
  runApp(const RubixBuddy());
}

/*
RubixBuddy
- initialize nested cubits (notation, move, timer)
- theme data to apply Pixel font everywhere
 */
class RubixBuddy extends StatelessWidget {
  const RubixBuddy({super.key});

 @override
  Widget build(BuildContext context) {
    return BlocProvider<NotationCubit>(
      create: (_) => NotationCubit()..init(), //create notation cubit
      child: BlocProvider<MoveCubit>(
        create: (_) => MoveCubit()..init(), //create move cubit
          child: BlocProvider<TimerCubit>( 
            create: (_) => TimerCubit(), // create timer cubit
             child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Rubix Buddy App',
              theme: ThemeData(
              fontFamily: 'PixelFont',
              scaffoldBackgroundColor: Colors.white,),
              home: const RubixBuddyHome(),
            ),
          ) // create timer cubit
        ) //create move cubit
      ); //create notation cubit
  } //build
} //rubixbuddy

/*
RubixBuddyHome
- Info screen to explain cube layout
- Home screen to select mode
 */
class RubixBuddyHome extends StatelessWidget {
  const RubixBuddyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), //make margins
              child: Text(
                "Welcome to RubixBuddy! This tool teaches you the notation and moves you need to solve a Rubix Cube using the beginner's method.",
                textAlign: TextAlign.center,
                ),
            ),

            Image.asset("assets/move_G.png", width: 100, height: 100),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), //make margins
              child: Text("When referencing the diagrams, keep in mind that the pink side is the one facing the user, and the red arrow is how you should rotate the cube.",
              textAlign: TextAlign.center,),
              ),

            Row( //Button Row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  ElevatedButton(
                  onPressed: () { // when you press the notation button, you go to the Notation mode Route
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RubixBuddyNotation()),
                    );
                  },
                    child: SizedBox(
                      width: 300,
                      height: 200,
                      child: 
                      Center(
                       child: Column(
                        children: [
                          Image.asset("assets/notation_image.png",width: 150,height: 150),
                          Text("Notation", style: const TextStyle(fontSize: 30)),
                        ],
                      )
                    )
                  )
                  ), // NOTATION BUTTON,
                  ],
                ),
                Column( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  ElevatedButton( // When you press the "Move" button, you go to the Moves mode page
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RubixBuddyMoves()),
                    );
                  },
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: 
                    Center(
                      child:
                      Column(
                        children: [
                          Image.asset("assets/moves_image.png",width: 150,height: 150),
                          Text("Moves", style: const TextStyle(fontSize: 30)),
                        ],
                      )
                    )
                  )
                ), // MOVES BUTTON
              ],
              ),
              ] // row children
            ),
          ],
        )
    );
  }
}

class TimerState{
  final int seconds;
  final bool isActive;

  TimerState(this.seconds, this.isActive);
}

class TimerCubit extends Cubit<TimerState> {
  TimerCubit() : super(TimerState(60, false));

  Timer? _timer;

  static const int maxTime = 60;

 void startTimer() { // start the timer at 60 seconds
  _timer?.cancel(); //clear any existing timers

  emit(TimerState(maxTime, true));  //changes seconds to 60

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (state.seconds <= 0) {
      stopTimer();
      return;
    }

    emit(TimerState(state.seconds - 1, true)); // after start, count down from 60 until stopped
  });
}

  void stopTimer() { // stop the timer by turning isActive to false
    _timer?.cancel();
    emit(TimerState(state.seconds, false));
  }

  void resetTimer() { // reset the timer to 60 and turn isActive to false
    _timer?.cancel();
    emit(TimerState(maxTime, false));
  }
}

/*
Notation mode
Given a notation ("U"), press the corresponding move button
 */
class RubixBuddyNotation extends StatelessWidget {
  const RubixBuddyNotation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotationCubit, NotationState>(
      builder: (context, state) {
        final ncubit = context.read<NotationCubit>();
        final tcubit = context.read<TimerCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Notation"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ncubit.state.currentPrompt,
                style: const TextStyle(fontSize: 30),
              ),

              Text("Score: ${ncubit.state.notationScore}"),

              BlocBuilder<TimerCubit, TimerState>(
                builder: (context, tstate) { //Format the timer display
                  String formatTime(int seconds) {
                    final mins =
                        (seconds ~/ 60).toString().padLeft(2, '0');
                    final secs =
                        (seconds % 60).toString().padLeft(2, '0');
                    return "$mins:$secs";
                  }

                  const endTime = 60;

                  double progress = tstate.seconds / endTime;

                  Color barColor = // change color as time progresses
                    progress > 0.5
                    ? Colors.green
                    : progress > 0.2
                    ? Colors.orange
                    : Colors.red;

                  if (tstate.seconds == 0 && tstate.isActive) { // stop timer if time runs out
                    Future.microtask(() {
                      tcubit.stopTimer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Time's up!")),
                      );
                    });
                  }

                  return Column(
                    children: [
                      Text(
                        "Time: ${formatTime(tstate.seconds)}",
                        style: const TextStyle(fontSize: 25),
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        color: barColor,
                        backgroundColor: Colors.grey[300],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Non-Prime"),
                  Switch(
                    value: ncubit.state.primes,
                    onChanged: (_) {
                      ncubit.togglePrime();
                    },
                  ),
                  const Text("Prime"),

                ElevatedButton(
                onPressed: () {
                  tcubit.startTimer();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
                child: const Text("START"),
              ),

                  ElevatedButton(
                    onPressed: () {
                      tcubit.stopTimer();
                    },
                    style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
                    child: const Text("STOP"),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      tcubit.resetTimer();
                    },
                    style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
                    child: const Text("RESET"),
              ),
                ],
              ),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 6,
                  children:
                      ncubit.state.notationkey.entries.map((entry) { //since notation key is a map, generate buttons by cycling through the map
                    return InkWell( //Inkwell allows for interactive button clicking
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        ncubit.checkNotationAnswer(entry.value); 
                        //the value of the map is the corresponding notation ("U")
                        //pass value into the checkNotationAnswer function

                        final isCorrect = ncubit.state.lastAnswerCorrect;

                        // Give user feedback and a picture of the right answer with the SnackBar popup
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: 
                            Row(
                              children: [ 
                              Image.asset("assets/${ncubit.state.notationkey[ncubit.state.currentPrompt]}", width: 100, height: 100,),
                              Text(
                                isCorrect
                                  ? "Correct!"
                                  : "Incorrect!",
                                ),
                            ],
                            ),
                            backgroundColor: isCorrect
                                ? Colors.green
                                : Colors.red,
                            duration:
                                const Duration(milliseconds: 600),
                          ),
                        );

                        ncubit.nextNotationQuestion(); //Move on to the next notation prompt
                      },
                      child: Ink( //Images that show on the buttons
                        child: Image.asset(
                          'assets/${entry.value}',
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RubixBuddyMoves extends StatelessWidget {
  const RubixBuddyMoves({super.key});

  @override
  Widget build(BuildContext context) {

  // list of moveButtons to build, when you click on one it adds notation to the list
  final moveButtons = [
  {"move": "U", "img": "move_U.png"},
  {"move": "U'", "img": "move_Uprime.png"},
  {"move": "D", "img": "move_D.png"},
  {"move": "D'", "img": "move_Dprime.png"},
  {"move": "L", "img": "move_L.png"},
  {"move": "L'", "img": "move_Lprime.png"},
  {"move": "R", "img": "move_R.png"},
  {"move": "R'", "img": "move_Rprime.png"},
  {"move": "F", "img": "move_F.png"},
  {"move": "F'", "img": "move_Fprime.png"},
  {"move": "B", "img": "move_B.png"},
  {"move": "B'", "img": "move_Bprime.png"},
  ];
    
    return BlocBuilder<MoveCubit, MoveState>(
      builder: (context, state) {
      MoveCubit mcubit = context.read<MoveCubit>();

      if (state.currentMovekey.isEmpty) { //if not loaded yet
        return const Center(child: CircularProgressIndicator());
      }

      return Scaffold(
      appBar: AppBar(
      title: const Text("Moves"),
    ),
      body: 
        Column(
          mainAxisAlignment: .center,
          children: [

            Text("Score: ${mcubit.state.moveScore}" ),
            Row(
              mainAxisAlignment: .center,
              children: [
                Image.asset('assets/${mcubit.state.currentMovekey[0]}', width:150,height: 150,),
                Image.asset('assets/${mcubit.state.currentMovekey[1]}', width:150,height: 150,),
                Image.asset('assets/${mcubit.state.currentMovekey[2]}', width:150,height: 150,),
              ],
            ),
          
          Wrap(
            children: mcubit.state.userMoves.map((m) => Chip(label: Text(m))).toList(),
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 6,
              children: moveButtons.map((btn) {
                return MoveButton(
                  btn["img"]!,
                  btn["move"]!,
                );
              }).toList(),
            ),
          ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [

    // CHECK BUTTON
    SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          mcubit.checkmoveAnswer(mcubit.state.userMoves.toString());

          final isCorrect = mcubit.state.lastAnswerCorrect;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCorrect ? "Correct!" : "Try again"),
              backgroundColor: isCorrect ? Colors.green : Colors.red,
              duration: const Duration(milliseconds: 300),
            ),
          );

          mcubit.nextMoveQuestion();
        },
        child: const Text("CHECK"),
      ),
    ),

    // UNDO BUTTON
    SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          mcubit.undoMove();
        },
        child: const Text("UNDO"),
      ),
    ),

    // ROTATE LEFT
    SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          mcubit.addMove("CL");
        },
        child: const Text("ROTATE CUBE LEFT"),
      ),
    ),

    // ROTATE RIGHT
    SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          mcubit.addMove("CR");
        },
        child: const Text("ROTATE CUBE RIGHT"),
      ),
    ),

  ],
),
          
            ],
        )
        ]
      )
      );
      }
    );
  }
}

class MoveButton extends StatelessWidget{

  final String filename; //image of move that displays button
  final String move; //the move corresponding with image (ex: R, U, U')

  const MoveButton(this.filename, this.move, {super.key});
  
  @override
  Widget build (BuildContext context){
    MoveCubit mcubit = BlocProvider.of<MoveCubit>(context); 
    return InkWell(
      onTap: (){
        mcubit.addMove(move);
      }, // onTap
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          'assets/$filename',
          width: 60, height: 60,
      ),
      )
    );
  } // build
} // MoveButton
