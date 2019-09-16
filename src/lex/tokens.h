#pragma once

#include <string>

enum Tokens {
    T_EOF,

    // Types
    T_STRING, T_CHAR, T_BYTE, T_BOOL, T_NULL, T_INT, T_INT8, T_INT16, T_INT64, T_UNSIGNED, T_FLOAT, T_VAR, T_FUNC,

    // Math
    ADD, SUB, MUL, DIV, MOD,

    // Byte
    GREATER, LESS, INV, COM,

    // Additives
    STATIC, REF, DEREF, NEW, DELETE, FINAL, GLOBAL, DECORATOR,

    // Functions and classes
    DEF, GET, SET, CLASS, EXTENDS, SELF, SUPER, ABSTRACT, INTERFACE, IMPLEMENTS, RETURN, HALT,

    // Conditionals
    IF, ELSE, ELIF, AND, OR, XOR, NOT, IS, IN,

    // Loops
    FOR, WHILE,

    // Errors
    ERROR, RAISE, TRY, EXCEPT,

    // Miscellaneous
    IMPORT, AS, ASSIGNMENT, OPEN_PAREN, CLOSED_PAREN, OPEN_CURLY, CLOSED_CURLY, METHOD_CALL, EOL, OPEN_BRACKET, CLOSED_BRACKET, LOCAL_VAR, GLOBAL_VAR
};

class Token {
    public:
        int tokn_val;

        Token(int tokn_val) {
            this->tokn_val = tokn_val;
        }

        virtual std::string tostring () = 0;
};

class KeywordToken : public Token {
    public:
        KeywordToken(int tokn_val) : Token(tokn_val) {}

        ~KeywordToken() {}

        virtual std::string tostring() {
            return std::string("KeywordToken: ") + std::to_string(this->tokn_val) + std::string("\n");
        }
};

class NamedToken : public Token {
    public:
        std::string tokn_name;

        NamedToken(int tokn_val, std::string tokn_name) : Token(tokn_val) {
            this->tokn_name = tokn_name;
        }

        virtual ~NamedToken() {}

        virtual std::string tostring() {
            return std::string("NamedToken: ") + this->tokn_name + std::string("\n");
        }
};

class StringToken : public Token {
    public:
        std::string value;

        StringToken(int tokn_val, std::string value) : Token(tokn_val) {
            this->value = value;
        }

        virtual ~StringToken() {}

        virtual std::string tostring() {
            return std::string("StringToken: ") + this->value + std::string("\n");
        }
};

class CharToken : public Token {
    public:
        char value;

        CharToken(int tokn_val, char& value) : Token(tokn_val) {
            this->value = value;
        }

        virtual ~CharToken() {}

        virtual std::string tostring() {
            return std::string("CharToken: ") + this->value + std::string("\n");
        }
};