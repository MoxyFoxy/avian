package utest

import "../src"

import "core:unicode/utf8"
import "core:fmt"
import "core:os"

main :: proc() {
    character_test, _ := os.read_entire_file("../test-code/character.avn");

    tokens, warnings := src.tokenize(0, utf8.string_to_runes(cast(string)character_test));

    for token in tokens {
        fmt.println(token);
    }
    
    fmt.println('\n');

    for warning in warnings {
        fmt.println(warning);
    }

    // Demonstrates an edge case with EOF causing a weird interation between `src.tokenize` and `src.consume_string`
    // where the input size ends up zeroing out and crashing.
    string_test := "\"this is a string test \\n\"";

    tokens, warnings = src.tokenize(0, utf8.string_to_runes(cast(string)string_test));

    for token in tokens {
        fmt.println(token);
    }
    
    fmt.println('\n');

    for warning in warnings {
        fmt.println(warning);
    }
}