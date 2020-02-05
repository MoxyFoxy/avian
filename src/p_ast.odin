package avian

// Globals
@(private="file")
tokens: [dynamic]Token;

@(private="file")
warning_queue: [dynamic]Warning;

@(private="file")
ast: AST;

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
    return char;
}

@(private="file")
discard :: inline proc(amount: int = 1) -> Token {
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
             "u32be", "u64be", "u128be", "f32be", "f64be", "char", "type",
             "type_id", "ctx":

            return true;

        case:
            return false;
    }
}

consume_parameter :: inline proc() -> Parameter {
    token = eat();
    name: string;

    if (token.kind != TokenKind.NAMED) {
        warning(&warning_queue, .P_PARAM_MISSING_NAME, file, token.line, token.offset);
        name = "--MALFORMED";
    }

    token = eat();

    if (token.kind != TokenKind.COLON) {
        warning(&warning_queue, .P_PARAM_MISSING_COLON, file, token.line, token.offset);
    }

    // TODO: Account for parametric polymorphism (parapoly)

    token = eat();
    type: Type;

    if (token.kind != TokenKind.NAMED) {
        warning(&warning_queue, .P_UNEXPECTED_TYPE_NAME, file, token.line, token.offset);
        type = RawType{"--MALFORMED"};
    }

    else {
        type = RawType{token.name};
    }

    return Parameter{name, type};
}

consume_return :: inline proc() -> RawType {

    // Possibility: Account for parametric polymorphism in return types?

    if (token.kind == TokenKind.NAMED) {
        return RawType{token.name};
    }

    else {
        warning(&warning_queue, .P_INVALID_RETURN_TYPE, file, token.line, token.offset);
        return RawType{"--MALFORMED"};
    }
}

consume_procedure :: inline proc() {
    if (check_for_keyword(token.name)) {
        warning(&warning_queue, .P_UNEXPECTED_KEYWORD, file, token.line, token.offset);
    }

    else {
        discard(3);

        name := token.name;

        procedure := Procedure {
                                name, // Procedure Name

                                make(map[string]Parameter, 0, 10), // Parameters
                                make([dynamic]RawType,     0, 3),  // Return Types

                                Scope { // Body
                                    ScopeType.PROCEDURE, // Scope Type

                                    make([dynamic]^Expression, 0, 100), // Expressions
                                    make([dynamic]^Scope,      0, 10),  // Child Scopes
                                }
                     };

        token = eat();

        if (token.kind != TokenKind.LEFT_PAREN) {
            warning(&warning_queue, .P_PROC_UNEXPECTED_TOKEN, file, token.line, token.offset);
        }

        else {
            token = eat();

            for token.kind != TokenKind.RIGHT_PAREN {
                append(&procedure.parameters, consume_parameter());

                token = eat();

                // If comma is not found, consume malformed parameters until closed
                if (token.kind != TokenKind.COMMA) {
                    warning(&warning_queue, .P_PARAM_UNEXPECTED_TOKEN, file, token.line, token.offset);

                    for {
                        token = peek();

                        if (token.kind == TokenKind.RIGHT_PAREN) {
                            discard();
                            break;
                        }

                        if (len(tokens) == 0) {
                            warning(&warning_queue, .P_UNEXPECTED_EOF, file, token.line, token.offset);
                            return procedure;
                        }

                        append(&procedure.parameters, Parameter{"--MALFORMED", "--MALFORMED"});
                    }

                    break;
                }
            }
        }

        // => is optional
        if (peek().kind == TokenKind.EQUALS && peek(1).kind == TokenKind.GREATER) {
            append(&procedure.return_types, consume_return());

            token = eat();

            // If comma is not found, consume malformed return types until closed by a scope
                if (token.kind != TokenKind.COMMA) {
                    warning(&warning_queue, .P_RETURN_UNEXPECTED_TOKEN, file, token.line, token.offset);

                    for {
                        token = peek();

                        if (token.kind == TokenKind.SCOPE_START) {
                            discard();
                            break;
                        }

                        if (len(tokens) == 0) {
                            warning(&warning_queue, .P_UNEXPECTED_EOF, file, token.line, token.offset);
                            return procedure;
                        }

                        append(&procedure.return_types, RawType{"--MALFORMED"});
                    }

                    break;
                }
        }

        else if (peek.kind == TokenKind.SCOPE_START) {
            // TODO: Parse scopes (aka parse normal expressions)
        }

        else {
            warning(&warning_queue, .P_PROC_UNEXPECTED_TOKEN, file, token.line, token.offset);
            return;
        }
    }
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

build_ast :: proc(package_name: string, file: u32, _tokens: [dynamic]Token, _warning_queue: [dynamic]Warning) -> AST {
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
        has_ops := false;

        if (peek().kind == TokenKind.COLON && peek(1).kind == TokenKind.COLON) {
            discard(2);

            token = eat();

            temp_token := peek(2);

            if (temp_token.kind == TokenKind.NAMED) {
                switch temp_token.name {
                    case "proc":
                        consume_procedure();
                }
            }
        }
    }
}