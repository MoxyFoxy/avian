package avian

import "core:unicode/utf8"
import "core:strings"

Token :: union {
    KeywordToken,
    NamedToken,
    StringToken,
    CharToken,
    ConstToken,
    OPToken,
    SpecialToken,
    EOFToken,
}

KeywordToken :: struct {
    kind  : TokenKind,

    line  : u32,
    offset: u32,
}

NamedToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,

    name  : string,
}

StringToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,

    escape: bool,
    value : string,
}

OPToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,
}

SpecialToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,
}

MalformedToken :: SpecialToken;

EOLToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,
}

tokens: Stack(Token);
input: []rune;
temp_token: ^strings.Builder;
file: u32;
line: u32;
offset: u32;
start_line: u32;
start_offset: u32;

warning_queue: [dynamic]Warning;

/*
// Other ConstToken only works well with C transpiling
ConstToken :: struct (T: typeid) {
    value: T,
}
*/

check_for_closer :: inline proc(char: rune) -> bool {
    switch char {
        case '0'..'9', 'a'..'z', 'A'..'Z':
            return true;
            
        case:
            return false;
    }
}

check_for_special :: inline proc(char: rune) -> bool {
    switch char {
        case '~', '`', '!', '@', '#', '$', '%',
             '^', '&', '*', '(', ')', '-', '+',
             '=', '[', ']', '{', '}', '\\', '|',
             ';', ':', '\'', '"', ',', '<', '.',
             '>', '/', '?':
            return true;

        case:
            return false;
    }
}

update_offset :: inline proc(char: rune) {
    if (char == R_NEWLINE) {
        line += 1;
        offset = 0;
    }

    else {
        offset += 1;
    }
}

consume_special :: inline proc(char: rune) {
    switch char {
        case '~':
            push(&tokens, SpecialToken{.TILDE, start_line, start_offset});

        case '`':
            push(&tokens, SpecialToken{.BACKTICK, start_line, start_offset});
    
        case '!':
            push(&tokens, SpecialToken{.NOT, start_line, start_offset});

        case '@':
            push(&tokens, SpecialToken{.AT, start_line, start_offset});

        case '#':
            push(&tokens, SpecialToken{.DECORATOR, start_line, start_offset});

        case '$':
            push(&tokens, SpecialToken{.DOLLAR, start_line, start_offset});

        case '%':
            push(&tokens, OPToken{.MOD, start_line, start_offset});

        case '^':
            push(&tokens, SpecialToken{.POINTER, start_line, start_offset});

        case '&':
            push(&tokens, SpecialToken{.AMPERSAND, start_line, start_offset});

        case '*':
            push(&tokens, SpecialToken{.MUL, start_line, start_offset});

        case '(':
            push(&tokens, SpecialToken{.LEFT_PAREN, start_line, start_offset});

        case ')':
            push(&tokens, SpecialToken{.RIGHT_PAREN, start_line, start_offset});

        case '-':
            push(&tokens, OPToken{.SUB, start_line, start_offset});

        case '=':
            push(&tokens, OPToken{.EQUAL, start_line, start_offset});

        case '+':
            push(&tokens, OPToken{.ADD, start_line, start_offset});

        case '[':
            push(&tokens, SpecialToken{.LEFT_SQUARE, start_line, start_offset});

        case ']':
            push(&tokens, SpecialToken{.RIGHT_SQUARE, start_line, start_offset});

        case '{':
            push(&tokens, SpecialToken{.SCOPE_START, start_line, start_offset});

        case '}':
            push(&tokens, SpecialToken{.SCOPE_END, start_line, start_offset});

        case '\\':
            push(&tokens, OPToken{.BACKSLASH, start_line, start_offset});

        case '|':
            push(&tokens, OPToken{.BIT_OR, start_line, start_offset});

        case ';':
            push(&tokens, SpecialToken{.EOL, start_line, start_offset});

        case ':':
            push(&tokens, SpecialToken{.COLON, start_line, start_offset});

        case '\'':
            push(&tokens, SpecialToken{.APOST, start_line, start_offset});

        case ',':
            push(&tokens, SpecialToken{.COMMA, start_line, start_offset});

        case '<':
            push(&tokens, SpecialToken{.LESSER, start_line, start_offset});

        case '>':
            push(&tokens, SpecialToken{.GREATER, start_line, start_offset});

        case '.':
            push(&tokens, SpecialToken{.DOT, start_line, start_offset});

        case '/':
            push(&tokens, SpecialToken{.DIV, start_line, start_offset});

        case '?':
            push(&tokens, SpecialToken{.QUESTION, start_line, start_offset});
    
        case:
            push(&tokens, MalformedToken{.MALFORMED, start_line, start_offset});
    }
}

check_for_keyword :: proc() {
    check := strings.to_string(&temp_token);

    switch check {
        case "obj":
            push(&tokens, KeywordToken{.OBJ, start_line, start_offset});

        case "bvr":
            push(&tokens, KeywordToken{.BEHAVIOR, start_line, start_offset});

        case "character":
            push(&tokens, KeywordToken{.CHARACTER, start_line, start_offset});

        case "union":
            push(&tokens, KeywordToken{.UNION, start_line, start_offset});

        case "enum":
            push(&tokens, KeywordToken{.ENUM, start_line, start_offset});

        case "unique":
            push(&tokens, KeywordToken{.UNIQUE, start_line, start_offset});

        case "is":
            push(&tokens, KeywordToken{.IS, start_line, start_offset});


        case "if":
            push(&tokens, KeywordToken{.IF, start_line, start_offset});

        case "elseif":
            push(&tokens, KeywordToken{.ELSEIF, start_line, start_offset});

        case "else":
            push(&tokens, KeywordToken{.ELSE, start_line, start_offset});

        case "switch":
            push(&tokens, KeywordToken{.SWITCH, start_line, start_offset});

        case "case":
            push(&tokens, KeywordToken{.CASE, start_line, start_offset});

        case "for":
            push(&tokens, KeywordToken{.FOR, start_line, start_offset});

        case "in":
            push(&tokens, KeywordToken{.IN, start_line, start_offset});

        case "notin":
            push(&tokens, KeywordToken{.NOTIN, start_line, start_offset});

        case "while":
            push(&tokens, KeywordToken{.WHILE, start_line, start_offset});

        case "do":
            push(&tokens, KeywordToken{.DO, start_line, start_offset});

        case "break":
            push(&tokens, KeywordToken{.BREAK, start_line, start_offset});

        case "continue":
            push(&tokens, KeywordToken{.CONTINUE, start_line, start_offset});

        case "return":
            push(&tokens, KeywordToken{.RETURN, start_line, start_offset});

        case "proc":
            push(&tokens, KeywordToken{.PROC, start_line, start_offset});

        case "trait":
            push(&tokens, KeywordToken{.TRAT, start_line, start_offset});

        case "inline":
            push(&tokens, KeywordToken{.INLINE, start_line, start_offset});

        case "import":
            push(&tokens, KeywordToken{.IMPORT, start_line, start_offset});

        case "as":
            push(&tokens, KeywordToken{.AS, start_line, start_offset});

        case "lib":
            push(&tokens, KeywordToken{.LIB, start_line, start_offset});

        case "when":
            push(&tokens, KeywordToken{.WHEN, start_line, start_offset});

        case "cast":
            push(&tokens, KeywordToken{.CAST, start_line, start_offset});

        case "defer":
            push(&tokens, KeywordToken{.DEFER, start_line, start_offset});

        case "uint":
            push(&tokens, KeywordToken{.UINT, start_line, start_offset});

        case "u8":
            push(&tokens, KeywordToken{.U8, start_line, start_offset});

        case "u16":
            push(&tokens, KeywordToken{.U16, start_line, start_offset});

        case "u32":
            push(&tokens, KeywordToken{.U32, start_line, start_offset});

        case "u64":
            push(&tokens, KeywordToken{.U64, start_line, start_offset});

        case "u128":
            push(&tokens, KeywordToken{.U128, start_line, start_offset});

        case "int":
            push(&tokens, KeywordToken{.INT, start_line, start_offset});

        case "i8":
            push(&tokens, KeywordToken{.I8, start_line, start_offset});

        case "i16":
            push(&tokens, KeywordToken{.I16, start_line, start_offset});

        case "i32":
            push(&tokens, KeywordToken{.I32, start_line, start_offset});

        case "i64":
            push(&tokens, KeywordToken{.I64, start_line, start_offset});

        case "i128":
            push(&tokens, KeywordToken{.I128, start_line, start_offset});

        case "f32":
            push(&tokens, KeywordToken{.F32, start_line, start_offset});

        case "f64":
            push(&tokens, KeywordToken{.F64, start_line, start_offset});

        case "char":
            push(&tokens, KeywordToken{.CHAR, start_line, start_offset});

        case "str":
            push(&tokens, KeywordToken{.STR, start_line, start_offset});

        case "cstr":
            push(&tokens, KeywordToken{.CSTR, start_line, start_offset});

        case "type":
            push(&tokens, KeywordToken{.TYPE, start_line, start_offset});

        case "typeid":
            push(&tokens, KeywordToken{.TYPEID, start_line, start_offset});

        case "ctx":
            push(&tokens, KeywordToken{.CTX, start_line, start_offset});
    }
}

// Consumes a string and turns it into a token
consume_string :: inline proc() {
    str_has_escape := false;

    for len(input) > 0 {
        escape := false;

        char  = input[0];
        input = input[1:];

        update_offset(char);

        if (char == R_BACKSLASH) {
            str_has_escape = true;
            escape = true;
        }

        else if (char == R_QUOTE && !escape) {
            push(&tokens, StringToken{.STRING, start_line, start_offset, str_has_escape, strings.to_string(temp_token)});
            strings.reset_builder(temp_token);
            return;
        }

        strings.write_rune(temp_token, char);
    }

    warning(.T_UNEXPECTED_EOF);
}

consume_named :: proc() {
    for len(input) > 0 {
        char  = input[0];

        if (check_for_special(char) || check_for_closer(char)) {
            push(&tokens, StringToken{.NAMED, start_line, start_offset, strings.to_string(temp_token)});
            strings.reset_builder(temp_token);
            return;
        }

        input = input[1:];
        update_offset(char);

        if (check_for_keyword()) {

        }

        strings.write_rune(temp_token, char);
    }
}

// TODO: Finish the tokenizer
tokenize :: proc(file: u32, input: []rune]) {
    tokens = Stack(Token){
        make([dynamic]Token, 100)
    };

    // Globals
    line = 0;
    offset = 0;
    temp_token = strings.make_builder();
    warning_queue = make([dynamic]Warning, 20);

    // Just give it a default value. F for "F0x1fy"!
    char := 'F';

    // Thanks Tetralux for teaching me this way to iterate :)
    for len(input) > 0 {
        char  = input[0];
        input = input[1:];

        update_offset(char);

        start_line   = line;
        start_offset = offset;

        // In-string check
        if (check_for_special()) {
            consume_special(char);
        }
    }
}
