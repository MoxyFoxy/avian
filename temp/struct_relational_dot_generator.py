import re
import os

### This all is meant to be simple to make. Not meant to be maintainable
### This all will get replaced with something in the future
### Just used to generate relational DOT diagrams for structs, enums, etc.
### Definitely not meant to be performant at all

def get_all(_input):
    _input.sub(r'\/\/.+', '', _input)
    _input.sub(r'\s', '', _input)
    matches = re.findall(r'[a-zA-Z]+::[a-zA-Z]+{([\^a-zA-Z,:\[\]_()])+}', _input)

def get_structs(_input):
    return re.findall(r'[a-zA-Z]+::struct{([\^a-zA-Z,:\[\]_()])+}', _input)

def get_enums(_input):
    return re.findall(r'[a-zA-Z]+::enum{([\^a-zA-Z,:\[\]_()])+}', _input)

def get_unions(_input):
    return re.findall(r'[a-zA-Z]+::union{([\^a-zA-Z,:\[\]_()])+}', _input)

def main():
    types = [
        'u8', 'u16', 'u32', 'u64', 'u128',
        'u8le', 'u16le', 'u32le', 'u64le', 'u128le',
        'u8be', 'u16be', 'u32be', 'u64be', 'u128be',
        'i8', 'i16', 'i32', 'i64', 'i128',
        'i8le', 'i16le', 'i32le', 'i64le', 'i128le',
        'i8be', 'i16be', 'i32be', 'i64be', 'i128be',
        'bool', 'b8', 'b16', 'b32', 'b64',
        'string', 'rune',
        'f32', 'f64',
        'complex64', 'complex128',
        'byte',
        'uintptr', 'uint', 'int', 'rawptr', 'cstring'
    ]

    with open('../src/p_structs.odin', 'r') as f:
        _input = f.read()

    # Structs
    _structs = get_structs(_input)
    structs = [Struct(re.search(r'^[a-zA-Z]+', struct), re.search(r'(?<={).+(?=})', struct)) for struct in _structs]

    string = 'digraph parser {graph [ranksep=0];'

    for struct in structs:
        string += str(struct)

    for struct in structs:
        for member in struct.members:
            if (member.derivative is None or member.derivative not in types):
                string += member.name + '->' + member.derivative + ';'

    string += '}'

    with open('parser.dot', 'w+') as f:
        f.write(string)

    os.system('dot parser.dot -Tpng -o ../images/parser.png')

class Struct:
    def __init__(self, name, members):
        self.name = name
        self.members = [Member(re.search(r'[a-zA-Z]+', member), re.search(r'(?<=\:)[a-zA-Z]+', member), re.search(r'[a-zA-Z]+(?=\,)', member)) for member in members]

        for member in members:
            members.append()

    def __str__(self):
        string = self.name + '[shape=record, label=\"'

        string += '{{' + self.name + '}' + '{'

        for member in members:
            string += str(member)

        string += '}}\"];'

        return string

class Member:
    def __init__(self, name, mem_type, derivative):
        self.name = name
        self.type = mem_type
        self.derivative = derivative

    def __str__(self):
        return '{' + self.name + ': ' + self.mem_type + '}'