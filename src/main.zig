const std = @import("std");
const builtin = @import("builtin");

const Allocator = std.mem.Allocator;

// TODO: some sort of c_allocator in Release modes. But I don't want to be confined
// to libc so idk yet.
var gpa_allocator = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
const gpa = gpa_allocator.allocator();

const usage =
    \\Usage: zcl [options] [files...] -o (path)
    \\
    \\Options:
    \\-h, --help        Print this message and exit
    \\-o (path)         Output path of the binary
;

pub fn main() !void {
    defer if (builtin.mode == .Debug) {
        _ = gpa_allocator.deinit();
    };

    const process_args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, process_args);

    const args = process_args[1..];
    if (args.len == 0) {
        printHelpAndExit();
    }

    var positionals = std.ArrayList([]const u8).init(gpa);
    var output_path: ?[]const u8 = null;

    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            printHelpAndExit();
        } else if (std.mem.eql(u8, arg, "-o")) {
            if (i + 1 >= args.len) printErrorAndExit("Missing output path", .{});
            output_path = args[i + 1];
            i += 1;
        } else if (std.mem.startsWith(u8, arg, "--")) {
            printErrorAndExit("Unknown argument '{s}'", .{arg});
        } else {
            try positionals.append(arg);
        }
    }
}

fn printHelpAndExit() noreturn {
    std.io.getStdOut().writer().print("{s}\n", .{usage}) catch {};
    std.process.exit(0);
}

fn printErrorAndExit(comptime fmt: []const u8, args: anytype) noreturn {
    const writer = std.io.getStdErr().writer();
    writer.print(fmt, args) catch {};
    writer.writeByte('\n') catch {};
    std.process.exit(1);
}
