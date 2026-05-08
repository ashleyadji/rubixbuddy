import "package:flutter_bloc/flutter_bloc.dart"; // for cubit information
import "dart:math"; // for randomness

class NotationState {
  bool primes = true; // whether we are using prime or nonprime notation
  Map<String,String> notationkey = {}; //map for the notation learning mode
  String currentPrompt = ""; //current prompt to user
  int notationScore = 0; // score
  bool lastAnswerCorrect; //keeps track of last answer that is correct

  NotationState(
  this.primes, 
  this.notationkey,
  this.currentPrompt,
  this.notationScore,
  this.lastAnswerCorrect
  );
}

class NotationCubit extends Cubit<NotationState>{
  NotationCubit() : super (NotationState(true,{},"",0,false));

  // Initialize mode with nonprime setting
  void init(){

    emit(
    NotationState(
      state.primes, // set to with prime mode initially
      {"U": 'move_U.png',
      "U'" : 'move_Uprime.png',
      "D": 'move_D.png',
      "D'" : 'move_Dprime.png',
      "L": 'move_L.png',
      "L'" : 'move_Lprime.png',
      "R": 'move_R.png',
      "R'" : 'move_Rprime.png',
      "F" : 'move_F.png',
      "F'" : 'move_Fprime.png',
      "B" : 'move_B.png',
      "B'" : 'move_Bprime.png'},
      state.currentPrompt, //change question using randomkey
      state.notationScore, 
      state.lastAnswerCorrect
    ));

     nextNotationQuestion();
  } //initialize

  void nextNotationQuestion() {
  //change question using randomkey
  final keys = state.notationkey.keys.toList();
  final randomKey = keys[Random().nextInt(keys.length)];

  emit(
    NotationState(
      state.primes,
      state.notationkey,
      randomKey,
      state.notationScore, 
      state.lastAnswerCorrect
    )
  );
  } //nextNotationQuestion

  void checkNotationAnswer(String selectedImage){
    // notation - check answer (submit button)
    // sees if correct sube rotation image was selected in response to notation
    // adjust score 

    if (selectedImage == state.notationkey[state.currentPrompt]) {
      emit(
        NotationState(
        state.primes,
        state.notationkey,
        state.currentPrompt, 
        state.notationScore+1, 
        true
      )
    );
    }else{
       emit(
        NotationState(
        state.primes,
        state.notationkey,
        state.currentPrompt,
        state.notationScore,
        false
      ));
    }
  } //checkNotationAnswer

  void togglePrime(){   // switch between prime / no prime mode (both notation and moves)
    Map<String, String> notationprime = {
    "U": 'move_U.png',
    "U'" : 'move_Uprime.png',
    "D": 'move_D.png',
    "D'" : 'move_Dprime.png',
    "L": 'move_L.png',
    "L'" : 'move_Lprime.png',
    "R": 'move_R.png',
    "R'" : 'move_Rprime.png',
    "F" : 'move_F.png',
    "F'" : 'move_Fprime.png',
    "B" : 'move_B.png',
    "B'" : 'move_Bprime.png'
  };

  Map<String, String> notationnoprime = {
    "U": 'move_U.png',
    "O" : 'move_O.png',
    "D": 'move_D.png',
    "N" : 'move_N.png',
    "L": 'move_L.png',
    "E" : 'move_E.png',
    "R": 'move_R.png',
    "S" : 'move_S.png',
    "F" : 'move_F.png',
    "G" : 'move_G.png',
    "B" : 'move_B.png',
    "K" : 'move_K.png'
    };

  if (state.primes) { //if primes == true
    emit(
        NotationState( // flip to no primes
        false,
        notationnoprime,
        state.currentPrompt, 
        state.notationScore, 
        state.lastAnswerCorrect
      )
    );
  } 
  else { // if primes == false
    emit(
        NotationState( // flip to yes primes
        true,
        notationprime,
        state.currentPrompt, 
        state.notationScore, 
        state.lastAnswerCorrect
      )
    );
  }
   nextNotationQuestion();
}

} //Notation Cubit