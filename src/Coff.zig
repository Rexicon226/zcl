//! Definition of a COFF object.

const std = @import("std");
const Allocator = std.mem.Allocator;

const Coff = @This();

pub const COFFHeader = packed struct {
    machine: u16,
    num_sections: u16,
    time_date_stamp: u32,
    pointer_to_symbol_table: u32,
    num_symbols: u32,
    size_of_optional_header: u16,
    characteristics: u16,
};

pub fn openPath(path: []const u8, alloc: Allocator) !void {
    const bytes = try std.fs.cwd().readFileAllocOptions(
        alloc,
        path,
        100 * 1024 * 1024,
        null,
        8,
        null,
    );
    defer alloc.free(bytes);

    const header_bytes = bytes[@sizeOf(COFFHeader)..];
    const header: *COFFHeader = @ptrCast(header_bytes);
    _ = header;
}
