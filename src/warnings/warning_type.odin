package warnings

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

warning :: inline proc (type: Warnings) {
    append(warning_queue, Warning{type, file, line, offset});
}

warning_start_offset :: inline proc (type: Warnings) {
    append(warning_queue, Warning{type, file, start_line, start_offset});
}