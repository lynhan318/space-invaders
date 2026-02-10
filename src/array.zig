const std = @import("std");
pub fn main() void {
    const numbers = [3]i32{ 1, 2, 3 };
    const numbers_dynamic = [_]i32{0} ** 10;
    var number_abstract: [10]i32 = undefined;

    for (&number_abstract, 0..) |*bucket, i| {
        bucket.* = @intCast(i);
    }

    std.debug.print("Static array: {d}\n", .{numbers[0]});
    std.debug.print("Dynamic array: {d}\n", .{numbers_dynamic.len});
}
