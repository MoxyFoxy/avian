package avian

AST :: struct {
    name      : string,
    behaviors : [] Behavior,
    characters: [] Character,
    objects   : [] Object,
    procedures: [] Procedure,
    libraries : []^Library,
    main      : Procedure,
}

Library :: AST;

Behavior :: struct {
    name      : string,
    members   : []Parameter,
    traits    : []Trait,
    procedures: []Procedure,
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
    of_type : []NPPType,
    and_type: []NPPType,
    or_type : []NPPType
}

NPPType :: union {
    RawType,
    Polyed,
}

Polyed :: struct {
    origin  : string,
    parapoly: []^NPPType,
}

Trait :: union {
    BehaviorTrait,
    SoloTrait,
}

BehaviorTrait :: distinct Procedure;

Procedure :: struct {
    name        : string,
    parameters  : []Parameter,
    return_types: []NPPType,
    body        : Scope,
}

Scope :: struct {
    scope_type:  ScopeType,
    parent    : ^Scope,
    exprs     :  []^Expression
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
    members     : []MemberParam,
    parameters  : []Parameter,
    return_types: []NPPType,
    body        : Scope,
}

MemberParam :: struct {
    name: string,
    type: NPPType,
}

Character :: struct {
    name     : string,
    members  : []MemberParam,
    behaviors: []CharBehavior,
}

CharBehavior :: struct {
    name   : string,
    members: []Member,
}

Member :: struct {
    name: string,
}

Object :: struct {
    name    : string,
    parapoly: []Parameter,
    members : []MemberParam,
}