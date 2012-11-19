// Copyright (c) 2012, the ANTLR Dart backend project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dartlr;

/** A DFA implemented as a set of transition tables.
 *
 *  Any state that has a semantic predicate edge is special; those states
 *  are generated with if-then-else structures in a specialStateTransition()
 *  which is generated by cyclicDFA template.
 *
 *  Could get away with byte sometimes but would have to generate different
 *  types and the simulation code too.  For a point of reference, the Java
 *  lexer's Tokens rule DFA has 326 states roughly.
 */
class DFA {
  
  List<int> _eot;
  List<int> _eof;
  List<int> _min;
  List<int> _max;
  List<int> _accept;
  List<int> _special;
  List<List<int>> _transition;
  int _decisionNumber;
  
  /** Which recognizer encloses this DFA?  Needed to check backtracking */
  BaseRecognizer _recognizer;

  static const bool debug = false;

  DFA([this._recognizer]);
  
  void set decisionNumber(int dn) {
    _decisionNumber = dn;
  }
  
  void set eot(List<int> eot) {
    _eot = eot;
  }
  
  void set eof(List<int> eof) {
    _eof = eof;
  }
  
  void set min(List<int> min) {
    _min = min;
  }
  
  void set max(List<int> max) {
    _max = max;
  }
  
  void set accept(List<int> accept) {
    _accept = accept;
  }
  
  void set special(List<int> special) {
    _special = special;
  }
  
  void set transition(List<List<int>> transition) {
    _transition = transition;
  }
  
  /** From the input stream, predict what alternative will succeed
   *  using this DFA (representing the covering regular approximation
   *  to the underlying CFL).  Return an alternative number 1..n.  Throw
   *  an exception upon error.
   */
  int predict(IntStream input) {
    if (debug)
      print("Enter DFA.predict for decision ${_decisionNumber}");
    int mark = input.mark();    
    int s = 0;
    try {
      while (true) {
        if (debug) 
          print("DFA ${_decisionNumber} state $s LA(1)="
            "${input.LA(1)}(${input.LA(1)}), index=${input.index}");
        int specialState = _special[s];
        if (specialState >= 0) {
          if (debug)
            print("DFA ${_decisionNumber} state $s is special state $specialState");       
          s = specialStateTransition(specialState,input);
          if (debug)
            print("DFA ${_decisionNumber} returns from special state $specialState to $s");
          if (s == -1) {
            _noViableAlt(s, input);
            return 0;
          }
          input.consume();
          continue;
        }
        if (_accept[s] >= 1) {         
          if (debug) 
            print("accept; predict ${_accept[s]} from state $s");
          return _accept[s];
        }       
        int c = input.LA(1);
        if (c >= _min[s] && c <= _max[s]) {
          int snext = _transition[s][c - _min[s]];
          if (snext < 0) {
           if (_eot[s] >= 0) {
              if (debug) 
                stderr.writeString("EOT transition");
              s = _eot[s];
              input.consume();
              continue;
            }
            _noViableAlt(s,input);
            return 0;
          }
          s = snext;
          input.consume();
          continue;
        }
        if (_eot[s] >= 0 ) {
          if (debug) stderr.writeString("EOT transition");
          s = _eot[s];
          input.consume();
          continue;
        }
        if (c == Token.EOF && _eof[s] >= 0) {
          if (debug) 
            stderr.writeString("accept via EOF; predict "
              "${_accept[_eof[s]]} from ${_eof[s]}");
          return _accept[_eof[s]];
        }
       if (debug) {
         stderr.writeString("min[$s]=${_min[s]}");
         stderr.writeString("max[$s]=${_max[s]}");
         stderr.writeString("eot[$s]=${_eot[s]}");
         stderr.writeString("eof[$s]=${_eof[s]}");
         for (int p = 0; p < _transition[s].length; p++)
           stderr.writeString("${_transition[s][p]} ");         
         stderr.writeString(Platform.operatingSystem == "windows" ? "\r\n" : "\n");
        }
        _noViableAlt(s,input);
        return 0;
      }
    }
    finally {
      input.rewind(mark);
    }
  }

  void _noViableAlt(int s, IntStream input) {
    if (_recognizer.state.backtracking > 0) {
      _recognizer.state.failed=true;
      return;
    }
    NoViableAltException nvae =
      new NoViableAltException
        (description, _decisionNumber, s, input);
    _error(nvae);
    throw nvae;
  }

  void _error(NoViableAltException nvae) {}

  int specialStateTransition(int s, IntStream input) => -1;

  String get description => "n/a";
  
  BaseRecognizer get recognizer => _recognizer;
  
  /** Given a String that has a run-length-encoding of some ints
   *  like "\1\2\3\9", convert to List<int> [2,9,9,9].
   */
  static List<int> unpackEncodedString(String encodedString) { 
    int size = 0;
    for (int i = 0; i < encodedString.length; i += 2)
      size += encodedString.charCodeAt(i);
    List data = new List(size);
    int di = 0;
    for (int i = 0; i < encodedString.length; i += 2) {
      int n = encodedString.charCodeAt(i);     
      int v = encodedString.charCodeAt(i + 1);      
      if(v == 0xffff) v = -1;
      for (int j = 1; j <= n; j++)
        data[di++] = v;
    }    
    return data;
  }
  
  static List unpackEncodedStringToUnsignedChars(String encodedString) {    
    int size = 0;
    for (int i = 0; i < encodedString.length; i += 2)
      size += encodedString.charCodeAt(i);    
    List data = new List(size);
    int di = 0;
    for (int i = 0; i < encodedString.length; i += 2) {
      int n = encodedString.charCodeAt(i);
      int v = encodedString.charCodeAt(i + 1);   
      for (int j = 1; j <= n; j++)
        data[di++] = v;     
    }
    return data;
  }
 
}