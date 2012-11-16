grammar t051treeRewriteASTv;
options {
    language=Dart;
    output=AST;
}

@header{part of dartlr_tests;}

a : ID INT -> ID INT | INT ;
ID : 'a'..'z'+ ;
INT : '0'..'9'+;
WS : (' '|'\n') {$channel = HIDDEN;} ;
