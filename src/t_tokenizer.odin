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
    EOFToken,
}

KeywordToken :: struct {
    line  : u32,
    offset: u32,

    name  : string,
}

NamedToken :: struct {
    line  : u32,
    offset: u32,

    name  : string,
}

StringToken :: struct {
    line  : u32,
    offset: u32,

    value : string,
}

CharToken :: struct {
    line  : u32,
    offset: u32,

    value : rune,
}

ConstToken :: struct {
    line  : u32,
    offset: u32,

    value : string,
    type  : Type,
}

OPToken :: struct {
    line  : u32,
    offset: u32,

    value : rune,
}

EOLToken :: struct {
    line  : u32,
    offset: u32,
}

tokens: Stack(Token);
input: []byte;
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
    return true;
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

// Consumes a string and turns it into a token
consume_string :: inline proc() {
    for len(input) > 0 {
        char, n := utf8.decode_rune(input);
        input = input[n:];

        update_offset(char);

        if (char == R_BACKSLASH) {
            char, n = utf8.decode_rune(input);
            input = input[n:];

            update_offset(char);
            consume_escape(char);
        }

        else if (char == R_QUOTE) {
            push(&tokens, StringToken{start_line, start_offset, strings.to_string(temp_token)});
            strings.reset_builder(temp_token);
            return;
        }

        strings.write_rune(temp_token, char);
    }

    warning(.T_UNEXPECTED_EOF);
}

/*
 * Octals and hexadecimals
 */

// Consumes an octal value (\onnn)
consume_octal :: inline proc() {
    strings.write_string(temp_token, "\\0o");

    start: u8 = 0;

    for len(input) > 0 {
        char, n := utf8.decode_rune(input);
        input = input[n:];

        update_offset(char);

        ok := check_for_closer(char);

        if (ok) {
            #partial switch char {
                case '0'..'9', 'a'..'f', 'A'..'F':
                    // FOR_C: Specifically for C transpilation
                    strings.write_rune(temp_token, char);

                case:
                    warning(.T_INVALID_OCTAL_VALUE);
            }
        }

        start += 1;
    }

    if (start < 3) {
        warning(.T_OCTAL_TOO_SMALL);
        return;
    }

    else if (start > 3) {
        warning(.T_OCTAL_TOO_LARGE);
        return;
    }

    else {
        push(&tokens, ConstToken{start_line, start_offset, strings.to_string(temp_token), .OCTAL});
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an 8bit, 16bit, or 32bit hex (\xnn, \xnnnn, \xnnnnnnnn)
consume_unsigned_hex :: inline proc() {

    // FOR_C: Specifically for C transpilation
    strings.write_string(temp_token, "\\0x");

    bit_count: u8 = 0;

    for len(input) > 0 {
        char, n := utf.decode_rune(input);
        input = input[n:];

        update_offset(char);

        ok := check_for_closer(char);

        if (ok) {
            #partial switch char {
                case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
                case 'a', 'b', 'c', 'd', 'e', 'f':
                case 'A', 'B', 'C', 'D', 'E', 'F':

                    // FOR_C: Specifically for C transpilation
                    strings.write_rune(temp_token, char);

                case:
                    warning(.T_INVALID_OCTAL_VALUE);
            }
        }
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an escape sequence (control or octal / hex). Preceded by a `\`
consume_escape :: inline proc(char: rune) {
    switch char {
        case E_ALERT, E_BACKSPACE, E_ESCAPE, E_BREAK, E_NEWLINE, E_CARRIAGE,
             E_TAB, E_V_TAB, R_BACKSLASH, R_APOST, R_QUOTE:
            
            // FOR_C: Specifically for C transpilation
            strings.write_rune(temp_token, R_BACKSLASH);
            strings.write_rune(temp_token, char);

        case E_OCTAL:
            consume_octal();

        case E_U_HEX:
            consume_unsigned_hex();

        case E_S_HEX:
            consume_signed_hex();

        case:
            warning(.T_INVALID_ESCAPE);
            return;
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an apostrophe. Could be either a member or a char
consume_apostrophe :: proc() {

}

// TODO: Finish the tokenizer
tokenize :: proc(file: u32, input: []byte]) {
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
        char, n := utf8.decode_rune(input);
        input = input[n:];

        update_offset(char);

        start_line   = line;
        start_offset = offset;

        // In-string check
        switch char {
            case R_QUOTE:
                consume_string(&input, temp_token, i);
                continue;

            case R_APOST:
                consume_apostrophe(&input, temp_token, i);
                push(&tokens, StringToken{strings.to_string(temp_token)});
                strings.reset_builder(temp_token);
                continue;
        }
    }
}