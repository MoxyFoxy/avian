package avian

AST :: struct {
    name      : string,
    //behaviors : map[string] Behavior, // Commented out until it's implemented
    //objects   : map[string] Object,   // Commented out until it's implemented
    procedures: map[string] Procedure,
    libraries : map[string]^Library,
    main      : Procedure,
}

Library :: AST;

Procedure :: struct {
    name        : string,
    parameters  : map[string]Parameter,
    return_types: [dynamic]RawType,
    body        : Scope,
}

Scope :: struct {
    scope_type  : ScopeType,
    expressions : [dynamic]^Expression,
    child_scopes: [dynamic]^Scope,
}

ScopeType :: enum {
    PROCEDURE,
    IF_BLOCK,
    FOR,
    WHILE,
    DEFER,
    USING,      
}

Parameter :: struct {
    name: string,
    type: Type,
}

Type :: union {
    Parapoly,
    RawType,
}

ParaPoly :: struct {
    type_name: string,
    of_type  : RawType, // The / operator on types (parapoly)
    or_type  : RawType, // The | operator on types (parapoly)
    not_type : RawType, // The ! operator on types (parapoly)
}

RawType :: struct {
    name: string,
}

Expression :: union {
    OP,
    Not,
    Declaration,
    Initialization,
    Assignment,
}

OP :: struct {
    left : Expression,
    right: Expression,
}

Add :: OP;
Sub :: OP;
Mul :: OP;
Div :: OP;
Mod :: OP;

And :: OP;
Or  :: OP;

Not :: struct {
    right: Expression,
}

Declaration :: struct {
    var_name: string,
    type    : RawType,
}