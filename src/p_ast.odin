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

// Should always be `NAMED`, `COLON`, `TYPE` or `name: type`
consume_parameter :: inline proc() -> Parameter {
    token = eat();
    name: string;

    // Parameter name
    if (token.kind != TokenKind.NAMED) {
        warning(warning_queue, .P_PARAM_MISSING_NAME, file, token.line, token.offset);
        name = "--MALFORMED";
    }

    else {
        name = token.variant.(NamedToken).name;
    }

    token = eat();

    if (token.kind != TokenKind.COLON) {
        warning(warning_queue, .P_PARAM_MISSING_COLON, file, token.line, token.offset);
    }

    // TODO: Account for parametric polymorphism (parapoly)

    token = eat();
    type: Type;

    // Type
    if (token.kind != TokenKind.NAMED) {
        warning(warning_queue, .P_UNEXPECTED_TYPE_NAME, file, token.line, token.offset);
        type = RawType{"--MALFORMED"};
    }

    else {
        type = RawType{token.variant.(NamedToken).name};
    }

    return Parameter{name, type};
}

consume_return :: inline proc() -> RawType {

    // Possibility: Account for parametric polymorphism in return types?

    if (token.kind == TokenKind.NAMED) {
        return RawType{token.variant.(NamedToken).name};
    }

    else {
        warning(warning_queue, .P_INVALID_RETURN_TYPE, file, token.line, token.offset);
        return RawType{"--MALFORMED"};
    }
}

consume_procedure :: inline proc() -> Procedure {
    if (check_for_keyword(token.variant.(NamedToken).name)) {
        warning(warning_queue, .P_UNEXPECTED_KEYWORD, file, token.line, token.offset);
    }

    else {
        discard(3);

        name := token.variant.(NamedToken).name;

        procedure := Procedure {
                                name, // Procedure Name

                                make(map[string]Parameter), // Parameters
                                make([dynamic]RawType,     0, 3),  // Return Types

                                Scope { // Body
                                    ScopeType.PROCEDURE, // Scope Type

                                    make([dynamic]^Expression, 0, 100), // Expressions
                                    make([dynamic]^Scope,      0, 10),  // Child Scopes
                                }
        };

        token = eat();

        if (token.kind != TokenKind.LEFT_PAREN) {
            warning(warning_queue, .P_PROC_UNEXPECTED_TOKEN, file, token.line, token.offset);
        }

        else {
            token = eat();

            // Consuming parameters
            for token.kind != TokenKind.RIGHT_PAREN {
                temp_parameter := consume_parameter();
                procedure.parameters[temp_parameter.name] = temp_parameter;

                token = eat();

                // If comma is not found, consume malformed parameters until closed
                if (token.kind != TokenKind.COMMA) {
                    warning(warning_queue, .P_PARAM_UNEXPECTED_TOKEN, file, token.line, token.offset);

                    for {
                        token = peek();

                        // If it's closed by a right parenthesis, then close
                        if (token.kind == TokenKind.RIGHT_PAREN) {
                            discard();
                            break;
                        }

                        // If we reach the end
                        if (len(tokens) == 0) {
                            warning(warning_queue, .P_UNEXPECTED_EOF, file, token.line, token.offset);
                            return procedure;
                        }

                        procedure.parameters["--MALFORMED"] = Parameter{"--MALFORMED", RawType{"--MALFORMED"}};
                    }

                    break;
                }
            }
        }

        // Parse return values
        // => is optional
        if (peek().kind == TokenKind.EQUAL && peek(1).kind == TokenKind.GREATER) {
            append(&procedure.return_types, consume_return());

            token = eat();

            // If comma is not found, consume malformed return types until closed by a scope
            if (token.kind != TokenKind.COMMA) {
                warning(warning_queue, .P_RETURN_UNEXPECTED_TOKEN, file, token.line, token.offset);

                for {
                    token = peek();

                    // SCOPE_START is `{`
                    if (token.kind == TokenKind.SCOPE_START) {
                        discard();
                        break;
                    }

                    // If we reach the end before a scope starting
                    if (len(tokens) == 0) {
                        warning(warning_queue, .P_UNEXPECTED_EOF, file, token.line, token.offset);
                        return procedure;
                    }

                    // Means we neither got a scope nor a file end
                    append(&procedure.return_types, RawType{"--MALFORMED"});
                }
            }
        }

        else if (peek().kind == TokenKind.SCOPE_START) {
            // TODO: Parse scopes (aka parse normal expressions)
        }

        else {
            warning(warning_queue, .P_PROC_UNEXPECTED_TOKEN, file, token.line, token.offset);
            return Procedure{name, nil, nil, Scope{}};
        }
    }

    return Procedure{"--MALFORMED", nil, nil, Scope{}};
}

// TODO: Implement proper operator consumption
/*consume_operator :: proc(previous, current, next: Token) {
    switch current.kind {
        case TokenKind.ADD:
            append(&statement, Add{previous, next});

        case TokenKind.SUB:
            append(&statement, Sub{previous, next});

        case TokenKind.MUL:
            append(&statement, Mul{previous, next});

        case TokenKind.DIV:
            append(&statement, Div{previous, next});

        case TokenKind.MOD:
            append(&statement, Mod{previous, next});
    }
}*/

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
                        consume_procedure();
                }
            }
        }
    }

    return ast;
}