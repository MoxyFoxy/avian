package avian

import "core:unicode/utf8"
import "core:strings"

Token :: union {
    KeywordToken,
    NamedToken,
    StringToken,
    CharToken,
}

KeywordToken :: struct {
    name: string,
}

NamedToken :: struct {
    name: string,
}

StringToken :: struct {
    value: string,
}

CharToken :: struct {
    value: rune,
}

// TODO: Finish the tokenizer
tokenize :: proc(input: string) {
    tokens := Stack(Token){
        make([dynamic]Token)
    };

    temp_token := strings.make_builder();

    in_string := false;
    char := 'a';

    for i in 0..<strings.rune_count(input) {
        char = strings.rune_at_pos(&input, i);

        // In-string check
        if (in_string) {
            if (char == '"') {
                in_string = false;

                strings.write_rune(temp_token, char);

                push(&tokens, StringToken{cast(string) temp_token});
            }

            else {
                strings.write_rune(&temp_token, char);
            }

            continue;
        }

        
    }
}