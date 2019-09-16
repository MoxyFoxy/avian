#include <vector>
#include <istream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <iostream>
#include <ctype.h>

#include "tokens.h"
#include "tokenclasses.h"

std::vector<Token*> tokenize(std::istream& input) {
    std::vector<Token*> tokens;
    std::string tempToken;
    bool inString = false;
    char c = 'a';

    while (!input.eof()) {
        c = input.get();
        bool switchSuccess = false;

        if (!inString) {
            switchSuccess = true;
            char val;

            switch (c) {
                case ';':
                    tokens.push_back(new KeywordToken(EOL));
                    break;

                case '+':
                    tokens.push_back(new KeywordToken(ADD));
                    break;

                case '-':
                    tokens.push_back(new KeywordToken(SUB));
                    break;

                case '*':
                    tokens.push_back(new KeywordToken(MUL));
                    break;

                case '/':
                    if (input.peek() == '/') {
                        while (val != '\n') {
                            input >> val;
                        }
                    }

                    else {
                        tokens.push_back(new KeywordToken(DIV));
                    }

                    break;

                case '%':
                    tokens.push_back(new KeywordToken(MOD));
                    break;

                case '>':
                    tokens.push_back(new KeywordToken(GREATER));
                    break;

                case '<':
                    tokens.push_back(new KeywordToken(LESS));
                    break;

                case '=':
                    tokens.push_back(new KeywordToken(ASSIGNMENT));
                    break;

                case '@':
                    tokens.push_back(new KeywordToken(DECORATOR));
                    break;

                case '\"':
                    if (inString) {
                        tokens.push_back(new StringToken(-1, tempToken));
                        tempToken = "";
                    }

                    inString = !inString;
                    break;

                case '\'':
                    input >> val;

                    if (input.peek() != '\'') {
                        throw std::exception();
                    }

                    tokens.push_back(new CharToken(-1, val));
                    input >> val;
                    break;

                case '(':
                    tokens.push_back(new KeywordToken(OPEN_PAREN));
                    break;

                case ')':
                    tokens.push_back(new KeywordToken(CLOSED_PAREN));
                    break;

                case '[':
                    tokens.push_back(new KeywordToken(OPEN_BRACKET));
                    break;

                case ']':
                    tokens.push_back(new KeywordToken(CLOSED_BRACKET));
                    break;

                case '{':
                    tokens.push_back(new KeywordToken(OPEN_CURLY));
                    break;

                case '}':
                    tokens.push_back(new KeywordToken(CLOSED_CURLY));
                    break;

                case '.':
                    tokens.push_back(new KeywordToken(METHOD_CALL));
                    break;

                case ' ':
                    break;

                case '\n':
                    break;

                case '\t':
                    break;

                default:
                    switchSuccess = false;
            }

            if (switchSuccess) {
                if (!(tempToken.compare("") == 0)) {
                    tokens.push_back(new NamedToken(-3, tempToken));
                    tempToken = "";
                }
            }
        }

        if (!switchSuccess && (isalnum(c) || c == '!')) {
            tempToken += c;

            // Types

            if (!isalnum(input.peek()) && input.peek() != '!') {
                if (tempToken.compare("string") == 0) {
                    tokens.push_back(new KeywordToken(T_STRING));
                    tempToken = "";
                }

                else if (tempToken.compare("char") == 0) {
                    tokens.push_back(new KeywordToken(T_CHAR));
                    tempToken = "";
                }

                else if (tempToken.compare("byte") == 0) {
                    tokens.push_back(new KeywordToken(T_BYTE));
                    tempToken = "";
                }

                else if (tempToken.compare("bool") == 0) {
                    tokens.push_back(new KeywordToken(T_BOOL));
                    tempToken = "";
                }

                else if (tempToken.compare("null") == 0) {
                    tokens.push_back(new KeywordToken(T_NULL));
                    tempToken = "";
                }

                else if (tempToken.compare("int") == 0) {
                    tokens.push_back(new KeywordToken(T_INT));
                    tempToken = "";
                }

                else if (tempToken.compare("int8") == 0) {
                    tokens.push_back(new KeywordToken(T_INT8));
                    tempToken = "";
                }

                else if (tempToken.compare("int16") == 0) {
                    tokens.push_back(new KeywordToken(T_INT16));
                    tempToken = "";
                }

                else if (tempToken.compare("int64") == 0) {
                    tokens.push_back(new KeywordToken(T_INT64));
                    tempToken = "";
                }

                else if (tempToken.compare("unsigned") == 0) {
                    tokens.push_back(new KeywordToken(T_UNSIGNED));
                    tempToken = "";
                }

                else if (tempToken.compare("float") == 0) {
                    tokens.push_back(new KeywordToken(T_FLOAT));
                    tempToken = "";
                }

                else if (tempToken.compare("var") == 0) {
                    tokens.push_back(new KeywordToken(T_VAR));
                    tempToken = "";
                }

                else if (tempToken.compare("class") == 0) {
                    tokens.push_back(new KeywordToken(CLASS));
                    tempToken = "";
                }

                else if (tempToken.compare("func") == 0) {
                    tokens.push_back(new KeywordToken(T_FUNC));
                    tempToken = "";
                }

                // Bytes

                else if (tempToken.compare("inv") == 0) {
                    tokens.push_back(new KeywordToken(INV));
                    tempToken = "";
                }

                else if (tempToken.compare("com") == 0) {
                    tokens.push_back(new KeywordToken(COM));
                    tempToken = "";
                }

                // Additives

                else if (tempToken.compare("static") == 0) {
                    tokens.push_back(new KeywordToken(STATIC));
                    tempToken = "";
                }

                else if (tempToken.compare("ref") == 0) {
                    tokens.push_back(new KeywordToken(REF));
                    tempToken = "";
                }

                else if (tempToken.compare("deref") == 0) {
                    tokens.push_back(new KeywordToken(DEREF));
                    tempToken = "";
                }

                else if (tempToken.compare("new") == 0) {
                    tokens.push_back(new KeywordToken(NEW));
                    tempToken = "";
                }

                else if (tempToken.compare("delete") == 0) {
                    tokens.push_back(new KeywordToken(DELETE));
                    tempToken = "";
                }

                else if (tempToken.compare("final") == 0) {
                    tokens.push_back(new KeywordToken(FINAL));
                    tempToken = "";
                }

                else if (tempToken.compare("global") == 0) {
                    tokens.push_back(new KeywordToken(GLOBAL));
                    tempToken = "";
                }

                else if (tempToken.compare("def") == 0) {
                    tokens.push_back(new KeywordToken(DEF));
                    tempToken = "";
                }

                else if (tempToken.compare("get") == 0) {
                    tokens.push_back(new KeywordToken(GET));
                    tempToken = "";
                }

                else if (tempToken.compare("set") == 0) {
                    tokens.push_back(new KeywordToken(SET));
                    tempToken = "";
                }

                else if (tempToken.compare("extends") == 0) {
                    tokens.push_back(new KeywordToken(EXTENDS));
                    tempToken = "";
                }

                else if (tempToken.compare("self") == 0) {
                    tokens.push_back(new KeywordToken(SELF));
                    tempToken = "";
                }

                else if (tempToken.compare("super") == 0) {
                    tokens.push_back(new KeywordToken(SUPER));
                    tempToken = "";
                }

                else if (tempToken.compare("abstract") == 0) {
                    tokens.push_back(new KeywordToken(ABSTRACT));
                    tempToken = "";
                }

                else if (tempToken.compare("interface") == 0) {
                    tokens.push_back(new KeywordToken(INTERFACE));
                    tempToken = "";
                }

                else if (tempToken.compare("implements") == 0) {
                    tokens.push_back(new KeywordToken(IMPLEMENTS));
                    tempToken = "";
                }

                else if (tempToken.compare("return") == 0) {
                    tokens.push_back(new KeywordToken(RETURN));
                    tempToken = "";
                }

                else if (tempToken.compare("halt") == 0) {
                    tokens.push_back(new KeywordToken(HALT));
                    tempToken = "";
                }

                // Conditionals

                else if (tempToken.compare("if") == 0) {
                    tokens.push_back(new KeywordToken(IF));
                    tempToken = "";
                }

                else if (tempToken.compare("else") == 0) {
                    tokens.push_back(new KeywordToken(ELSE));
                    tempToken = "";
                }

                else if (tempToken.compare("elif") == 0) {
                    tokens.push_back(new KeywordToken(ELIF));
                    tempToken = "";
                }

                else if (tempToken.compare("and") == 0) {
                    tokens.push_back(new KeywordToken(AND));
                    tempToken = "";
                }

                else if (tempToken.compare("or") == 0) {
                    tokens.push_back(new KeywordToken(OR));
                    tempToken = "";
                }

                else if (tempToken.compare("xor") == 0) {
                    tokens.push_back(new KeywordToken(XOR));
                    tempToken = "";
                }

                else if (tempToken.compare("is") == 0) {
                    tokens.push_back(new KeywordToken(IS));
                    tempToken = "";
                }

                else if (tempToken.compare("in") == 0) {
                    tokens.push_back(new KeywordToken(IN));
                    tempToken = "";
                }

                // Loops

                else if (tempToken.compare("for") == 0) {
                    tokens.push_back(new KeywordToken(FOR));
                    tempToken = "";
                }

                else if (tempToken.compare("while") == 0) {
                    tokens.push_back(new KeywordToken(WHILE));
                    tempToken = "";
                }

                // Errors

                else if (tempToken.compare("error") == 0) {
                    tokens.push_back(new KeywordToken(ERROR));
                    tempToken = "";
                }

                else if (tempToken.compare("raise") == 0) {
                    tokens.push_back(new KeywordToken(RAISE));
                    tempToken = "";
                }

                else if (tempToken.compare("try") == 0) {
                    tokens.push_back(new KeywordToken(TRY));
                    tempToken = "";
                }

                else if (tempToken.compare("except") == 0) {
                    tokens.push_back(new KeywordToken(EXCEPT));
                    tempToken = "";
                }

                // Miscellaneous

                else if (tempToken.compare("import") == 0) {
                    tokens.push_back(new KeywordToken(IMPORT));
                    tempToken = "";
                }

                else if (tempToken.compare("as") == 0) {
                    tokens.push_back(new KeywordToken(AS));
                    tempToken = "";
                }
            }
        }

        else {
            if (tempToken.compare("") != 0) {
                tokens.push_back(new NamedToken(-1, tempToken));
                tempToken = "";
            }
        }
    }

    tokens.push_back(new KeywordToken(T_EOF));

    return tokens;
}

int main(int argc, char **argv) {
    std::string test =  "class Foo extends Bar {    \\\
                            string foo;              \\\
                            unsigned int8 zoo;        \\\
                            int64 boo;                 \\\
                                                        \\\
                            set zoo(int8 newval) {       \\\
                                self.zoo += zoo;          \\\
                                self.zoo++;                \\\
                            }                               \\\
                        }";                                 //\\
                                                           ///\\\
                                                          ///  \\\
                                                         ///    \\\         THE POWER OF LAMBDA (unrelated to the actual code)
                                                        ///      \\\            ABSOLUTE UNIT (test)
                                                       ///        \\\
                                                      ///          \\\
                                                     ///            \\\
                                                    ///              \\\
                                                   ///                \\\
    std::stringstream s;
    s << test;

    std::vector<Token*> tokens = tokenize(s);

    for (int i = 0; i < tokens.size(); i++) {
        Token *token = tokens.at(i);
        std::cout << token->tostring();
    }

    for (int i = 0; i < tokens.size(); i++) {
        delete tokens.at(i);
    }

    tokens.clear();
}