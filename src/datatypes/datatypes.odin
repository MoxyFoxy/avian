package datatypes

Stack :: struct(T: typeid) {
    values: [dynamic]T,
    size: int = 0,
}

pop :: proc(_s: ^Stack($T)) -> T {
    s := _s;

    s.size -= 1;
    return s.values[size];
}

push :: proc(_s: ^Stack($T), value: T) {
    s := _s;

    s.values[size] = value;
    s.size += 1;
}