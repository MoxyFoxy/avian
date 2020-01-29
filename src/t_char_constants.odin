package avian

R_L_PAREN  :: '(';
R_R_PAREN  :: ')';
R_L_SQUARE :: '[';
R_R_SQUARE :: ']';
R_L_CURLY  :: '{';
R_R_CURLY  :: '}';

R_LESS     :: '<';
R_GREATER  :: '>';
R_EQUAL    :: '=';

R_QUOTE    :: '"';
R_APOST    :: '\'';

R_NEWLINE  :: '\n'; // Different from E_NEWLINE as this is the rune (0x0A), not the escape

R_ADD :: '+';
R_SUB :: '-';
R_MUL :: '*';
R_DIV :: '/';
R_MOD :: '%';

R_ALERT     :: 'a'; // Alert
R_BACKSPACE :: 'b'; // Backspace
R_ESCAPE    :: 'e'; // Escape
R_BREAK     :: 'f'; // Page break
//R_NEWLINE   :: 'n'; // Newline
R_CARRIAGE  :: 'r'; // Carriage return
R_TAB       :: 't'; // Horizontal tab
R_V_TAB     :: 'v'; // Vertical tab
R_OCTAL     :: 'o'; // Octal value
R_HEX       :: 'x'; // Unsigned 8, 16, or 32bit hex value
R_UNI       :: 'u'; // 16bit unicode
R_BIG_UNI   :: 'U'; // 32bit unicode

R_DECORATOR :: '@';
R_BACKSLASH :: '\\';
R_EOL :: ';';
