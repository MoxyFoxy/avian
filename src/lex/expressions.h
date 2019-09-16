#include <vector>

enum ExpressionType {
    INITIALIZATION, ARRAYINIT, ASSIGNMENT, // Initializations
    ADD, SUB, MUL, DIV, MOD,              // Math Operators
    GREATER, LESS, INV, COM,             // Conditional Operators
    IF, ELSEIF, ELSE,                   // Conditionals
    SPLICE, CURLY,                     // Brackets
    CALL, METHODCALL,                 // Functions / Methods
    VARIABLE, IMPORT, IMPORTAS       // Variables and Imports
};

// Base Expression struct
struct Expression {
    const int type;
};

/*
 * Initializations
 */

struct Initialization : Expression {
    const KeywordToken* vartype;
    const NamedToken* varname;

    type = ExpressionType::INITIALIZATION;
};

struct ArrayInitialization : Expression {
    const KeywordToken* vartype;
    const NamedToken* varname;
    const int arraySize;

    type = ExpressionType::ARRAYINIT;
};

struct Assignment : Expression {
    const NamedToken* varname;
    const Expression* assignment;

    type = ExpressionType::ASSIGNMENT;
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

/*
 * Conditional Operators
 */

struct Greater : Operator {
    type = ExpressionType::GREATER;
};

struct Less : Operator {
    type = ExpressionType::LESS;
};

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

    type = ExpressionType::VARIABLE;
};

struct Import : Expression {
    const NamedToken* imports [];

    type = ExpressionType::IMPORT;
};

struct ImportAs : Import {
    const NamedToken* asnames [];

    type = ExpressionType::IMPORTAS;
};