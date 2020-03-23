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
             "type_id", "ctx", "of", "and", "or":

            return true;

        case:
            return false;
    }
}

// Parses an NPPType value
// TODO: Account for pointers and arrays
parse_npptype :: proc() -> NPPType {
    if (peek(1).kind == TokenKind.LEFT_PAREN) {
        return cast(NPPType)parse_polyed();
    }

    else {
        return cast(NPPType)parse_rawtype();
    }
}

// Parses a RawType value
// TODO: Account for pointers and arrays
parse_rawtype :: proc() -> RawType {
    token := eat();

    if (token.kind == TokenKind.NAMED) {
        return RawType{token.variant.(NamedToken).name};
    }

    else {
        warning(warning_queue, .P_UNEXPECTED_TOKEN_TYPE,
                file, token.line, token.offset);
    }

    return RawType{"--MALFORMED"};
}

//// Potential bug-bringer. To be determined \\\\
// Parses a Polyed type
// TODO: Account for pointers and arrays
parse_polyed :: proc() -> Polyed {
    token := eat();

    if (token.kind == TokenKind.NAMED) {
        origin := token.variant.(NamedToken).name;
        token = eat();

        if (token.kind == TokenKind.LEFT_PAREN) {
            token = eat();

            npp_types := make([dynamic]^NPPType, 0, 5);

            for token.kind == TokenKind.RIGHT_PAREN {
                npp := parse_npptype();
                append(&npp_types, &npp);

                if (peek().kind == TokenKind.COMMA) {
                    discard();
                }
            }

            if (len(npp_types) <= 0) {
                warning(warning_queue, .P_POLYED_MISSING_PARAPOLY,
                        file, token.line, token.offset);
            }
            
            return Polyed{origin, npp_types[:]};
        }

        else {
            warning(warning_queue, .P_UNEXPECTED_TOKEN_TYPE,
                    file, token.line, token.offset);
        }
    }

    else {
        warning(warning_queue, .P_UNEXPECTED_TOKEN_TYPE,
                file, token.line, token.offset);
    }

    return Polyed{"--MALFORMED", nil};
}

// TODO: Account for pointers and arrays
parse_parapoly :: proc() -> ParaPoly {
    token := eat();

    if (token.kind == TokenKind.QUESTION) {
        token = peek();

        if (token.kind == TokenKind.NAMED) {
            name := token.variant.(NamedToken).name;

            of_type  := make([dynamic]NPPType, 0, 5);
            and_type := make([dynamic]NPPType, 0, 5);
            or_type  := make([dynamic]NPPType, 0, 5);

            discard();
            token = peek();

            for token.kind == TokenKind.NAMED {
                switch token.variant.(NamedToken).name {
                    case "of" : append(&of_type,  parse_npptype());
                    case "and": append(&and_type, parse_npptype());
                    case "or" : append(&or_type,  parse_npptype());

                    case:
                        warning(warning_queue, .P_PARAPOLY_UNEXPECTED_TOKEN,
                                file, token.line, token.offset);
                        discard();
                }
            }

            return ParaPoly{name, of_type[:], and_type[:], or_type[:]};
        }

        else {
            warning(warning_queue, .P_UNEXPECTED_TOKEN_TYPE,
                    file, token.line, token.offset);
        }
    }

    else {
        warning(warning_queue, .P_PARAPOLY_MISSING_QUESTION,
                file, token.line, token.offset);
    }

    return ParaPoly{"--MALFORMED", nil, nil, nil};
}

build_ast :: proc(package_name: string, _file: u32, _tokens: []Token, _warning_queue: [dynamic]Warning) -> AST {
    tokens = _tokens;
    warning_queue = _warning_queue;
    file = _file;

    ast_name  := package_name;
    ast_bvrs  := make([dynamic]Behavior,  0, 100);
    ast_chars := make([dynamic]Character, 0, 100);
    ast_objs  := make([dynamic]Object,    0, 100);
    ast_procs := make([dynamic]Procedure, 0, 100);
    ast_libs  := make([dynamic]^Library,  0, 100);
    ast_main: Procedure;

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
    ast: AST = nil;
    return ast;
}