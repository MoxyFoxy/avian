#include <vector>

enum ExpressionType {
    INITIALIZATION, ARRAYINIT, ASSIGNMENT,      // Initializations
    CLASSINIT, INTERFACEINIT,                  // Class and Interface Initialization
    ADD, SUB, MUL, DIV, MOD, EXP,             // Math Operators
    GREATER, LESS, EQUAL, INV, COM,          // Conditional Operators
    IF, ELSEIF, ELSE,                       // Conditionals
    SPLICE, CURLY,                         // Brackets
    FUNCTION, METHOD, CALL, METHODCALL,   // Functions / Methods
    VARIABLE, CLASSVAR, IMPORT, IMPORTAS // Variables and Imports
};

// Base Expression struct
struct Expression {
    int type;
};

/*
 * Initializations
 */

struct Initialization : Expression {
    const NamedToken* name;

    type = ExpressionType::INITIALIZATION;
};

struct ArrayInitialization : Initialization {
    const int arraySize;

    type = ExpressionType::ARRAYINIT;
};

struct Assignment : Initialization {
    const Expression* assignment;

    type = ExpressionType::ASSIGNMENT;
};

struct ClassInit : Initialization {
    const NamedToken* extends;
    const NamedToken* implements;

    const CurlyExpression* curly;

    type = ExpressionType::CLASSINIT;
};

struct InterfaceInit : Initialization {
    const NamedToken* implements;
    
    const CurlyExpression* curly;

    type = ExpressionType::INTERFACEINIT;
};

/*
 * Math Operators
 */

struct Operator : Expression {
    const Expression* left;
    const Expression* right;
};

struct Add : Operator {
    type = ExpressionType::ADD;
};

struct Sub : Operator {
    type = ExpressionType::SUB;
};

struct Mul : Operator {
    type = ExpressionType::MUL;
};

struct Div : Operator {
    type = ExpressionType::DIV;
};

struct Mod : Operator {
    type = ExpressionType::MOD;
};

struct Exp: Operator {
    type = ExpressionType::EXP;
};

/*
 * Conditional Operators
 */

struct Greater : Operator {
    type = ExpressionType::GREATER;
};

struct Less : Operator {
    type = ExpressionType::LESS;
};

struct Equal : Operator {
    type = ExpressionType::EQUAL;
}

struct Inv : Operator {
    type = ExpressionType::INV;
};

struct Com : Operator {
    type = ExpressionType::COM;
};

/*
 * Conditionals
 */

struct Conditional : Expression {
    const CurlyExpression* curly;
};

struct If : Conditional {
    const Expression* condition;

    type = ExpressionType::IF;
};

struct ElseIf : If {
    type = ExpressionType::ELSEIF;
};

struct Else : Conditional {
    type = ExpressionType::ELSE;
};

/*
 * Loops
 */

struct Loop : Expression {
    const CurlyExpression* curly;

    type = ExpressionType::LOOP;
};

struct For : Loop {
    const Expression* iterator;
    const Expression* condition;
    const Expression* iteration;

    type = ExpressionType::FOR;
};

struct ForIn : Loop {
    const NamedToken* variable;
    const Expression* collection;

    type = ExpressionType::FORIN;
};

struct While : Loop {
    const Expression* condition;
};

/*
 * Brackets
 */

struct Splice : Expression {
    const Expression* leftSplice;
    const Expression* rightSplice = -1;
    const Expression* step = -1;

    type = ExpressionType::SPLICE;
};

struct CurlyExpression : Expression {
    const Expression* statements [];

    type = ExpressionType::CURLY;
};

/*
 * Functions / Methods
 */

struct Function : Expression {
    const NamedToken* funcname;
    const NamedToken* parameters [];

    type = ExpressionType::FUNCTION;
};

struct Method : Function {
    const NamedToken* classname;

    type = ExpressionType::METHOD;
};

struct Call : Expression {
    const NamedToken* funcname;
    const Expression* parameters [];

    type = ExpressionType::CALL;
};

struct MethodCall : Call {
    const NamedToken* classname;

    type = ExpressionType::METHODCALL;
};

/*
 * Variables and imports
 */

struct Variable : Expression {
    const NamedToken* vartype;
    const NamedToken* varname;

    const bool isStatic;
    const bool isRef;

    type = ExpressionType::VARIABLE;
};

struct ClassVariable : Variable {
    const bool hasGetter;
    const bool hasSetter;

    type = ExpressionType::CLASSVAR;
};

struct Import : Expression {
    const StringToken* link;
    const NamedToken* imports [];

    type = ExpressionType::IMPORT;
};

struct ImportAs : Import {
    const NamedToken* asnames [];

    type = ExpressionType::IMPORTAS;
};