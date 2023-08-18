const std = @import("std");

const zigimg = @import("zigimg");

fn readPixel(img: []u8, width: u32, x: usize, y: usize) u8
{
    return img[y * width + x];
}

fn writePixel(img: []u8, width: u32, x: u32, y: u32, value: u8) void
{
    img[y * width + x] = value;
}

fn writeCircle(img: []u8, width: u32, centerX: u32, centerY: u32, radius: u32) void
{
    const r2: i32 = @intCast(2 * radius);

    var x: u32 = radius;
    var y: u32 = 0;
    var dY: i32 = -2;
    var dX: i32 = r2 + r2 - 4;
    var d: i32 = r2 - 1;

    while (y <= x) {
        writePixel(img, width, centerX - x, centerY - y, 1);
        writePixel(img, width, centerX - x, centerY + y, 1);
        writePixel(img, width, centerX + x, centerY - y, 1);
        writePixel(img, width, centerX + x, centerY + y, 1);
        writePixel(img, width, centerY - y, centerX - x, 1);
        writePixel(img, width, centerY - y, centerX + x, 1);
        writePixel(img, width, centerY + y, centerX - x, 1);
        writePixel(img, width, centerY + y, centerX + x, 1);

        d += dY;
        dY -= 4;
        y += 1;
        if (d < 0) {
            d += dX;
            dX -= 4;
            x -= 1;
        }
    }
}

fn printImg(img: []u8, width: u32, height: u32) !void
{
    const stdoutFile = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdoutFile);
    const stdout = bw.writer();

    for (0..height) |y| {
        for (0..width) |x| {
            if (readPixel(img, width, x, y) == 0) {
                try stdout.print("  ", .{});
            } else {
                try stdout.print("[]", .{});
            }
        }
        try stdout.print("\n", .{});
    }

    try bw.flush();
}

pub fn main() !void
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len != 2) {
        std.log.err("Expected arguments: radius", .{});
        return error.BadArgs;
    }

    // Setup and clear image pixels
    const imgSize = 64;
    var img = try allocator.alloc(u8, imgSize * imgSize);
    defer allocator.free(img);
    @memset(img, 0);

    // Calculate+write circle pixels to image
    const centerX = 32;
    const centerY = 32;
    const radius = try std.fmt.parseUnsigned(u32, args[1], 10);
    writeCircle(img, imgSize, centerX, centerY, radius);

    // Print image pixels
    try printImg(img, imgSize, imgSize);
}
