package avian

Warnings :: enum {
    T_INVALID_ESCAPE, T_UNEXPECTED_EOF,

    // Octals
    T_OCTAL_TOO_SMALL, T_OCTAL_TOO_LARGE, T_INVALID_OCTAL_VALUE,
}

Warning :: struct {
    type  : Warnings,
    file  : u32,
    line  : u32,
    offset: u32,
}

warning :: inline proc (_warning_queue: [dynamic]Warning, type: Warnings, file, line, offset: u32) {
    warning_queue := _warning_queue;
    append(&warning_queue, Warning{type, file, line, offset});
}

warning_start_offset :: inline proc (_warning_queue: [dynamic]Warning, type: Warnings, file, start_line, start_offset: u32) {
    warning_queue := _warning_queue;
    append(&warning_queue, Warning{type, file, start_line, start_offset});
}