const std = @import("std");
const testing = std.testing;

const HEAPSIZE = 10000000;
const FREESIZE = 50;
const STACKSIZE = 30000;
const SYMSIZE = 256;
const BUFSIZE = 256;
const NIL = 0;
const T = 4;

//-------error code---
const CANT_FIND_ERR = 1;
const ARG_SYM_ERR = 2;
const ARG_NUM_ERR = 3;
const ARG_LIS_ERR = 4;
const ARG_LEN0_ERR = 5;
const ARG_LEN1_ERR = 6;
const ARG_LEN2_ERR = 7;
const ARG_LEN3_ERR = 8;
const MALFORM_ERR = 9;
const CANT_READ_ERR = 10;
const ILLEGAL_OBJ_ERR = 11;

//-------arg check code--
const NUMLIST_TEST = 1;
const SYMBOL_TEST = 2;
const NUMBER_TEST = 3;
const LIST_TEST = 4;
const LEN0_TEST = 5;
const LEN1_TEST = 6;
const LEN2_TEST = 7;
const LEN3_TEST = 8;
const LENS1_TEST = 9;
const LENS2_TEST = 10;
const COND_TEST = 11;

//-------read--------
const EOL: u8 = '\n';
const TAB: u8 = '\t';
const SPACE: u8 = ' ';
const ESCAPE: u8 = 27;
const NUL: u8 = 0;

const Tag = enum { EMP, NUM, SYM, LIS, SUBR, FSUBR, FUNC };
const Flag = enum { FRE, USE };
const TokType = enum { LPAREN, RPAREN, QUOTE, DOT, NUMBER, SYMBOL, OTHER };
const BackTrack = enum { GO, BACK };
const Cell = struct { tag: Tag, flag: Flag, name: *[]u8, val: union { num: i32, bind: i32, subr: *const fn () i32 }, car: i32, cdr: i32 };
const Token = struct { ch: u8, flag: BackTrack, type: TokType, buf: [BUFSIZE]u8 };

// Global Variables
var head: [HEAPSIZE]Cell = undefined;
var stok = Token{ .ch = 0, .flag = .GO, .type = .OTHER, .buf = [_]u8{0} ** BUFSIZE };

var hp: i32 = undefined;
var ep: i32 = undefined;
var sp: i32 = undefined;
var fc: i32 = undefined;
var ap: i32 = undefined;

fn getCar(comptime addr: comptime_int) i32 {
    return head[addr].car;
}

fn getCdr(comptime addr: comptime_int) i32 {
    return head[addr].cdr;
}

fn makeSym(_: []const u8) i32 {
    return 0;
}

fn assocSym(_: i32, _: i32) void {}

fn initCell() void {
    for (0..HEAPSIZE) |addr| {
        head[addr].flag = .FRE;
        head[addr].cdr = @as(i32, @intCast(addr)) + 1;
    }
    hp = 0;
    fc = HEAPSIZE;

    // 環境の初期値はnilで初期環境とする
    ep = makeSym("nil");
    assocSym(makeSym("nil"), NIL);
    assocSym(makeSym("t"), makeSym("t"));

    // GC用のスタックの先頭アドレス、引数リストのアドレス
    sp = 0;
    ap = 0;
}

fn getToken() !void {
    const stdin = std.io.getStdIn().reader();
    var pos: usize = undefined;

    if (stok.flag == .BACK) {
        stok.flag = .GO;
        return;
    }

    if (stok.ch == ')') {
        stok.type = .RPAREN;
        stok.ch = NUL;
        return;
    }

    if (stok.ch == '(') {
        stok.type = .LPAREN;
        stok.ch = NUL;
        return;
    }

    var c = try stdin.readByte();
    while ((c == SPACE) or (c == EOL) or (c == TAB)) {
        c = try stdin.readByte();
    }

    stok.type = switch (c) {
        '(' => .LPAREN,
        ')' => .RPAREN,
        '\'' => .QUOTE,
        '.' => .DOT,
        else => blk: {
            pos = 0;
            stok.buf[pos] = c;
            pos += 1;

            while (pos < BUFSIZE) {
                c = try stdin.readByte();
                if (c == EOL or c == SPACE or c == '(' or c == ')') {
                    break;
                }

                stok.buf[pos] = c;
                pos += 1;
            }

            stok.buf[pos] = NUL;
            stok.ch = c;
            if (numberToken(stok.buf)) {
                break :blk .NUMBER;
            }

            if (symbolToken(stok.buf)) {
                break :blk .SYMBOL;
            }

            break :blk .OTHER;
        },
    };
}

pub fn numberToken(buf: [BUFSIZE]u8) bool {
    if (buf.len == 0) return false;

    var i: usize = 0;

    if (buf[0] == '+' or buf[0] == '-') {
        if (buf.len == 1) return false;

        i = 1;
    }

    while (i < buf.len) : (i += 1) {
        if (!std.ascii.isDigit(buf[i])) {
            return false;
        }
    }
    return true;
}

pub fn symbolToken(buf: [BUFSIZE]u8) bool {
    if (buf.len == 0) return false;
    if (std.ascii.isDigit((buf[0]))) return false;

    for (buf) |c| {
        if (!std.ascii.isAlphabetic(c) and !std.ascii.isDigit(c) and !isSymch(c)) {
            return false;
        }
    }
    return true;
}

pub fn isSymch(c: u8) bool {
    return switch (c) {
        '+', '-', '*', '/', '<', '>', '=', '!', '?' => true,
        else => false,
    };
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "init Lisp Environment" {
    initCell();

    for (0..HEAPSIZE) |addr| {
        try testing.expect(head[addr].flag == .FRE);
        try testing.expect(head[addr].cdr == @as(i32, @intCast(addr)) + 1);
    }

    try testing.expect(ep == 0);
    try testing.expect(sp == 0);
    try testing.expect(ap == 0);
}
