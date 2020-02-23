package avian

import "core:strings"
import "core:strconv"

// Globals
@(private="file")
tokens: []Token;

@(private="file")
token: Token;

@(private="file")
warning_queue: [dynamic]Warning;

@(private="file")
ast: AST;

@(private="file")
statement: [dynamic]Expression;

@(private="file")
file: u32;

@(private="file")
peek :: inline proc(amount: int = 0) -> Token {
    assert(tokens[amount].kind != TokenKind.MALFORMED);
    return tokens[amount];
}

@(private="file")
eat :: inline proc() -> Token {
    token := tokens[0];
    tokens = tokens[1:];
    assert(token.kind != TokenKind.MALFORMED);
    return token;
}

@(private="file")
discard :: inline proc(amount: int = 1) {
    tokens = tokens[amount:];
}

check_for_keyword :: proc(name: string) -> bool {
    switch name {
        case "obj", "bvr", "char", "union", "enum", "unique", "is", "if",
             "elseif", "else", "switch", "case", "for", "in", "notin",
             "while", "do", "break", "continue", "return", "proc", "trait",
             "inline", "import", "as", "lib", "when", "cast", "defer",
             "uint", "u8", "u16", "u32", "u64", "u128", "int", "i8", "i16",
             "i32", "i64", "i128", "f32", "f64", "intle", "i8le", "i16le",
             "i32le", "i64le", "i128le", "uintle", "u8le", "u16le",
             "u32le", "u64le", "u128le", "f32le", "f64le", "intbe", "i8be",
             "i16be", "i32be", "i64be", "i128be", "uintbe", "u8be", "u16be",
             "u32be", "u64be", "u128be", "f32be", "f64be", "type",
             "type_id", "ctx":

            return true;

        case:
            return false;
    }
}



build_ast :: proc(package_name: string, file: u32, _tokens: []Token, _warning_queue: [dynamic]Warning) -> AST {
    tokens = _tokens;
    warning_queue = _warning_queue;

    ast = AST {package_name,

               //make(map[string] Behavior, 0, 100),  // Commented out until it's implemented
               //make(map[string] Object,   0, 100), // Commented out until it's implemented
               make(map[string] Procedure),     // 0'd out until it's fully implemented
               make(map[string]^Library),      // 0'd out until it's fully implemented

               // Main procedure
               Procedure {"",
                          make(map[string]Parameter),
                          make([dynamic]RawType,        0, 100),
                          Scope{},
               }
    };

    for len(tokens) > 0 {
        token := eat();

        // This can be used for post-parse precedence checking
        has_ops := false;

        // If `::` (constant value)
        if (peek().kind == TokenKind.COLON && peek(1).kind == TokenKind.COLON) {
            discard(2);

            token = eat();

            temp_token := peek(2);

            // What the right side is. Can be either a NAMED token or constant value
            if (temp_token.kind == TokenKind.NAMED) {
                switch temp_token.variant.(NamedToken).name {
                    case "proc":
                        parse_procedure();
                }
            }
        }
    }

    return ast;
}