package avian

import "core:unicode/utf8"
import "core:strings"

Token :: union {
    NamedToken,
    NumberToken,
    StringToken,
    OPToken,
    SpecialToken,
}

NamedToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,

    name  : string,
}

NumberToken :: struct {
    kind  : TokenKind,
    
    line  : u32,
    offset: u32,

    value : string,
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

// Globals
tokens: [dynamic]Token;
input: []rune;
temp_token: strings.Builder;
file: u32;
line: u32;
offset: u32;
start_line: u32;
start_offset: u32;

warning_queue: [dynamic]Warning;

// Checks for non-alphabetic characters. This is temporary until full unicode support
check_for_closer :: inline proc(char: rune) -> bool {
    switch char {
        case '0'..'9', 'a'..'z', 'A'..'Z':
            return false;
            
        case:
            return true;
    }
}

// Checks for pre-determined special characters (aka mostly the operators)
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

// Updates offset accordingly. Accounts for newlines.
update_offset :: inline proc(char: rune) {
    if (char == R_NEWLINE) {
        line += 1;
        offset = 0;
    }

    else {
        offset += 1;
    }
}

// Consumes a special character. Yes, it's necessary to be this long...
consume_special :: inline proc(char: rune) {
    switch char {
        case '~':
            append(&tokens, SpecialToken{.TILDE, start_line, start_offset});

        case '`':
            append(&tokens, SpecialToken{.BACKTICK, start_line, start_offset});
    
        case '!':
            append(&tokens, SpecialToken{.NOT, start_line, start_offset});

        case '@':
            append(&tokens, SpecialToken{.AT, start_line, start_offset});

        case '#':
            append(&tokens, SpecialToken{.DECORATOR, start_line, start_offset});

        case '$':
            append(&tokens, SpecialToken{.DOLLAR, start_line, start_offset});

        case '%':
            append(&tokens, OPToken{.MOD, start_line, start_offset});

        case '^':
            append(&tokens, SpecialToken{.POINTER, start_line, start_offset});

        case '&':
            append(&tokens, SpecialToken{.AMPERSAND, start_line, start_offset});

        case '*':
            append(&tokens, SpecialToken{.MUL, start_line, start_offset});

        case '(':
            append(&tokens, SpecialToken{.LEFT_PAREN, start_line, start_offset});

        case ')':
            append(&tokens, SpecialToken{.RIGHT_PAREN, start_line, start_offset});

        case '-':
            append(&tokens, OPToken{.SUB, start_line, start_offset});

        case '=':
            append(&tokens, OPToken{.EQUAL, start_line, start_offset});

        case '+':
            append(&tokens, OPToken{.ADD, start_line, start_offset});

        case '[':
            append(&tokens, SpecialToken{.LEFT_SQUARE, start_line, start_offset});

        case ']':
            append(&tokens, SpecialToken{.RIGHT_SQUARE, start_line, start_offset});

        case '{':
            append(&tokens, SpecialToken{.SCOPE_START, start_line, start_offset});

        case '}':
            append(&tokens, SpecialToken{.SCOPE_END, start_line, start_offset});

        case '\\':
            append(&tokens, OPToken{.BACKSLASH, start_line, start_offset});

        case '|':
            append(&tokens, OPToken{.BIT_OR, start_line, start_offset});

        case ';':
            append(&tokens, SpecialToken{.EOL, start_line, start_offset});

        case ':':
            append(&tokens, SpecialToken{.COLON, start_line, start_offset});

        case '\'':
            append(&tokens, SpecialToken{.APOST, start_line, start_offset});

        case ',':
            append(&tokens, SpecialToken{.COMMA, start_line, start_offset});

        case '<':
            append(&tokens, SpecialToken{.LESSER, start_line, start_offset});

        case '>':
            append(&tokens, SpecialToken{.GREATER, start_line, start_offset});

        case '.':
            append(&tokens, SpecialToken{.DOT, start_line, start_offset});

        case '/':
            append(&tokens, SpecialToken{.DIV, start_line, start_offset});

        case '?':
            append(&tokens, SpecialToken{.QUESTION, start_line, start_offset});
    
        // This should never happen. If it does, the code is seriously messed up lol
        case:
            append(&tokens, MalformedToken{.MALFORMED, start_line, start_offset});
    }
}

// Consumes a string and turns it into a token
consume_string :: inline proc() {
    str_has_escape := false;

    input = input[1:];

    for len(input) > 0 {

        // This was intentionally put here as it'll reset every loop
        escape := false;

        char := input[0];
        input = input[1:];

        update_offset(char);

        // This allows us to check if there is an escape
        // during the compiling phase
        if (char == R_BACKSLASH) {
            str_has_escape = true;
            escape = true;
        }

        else if (char == R_QUOTE && !escape) {
            append(&tokens, StringToken{.STRING, start_line, start_offset, str_has_escape, strings.clone(strings.to_string(temp_token))});
            strings.reset_builder(&temp_token);
            return;
        }

        strings.write_rune(&temp_token, char);
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes a name
consume_named :: inline proc() {
    for len(input) > 0 {
        char := input[0];

        if (check_for_special(char) || check_for_closer(char)) {
            append(&tokens, NamedToken{.NAMED, start_line, start_offset, strings.clone(strings.to_string(temp_token))});
            strings.reset_builder(&temp_token);
            return;
        }

        // Having the input mutate after a possible return was done intentionally.
        // Allows the tokenizer to properly lex the special/closing token
        input = input[1:];
        update_offset(char);

        strings.write_rune(&temp_token, char);
    }
}

// Consumes a number. Note that this DOES consider all alphanumeric characters
consume_number :: inline proc() {
    for len(input) > 0 {
        char := input[0];

        if (check_for_special(char) || check_for_closer(char)) {
            append(&tokens, NumberToken{.NUMBER, start_line, start_offset, strings.clone(strings.to_string(temp_token))});
            strings.reset_builder(&temp_token);
            return;
        }

        // Having the input mutate after a possible return was done intentionally.
        // Allows the tokenizer to properly lex the special/closing token
        input = input[1:];
        update_offset(char);

        strings.write_rune(&temp_token, char);
    }
}

// Takes in a file number and an array of runes to create a dynamic array of tokens and warnings.
// You can create an array of runes from a string by calling `strings.string_to_runes`
tokenize :: proc(file: u32, _input: []rune) -> ([dynamic]Token, [dynamic]Warning) {
    // This is done this way to make sure not to cause shadowing
    input = _input;

    // Setting globals
    tokens = make([dynamic]Token, 0, 100);
    line = 0;
    offset = 0;
    temp_token = strings.make_builder();
    warning_queue = make([dynamic]Warning, 0, 20);

    // Just give it a default value. F for "F0x1fy"!
    char := 'F';

    // Thanks Tetralux for teaching me this way to iterate :)
    for len(input) > 0 {
        char := input[0];

        update_offset(char);

        start_line   = line;
        start_offset = offset;

        // This has to come before check_for_special
        if (char == R_QUOTE) {
            consume_string();
        }

        else if (check_for_special(char)) {
            consume_special(char);
        }

        else if (is_number(char)) {
            consume_number();
        }

        else if (!check_for_closer(char)) {
            consume_named();
        }

        // Edge cases where it could reach the end from a previous consumer
        if (len(input) > 0) {
            input = input[1:];
        }
    }

    return tokens, warning_queue;
}

is_number :: inline proc(char: rune) -> bool {
    switch char {
        case '0'..'9':
            return true;

        case:
            return false;
    }
}