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

MemberToken :: struct {
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

OctalToken :: struct {
    line  : u32,
    offset: u32,

    value : u16,
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
        char  = input[0];
        input = input[1:];

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
    start := 0;

    for len(input) > 0 {
        char  = input[0];
        input = input[1:];

        output := 0;
        count  := 0;

        update_offset(char);

        ok := check_for_closer(char);

        output := 0;

        if (ok) {
            switch char {
                case '0'..'7':
                    temp := u16((u8)char - 30);

                    if (output != 0) {
                        output *= 8;
                    }

                    count  += 1;
                    output += temp;

                case:
                    warning(.T_INVALID_OCTAL_VALUE);
            }
        }

        else if (start != 0) {
            push(&tokens, OctalToken{start_line, start_offset, output});
            strings.reset_builder(temp_token);
            return;
        }

        else {
            warning(.T_INVALID_OCTAL_VALUE);
        }

        start += 1;
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an 8bit, 16bit, or 32bit unsigned hex (\xnn, \xnnnn, \xnnnnnnnn)
consume_hex :: inline proc() {
    bit_count: u8 = 0;

    for len(input) > 0 {
        char  = input[0];
        input = input[1:];

        update_offset(char);

        ok := check_for_closer(char);

        if (ok) {
            switch char {
                case '0'..'9':
                    temp := u16((u8)char - 30);

                    if (output != 0) {
                        output *= 8;
                    }

                    count  += 1;
                    output += temp;

                case 'A'..'F':
                    temp := u16((u8)char - 31);

                    if (output != 0) {
                        output *= 8;
                    }

                    count  += 1;
                    output += temp;

                case 'a'..'f':
                    temp := u16((u8)char - 51);

                    if (output != 0) {
                        output *= 8;
                    }

                    count  += 1;
                    output += temp;

                case:
                    warning(.T_INVALID_OCTAL_VALUE);
                    return;
            }
        }

        else {
            break;
        }
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an escape sequence (control or octal / hex). Preceded by a `\`
consume_escape :: inline proc(char: rune) {
    switch char {
        case R_ALERT, R_BACKSPACE, R_ESCAPE, R_BREAK, R_NEWLINE, R_CARRIAGE,
             R_TAB, R_V_TAB, R_BACKSLASH, R_APOST, R_QUOTE:

            strings.write_rune(temp_token, char);

        case R_OCTAL:
            consume_octal();

        case R_HEX:
            consume_hex();

        case:
            warning(.T_INVALID_ESCAPE);
            return;
    }

    warning(.T_UNEXPECTED_EOF);
}

// Consumes an apostrophe. Could be either a member or a char
consume_apostrophe :: proc() {
    if (input[2] == '\'') {
        push(&tokens, CharToken{start_line, start_offset, input[1]});
        strings.reset_builder(temp_token);
        
        input = input[3:];
    }
    
    else {
        for len(input) > 0 {
            char  = input[0];
            input = input[1:];
            
            ok := check_for_closer(char);
            
            if (ok) {
                strings.write_rune(char);
            }
            
            else {
                push(&tokens, MemberToken{strings.to_string(temp_token)});
                strings.reset_builder(temp_token);

                input = input[3:];
            }
        }
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
        switch char {
            case R_QUOTE:
                consume_string(&input, temp_token, i);
                continue;

            case R_APOST:
                consume_apostrophe(&input, temp_token);
                continue;
        }
    }
}
