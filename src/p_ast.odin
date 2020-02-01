package avian

AST :: struct {
    name     : string,
    behaviors: [dynamic]Behavior,
    objects  : [dynamic]Object,
    libraries: map[string]^Library,
    main     : Procedure,
}

Library :: AST;

Object :: struct {
    name   :  string,
    members:  [dynamic]Member,
    parent : ^ObjectParent,
}

ObjectParent :: struct {
    name   : string,
    members: [dynamic]Member,
}

Member :: struct {
    name: string,
    type: Type,
}

Type :: union {
    BuiltinType, // In p_builtins.odin
    Object,
}

Behavior :: struct {
    name  : string,
    traits: [dynamic]Trait,
    procs : [dynamic]Procedure,
}

Scope :: union {
    Object,
    Behavior,
    Trait,
    Procedure,
}

Procedure :: struct {
    name       : string,
    parameters : [dynamic]Parameter,
    return_vals: [dynamic]Type,
}

Trait :: struct {
    name       : string,
    member_refs: [dynamic]TraitMember,
    parameters : [dynamic]Parameter,
}

Parameter :: struct {
    name: string,
    type: Type,
}

TraitMember :: Member;

// Globals
tokens: [dynamic]Token;
warning_queue: [dynamic]Warning;
ast: AST;

build_ast :: proc (_tokens: [dynamic]Token, _warning_queue: [dynamic]Warning) -> AST {
    tokens = _tokens;
    warning_queue = _warning_queue;

    ast = AST {"",

               make([dynamic]Behavior,   0, 100),
               make([dynamic]Object,     0, 100),
               make(map[string]^Library, 0, 100),

              Procedure {"",
                         make([dynamic]Parameter, 0, 100),
                         make([dynamic]Type,      0, 100)
              }
    };

    for len(tokens) > 0 {
        token := tokens[0];


    }
}