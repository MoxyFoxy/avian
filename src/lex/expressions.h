#include <vector>

enum ExpressionType {
    INITIALIZATION, ARRAYINIT, ASSIGNMENT,
    ADD, SUB, MUL, DIV, MOD,
    GREATER, LESS, INV, COM,
    SPLICE,
    CALL, METHODCALL,
}

struct Expression {}

struct Initialization : Expression {
    const KeywordToken* type;
    const NamedToken* name;

    const int type = ExpressionType::INITIALIZATION;
}

struct ArrayInitialization : Expression {
    const KeywordToken* type;
    const NamedToken* name;
    const int arraySize;

    const int type = ExpressionType::ARRAYINIT;
}

struct Assignment : Expression {
    const NamedToken* name;
    const Expression* assignment;

    const int type = ExpressionType::ASSIGNMENT;
}



struct Operator : Expression {
    const Expression* left;
    const Expression* right;
}

struct Add : Operator {
    const int type = ExpressionType::ADD;
}

struct Sub : Operator {
    const int type = ExpressionType::SUB;
}

struct Mul : Operator {
    const int type = ExpressionType::MUL;
}

struct Div : Operator {
    const int type = ExpressionType::DIV;
}

struct Mod : Operator {
    const int type = ExpressionType::MOD;
}



struct Greater : Operator {
    const int type = ExpressionType::GREATER;
}

struct Less : Operator {
    const int type = ExpressionType::LESS;
}

struct Inv : Operator {
    const int type = ExpressionType::INV;
}

struct Com : Operator {
    const int type = ExpressionType::COM;
}



struct Splice : Expression {
    const Expression* leftSplice;
    const Expression* rightSplice;
    const Expression* step;

    const int type = ExpressionType::SPLICE;
}



struct Call : Expression {
    const NamedToken* funcname;
    const Expression* parameters [];

    const int type = ExpressionType::CALL;
}

struct MethodCall : Call {
    const NamedToken* classname;

    const int type = ExpressionType::METHODCALL;
}