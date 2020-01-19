package avian

/*
 * TODO: Add new tokens based on the creation and change to Actor-Oriented Programming
 */

expression_type :: enum u8 {
    DECLARATION, INITIALIZATION, ASSIGNMENT,         // Initializations
    CLASS, ACTOR, STRUCT, UNION,                    // Type Initialization
    ADD, SUB, MUL, DIV, MOD, EXP, INV, COM,        // Math Operators
    GREATER, LESS, EQUAL,                         // Conditional Operators
    IF, ELSEIF, ELSE,                            // Conditionals
    SPLICE, SCOPE,                              // Brackets
    PROCEDURE, ACTION, PROC_CALL, ACT_CALL,    // Functions / Actions
    VAR, GLOBAL, CONST, CLASS_VAR, ACTOR_VAR, // Variables
    IMPORT, IMPORTAS,                        // Imports
    TYPE, CONST_TYPE,                       // Types
}

Expression :: union ---;

Type :: struct {
    name      :    string,
    parameters: ^[]Type,
}

// Initializations

Init :: union {
    Declaration,
    Initialization,
}

Declaration :: struct {
    name:  string,
    type: ^Type,
}

Initialization :: struct {
    name :  string,
    type : ^Type,
    value: ^Expression,
}

Assignment :: struct {
    variable:  string,
    value   : ^Expression,
}

// Type Initializations

Class :: struct {
    name    :    string,
    parents : ^[]string,
    _cast   : ^[]string,
    pub_dat : ^[]Init,
    hidden  : ^[]Init,
    actions : ^[]Expression,
}

Actor :: struct {
    name   :    string,
    parents: ^[]Actor,
    actions: ^[]Action,
}

Struct :: struct {
    name:    string,
    data: ^[]Init,
}

Union :: struct {
    name :    string,
    types: ^[]string,
}

// Math Operators

Operator :: struct {
    left : ^Expression,
    right: ^Expression,
}

Add :: Operator;
Sub :: Operator;

Mul :: Operator;
Div :: Operator;
Mod :: Operator;

Exp :: Operator;

Inv :: Operator;
Com :: Operator;

// Conditional Operators

Greater :: Operator;
Less    :: Operator;
Equal   :: Operator;

Great_Equal :: Operator;
Less_Equal  :: Operator;

Raw_Greater :: Operator;
Raw_Less    :: Operator;
Raw_Equal   :: Operator;

Raw_Great_Equal :: Operator;
Raw_Less_Equal  :: Operator;

// Conditionals

Else :: union {
    _Else,
    Else_If,
}

If :: struct {
    expression: ^Operator,
    _else     : ^Else,
    body      : ^Scope,
}

_Else :: struct {
    body: ^Scope,
}

Else_If :: If;

// Brackets

Splice :: struct {
    start: ^Expression,
    end  : ^Expression,
    step : ^Expression,
}

Scope :: struct {
    body: ^[]Expression,
}

Label :: struct {
    name:  string,
    body: ^Scope,
}

// Functions / Actions

Param :: struct {
    name:  string,
    type: ^Type,
}

Procedure :: struct {
    name      :    string,
    parameters: ^[]Param,
    body      : ^  Scope
}

Action :: struct {
    name      :    string,
    parameters: ^[]Param,
    body      : ^  Scope,
}

Proc_Call :: struct {
    name      : string,
    parameters: ^[]Expression,
}

Act_Call :: struct {
    name      : string,
    actor     : string,
    parameters: ^[]Expression,
}

// Variables

Global :: Init;

Const :: struct {
    name :  string,
    value:  string,
}

// Imports

Import :: struct {
    name: string,
}

Import_As :: struct {
    name : string,
    alias: string,
}

// Types

Type :: struct {
    name: string,
}

Const_Type :: struct {
    name: string,
}