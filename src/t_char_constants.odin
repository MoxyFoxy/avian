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

E_ALERT     :: 'a'; // Alert
E_BACKSPACE :: 'b'; // Backspace
E_ESCAPE    :: 'e'; // Escape
E_BREAK     :: 'f'; // Page break
E_NEWLINE   :: 'n'; // Newline
E_CARRIAGE  :: 'r'; // Carriage return
E_TAB       :: 't'; // Horizontal tab
E_V_TAB     :: 'v'; // Vertical tab
E_OCTAL     :: 'o'; // Octal value
E_HEX       :: 'x'; // Unsigned 8, 16, or 32bit hex value
E_UNI       :: 'u'; // 16bit unicode
E_BIG_UNI   :: 'U'; // 32bit unicode

R_DECORATOR :: '@';
R_BACKSLASH :: '\\';
R_EOL :: ';';
