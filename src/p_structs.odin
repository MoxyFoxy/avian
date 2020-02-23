package avian

AST :: struct {
    name      : string,
    behaviors : map[string] Behavior,
    characters: map[string] Character,
    objects   : map[string] Object,
    procedures: map[string] Procedure,
    libraries : map[string]^Library,
    main      : Procedure,
}

Library :: AST;

Behavior :: struct {
    name      : string,
    members   : map[string]Parameter,
    traits    : map[string]Trait,
    procedures: map[string]Procedure,
}

Parameter :: struct {
    name: string,
    type: Type,
}

Type :: union {
    RawType,
    ParaPoly,
    Polyed,
}

RawType :: struct {
    name: string,
}

ParaPoly :: struct {
    name    : string,
    of_type : [dynamic]NPPType,
    and_type: [dynamic]NPPType,
    or_type : [dynamic]NPPType
}

NPPType :: union {
    RawType,
    Polyed,
}

Polyed :: struct {
    origin  : string,
    parapoly: [dynamic]^NPPType,
}

Trait :: union {
    BehaviorTrait,
    SoloTrait,
}

BehaviorTrait :: distinct Procedure;

Procedure :: struct {
    name        : string,
    parameters  : map[string]Parameter,
    return_types: [dynamic]NPPType,
    body        : Scope,
}

Scope :: struct {
    scope_type:  ScopeType,
    parent    : ^Scope,
    exprs     :  [dynamic]^Expression
}

ScopeType :: enum {
    PROCEDURE,
    IF_BLOCK, ELSEIF_BLOCK, ELSE_BLOCK,
    FOR, WHILE,
    DEFER,
    USING,
}

Expression :: union {
    OP,
    Not,
    VarCreation,
    Assignment, ConstAssign,
}

OP :: struct {
    left : ^Expression,
    right: ^Expression,
}

Not :: struct {
    expr: ^Expression,
}

VarCreation :: struct {
    name: string,
    type: NPPType,

    init: ^Expression // Nil if it's a declaration instead of an initialization
}

Assignment :: struct {
    name :  string,
    value: ^Expression,
}

ConstAssign :: struct {
    name : string,
    value: Constant,
}

Constant :: struct {
    value: union {
        string,
        Type,
    }
}

SoloTrait :: struct {
    name        : string,
    members     : map[string]MemberParam,
    parameters  : map[string]Parameter,
    return_types: [dynamic]NPPType,
    body        : Scope,
}

MemberParam :: struct {
    name: string,
    type: NPPType,
}

Character :: struct {
    name     : string,
    members  : map[string]MemberParam,
    behaviors: [dynamic]CharBehavior,
}

CharBehavior :: struct {
    name   : string,
    members: map[string]Member,
}

Member :: struct {
    name: string,
}

Object :: struct {
    name    : string,
    parapoly: map[string]Parameter,
    members : map[string]MemberParam,
}