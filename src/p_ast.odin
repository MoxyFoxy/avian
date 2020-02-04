package avian

// Globals
tokens: [dynamic]Token;
warning_queue: [dynamic]Warning;
ast: AST;

@(private="file")
peek :: inline proc(int amount = 1) -> Token {
    return tokens[amount - 1];
}

@(private="file")
eat :: inline proc() -> Token {
    char  := tokens[0];
    tokens = tokens[1:];
    return char;
}

@(private="file")
discard :: inline proc(int amount = 1) -> Token {
    tokens = tokens[amount:];
}

consume_procedure :: proc() {

}

consume_operator :: proc(previous, current, next: Token) {
    switch current.kind {
        case TokenKind.ADD:
            append(&tokens, Add{previous, next});

        case TokenKind.SUB:
            append(&tokens, Sub{previous, next});

        case TokenKind.MUL:
            append(&tokens, Mul{previous, next});

        case TokenKind.DIV:
            append(&tokens, Div{previous, next});

        case TokenKind.MOD:
            append(&tokens, Mod{previous, next});
    }
}

build_ast :: proc(package_name: string, _tokens: [dynamic]Token, _warning_queue: [dynamic]Warning) -> AST {
    tokens = _tokens;
    warning_queue = _warning_queue;

    ast = AST {package_name,

               //make(map[string] Behavior, 0, 100), // Commented out until it's implemented
               //make(map[string] Object,   0, 100), // Commented out until it's implemented
               make(map[string]^Library,  0, 0),     // 0'd out until it's fully implemented

               Procedure {"",
                          make(map[string]Parameter, 0, 100),
                          make([dynamic]Type,        0, 100)
               }
    };

    for len(tokens) > 0 {
        token := eat();

        if (peek(1).kind == TokenKind.COLON && peek(2).kind == TokenKind.COLON) {
            discard(2);

            token = eat();

            if (token.kind == TokenKind.NAMED) {
                switch token.name {
                    case "proc":
                        consume_procedure();
                }
            }
        }
    }
}