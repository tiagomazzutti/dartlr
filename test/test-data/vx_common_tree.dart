// Copyright (c) 2012, the ANTLR Dart backend project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dartlr_tests;

class VX extends CommonTree {
  
  VX(dynamic t) : super(t);
     
  String toString() {
    return "${super.toString()}<V>";
  }
  
}