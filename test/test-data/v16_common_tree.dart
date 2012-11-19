// Copyright (c) 2012, the ANTLR Dart backend project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dartlr_tests;

class V16 extends CommonTree {
  
  Object x;
  
  V16(int ttype, this.x) : super.fromToken(new CommonToken(ttype));
 
  String toString() {
    return "${t053heteroTP16.namesOfTokens[this.type]}<V>;${this.x}";
  }
  
}
