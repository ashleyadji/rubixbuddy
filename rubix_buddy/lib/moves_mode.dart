import "package:flutter_bloc/flutter_bloc.dart"; // for cubit informaiton
import 'package:flutter/services.dart' show rootBundle; //for importing file information
import "dart:math"; // for randomness

class MoveState {
  Map<List<String>,String> movekey = {}; //map for move learning mode
  List<String> currentMovekey; // the current question presented to user
  String moveAnswer; // string of move sequence that is correct answer
  List<String> userMoves; // keep track of user moves using list
  int moveScore; // overall score of sequences that are correct
  bool lastAnswerCorrect; // whether or not the last answer is correct

  MoveState( 
  this.movekey,
  this.currentMovekey,
  this.moveAnswer,
  this.userMoves,
  this.moveScore,
  this.lastAnswerCorrect
  );
}
  
class MoveCubit extends Cubit<MoveState>{
  MoveCubit() : super (MoveState({},[],"",[],0,false));

  // initialize as no prime, set notationkey and load data from move csv
  void init() async{

  //import from moves_prime.csv
  final csvString = await rootBundle.loadString('assets/moves_prime.csv');
  // id, stage, start png, goal png, correctsequence

  Map<List<String>,String> movekey = {};
  List<String> movelist = [];
  String corrsequence;
  final lines = csvString.split('\n');
  for (String s in lines){
    final info = s.split(',');
    movelist = [info[1],info[2],info[3]]; //id, stage, start_png, goal_png
    corrsequence = info[4]; //correct sequence
    movekey[movelist] = corrsequence;
  }

  emit(
    MoveState(
    movekey,
    movelist,
    movekey[movelist]!,
    state.userMoves,
    state.moveScore,
    false
    )
  );

  nextMoveQuestion(); //initialize moves

  } // init method


void nextMoveQuestion(){ // move on to the next quesiton by picking a random one from the movekey list
  final keys = state.movekey.keys.toList(); // List of List of strings
  final randomKey = keys[Random().nextInt(keys.length)]; // get new movekey
  final correct = state.movekey[randomKey]!; //get new correct answer
    emit(MoveState(state.movekey, randomKey, correct, [], state.moveScore,state.lastAnswerCorrect));
}

void addMove(String move){ //add a move to the userMoves list after clicking corresponding move button

  final updated = List<String>.from(state.userMoves); //copy userMoves
  updated.add(move); //add a move
  
  emit(MoveState(state.movekey, state.currentMovekey, state.moveAnswer,updated,state.moveScore,state.lastAnswerCorrect)); // add move to input
}

void undoMove(){

  final updated = List<String>.from(state.userMoves);

  if (updated.length == 0){ // if empty
   emit(MoveState(state.movekey, state.currentMovekey, state.moveAnswer,state.userMoves,state.moveScore,state.lastAnswerCorrect)); // do nothing
  }
  else if (updated.length == 1){ // if one item
    emit(MoveState(state.movekey, state.currentMovekey, state.moveAnswer,[],state.moveScore,state.lastAnswerCorrect)); // remove move from input
  }
  else{ //otherwise
    updated.removeLast();
    emit(MoveState(state.movekey, state.currentMovekey, state.moveAnswer,[],state.moveScore,state.lastAnswerCorrect)); // remove move to input
  }
}
 
bool checkmoveAnswer(String selectedImage) {
  String normalize(String s) { //makes sure formatting of userAnswer matches correctAnswer
    return s
        .replaceAll('\uFEFF', '')      
        .replaceAll('\u00A0', ' ')     
        .replaceAll('“', '')
        .replaceAll('”', '')
        .replaceAll('’', "'")
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  final userAnswer = normalize(state.userMoves.join(" ")); //collapse usermoves list
  final correctAnswer = normalize(state.moveAnswer); //collapse moveanswer

  final isCorrect = userAnswer == correctAnswer;

  emit(MoveState(
    state.movekey,
    state.currentMovekey,
    state.moveAnswer,
    state.userMoves,
    state.moveScore + (isCorrect ? 1 : 0), //if it is correct, add to score
    isCorrect,
  ));

  return isCorrect;
}

} 