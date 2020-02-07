package avian

import "core:unicode/utf8"
import "core:strings"

// Thanks TillerErikson and Tetralux for teaching me about in-struct unions!
Token :: struct {
    kind: TokenKind,

    line  : u32,
    offset: u32,

    variant: union {
        NamedToken,
        NumberToken,
        StringToken,
        OPToken,
        SpecialToken,
    },
}

NamedToken :: struct {
    name  : string,
}

NumberToken :: struct {
    value : string,
}

StringToken :: struct {
    escape: bool,
    value : string,
}

OPToken :: struct {}

SpecialToken :: struct {}

MalformedToken :: SpecialToken;

// File-scoped globals
@(private="file")
tokens: [dynamic]Token;

@(private="file")
input: []rune;

@(private="file")
temp_token: strings.Builder;

@(private="file")
file: u32;

@(private="file")
line: u32;

@(private="file")
offset: u32;

@(private="file")
start_line: u32;

@(private="file")
start_offset: u32;

@(private="file")
warning_queue: [dynamic]Warning;

@(private="file")
peek :: inline proc(index: int = 0) -> rune {
    return input[index];
}

@(private="file")
eat :: inline proc() -> rune {
    char := input[0];
    input = input[1:];
    return char;
}

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
            append(&tokens, Token{.TILDE, start_line, start_offset, SpecialToken{}});

        case '`':
            append(&tokens, Token{.BACKTICK, start_line, start_offset, SpecialToken{}});

        case '!':
            append(&tokens, Token{.NOT, start_line, start_offset, SpecialToken{}});

        case '@':
            append(&tokens, Token{.AT, start_line, start_offset, SpecialToken{}});

        case '#':
            append(&tokens, Token{.DECORATOR, start_line, start_offset, SpecialToken{}});

        case '$':
            append(&tokens, Token{.DOLLAR, start_line, start_offset, SpecialToken{}});

        case '%':
            append(&tokens, Token{.MOD, start_line, start_offset, OPToken{}});

        case '^':
            append(&tokens, Token{.POINTER, start_line, start_offset, SpecialToken{}});

        case '&':
            append(&tokens, Token{.AMPERSAND, start_line, start_offset, SpecialToken{}});

        case '*':
            append(&tokens, Token{.MUL, start_line, start_offset, SpecialToken{}});

        case '(':
            append(&tokens, Token{.LEFT_PAREN, start_line, start_offset, SpecialToken{}});

        case ')':
            append(&tokens, Token{.RIGHT_PAREN, start_line, start_offset, SpecialToken{}});

        case '-':
            append(&tokens, Token{.SUB, start_line, start_offset, OPToken{}});

        case '=':
            append(&tokens, Token{.EQUAL, start_line, start_offset, OPToken{}});

        case '+':
            append(&tokens, Token{.ADD, start_line, start_offset, OPToken{}});

        case '[':
            append(&tokens, Token{.LEFT_SQUARE, start_line, start_offset, SpecialToken{}});

        case ']':
            append(&tokens, Token{.RIGHT_SQUARE, start_line, start_offset, SpecialToken{}});

        case '{':
            append(&tokens, Token{.SCOPE_START, start_line, start_offset, SpecialToken{}});

        case '}':
            append(&tokens, Token{.SCOPE_END, start_line, start_offset, SpecialToken{}});

        case '\\':
            append(&tokens, Token{.BACKSLASH, start_line, start_offset, OPToken{}});

        case '|':
            append(&tokens, Token{.BIT_OR, start_line, start_offset, OPToken{}});

        case ';':
            append(&tokens, Token{.EOL, start_line, start_offset, SpecialToken{}});

        case ':':
            append(&tokens, Token{.COLON, start_line, start_offset, SpecialToken{}});

        case '\'':
            append(&tokens, Token{.APOST, start_line, start_offset, SpecialToken{}});

        case ',':
            append(&tokens, Token{.COMMA, start_line, start_offset, SpecialToken{}});

        case '<':
            append(&tokens, Token{.LESSER, start_line, start_offset, SpecialToken{}});

        case '>':
            append(&tokens, Token{.GREATER, start_line, start_offset, SpecialToken{}});

        case '.':
            append(&tokens, Token{.DOT, start_line, start_offset, SpecialToken{}});

        case '/':
            append(&tokens, Token{.DIV, start_line, start_offset, SpecialToken{}});

        case '?':
            append(&tokens, Token{.QUESTION, start_line, start_offset, SpecialToken{}});

        // This should never happen. If it does, the code is seriously messed up lol
        case:
            append(&tokens, Token{.MALFORMED, start_line, start_offset, MalformedToken{}});
    }
}

// Consumes a string and turns it into a token
consume_string :: inline proc() {
    str_has_escape := false;

    // Get rid of the first `"`
    eat();

    for len(input) > 0 {

        // This was intentionally put here as it'll reset every loop
        escape := false;

        char := eat();

        update_offset(char);

        // This allows us to check if there is an escape
        // during the compiling phase
        if (char == R_BACKSLASH) {
            str_has_escape = true;
            escape = true;
        }

        else if (char == R_QUOTE && !escape) {
            append(&tokens, Token{.STRING, start_line, start_offset, StringToken{str_has_escape, strings.clone(strings.to_string(temp_token))}});
            strings.reset_builder(&temp_token);
            return;
        }

        strings.write_rune(&temp_token, char);
    }

    warning(warning_queue, .T_UNEXPECTED_EOF, file, line, offset);
}

// Consumes a name
consume_named :: inline proc() {
    for len(input) > 0 {
        char := peek();

        if (check_for_special(char) || check_for_closer(char)) {
            append(&tokens, Token{.NAMED, start_line, start_offset, NamedToken{strings.clone(strings.to_string(temp_token))}});
            strings.reset_builder(&temp_token);
            return;
        }

        // Having the input mutate after a possible return was done intentionally.
        // Allows the tokenizer to properly lex the special/closing token
        eat();
        update_offset(char);

        strings.write_rune(&temp_token, char);
    }
}

// Consumes a number. Note that this DOES consider all alphanumeric characters
consume_number :: inline proc() {
    for len(input) > 0 {
        char := peek();

        if (check_for_special(char) || check_for_closer(char)) {
            append(&tokens, Token{.NUMBER, start_line, start_offset, NumberToken{strings.clone(strings.to_string(temp_token))}});
            strings.reset_builder(&temp_token);
            return;
        }

        // Having the input mutate after a possible return was done intentionally.
        // Allows the tokenizer to properly lex the special/closing token
        eat();
        update_offset(char);

        strings.write_rune(&temp_token, char);
    }
}

consume_comment :: inline proc() {
    for len(input) > 0 {
        char := eat();

        if (peek(1) == '\n') {
            return;
        }
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
        char := peek();

        update_offset(char);

        start_line   = line;
        start_offset = offset;

        if (char == R_SLASH && peek(1) == R_SLASH) {
            consume_comment();
        }

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
            eat();
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