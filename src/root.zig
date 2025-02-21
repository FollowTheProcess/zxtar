//! zxtar is an implementation of the txtar archive format originally invented for the Go language.
//!
//! The syntax of the archive files is 100% compatible with the original specification.
const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

/// An Archive is a txtar archive
pub const Archive = struct {
    comment: []const u8,
    files: std.StringHashMap([]const u8),

    const Self = @This();

    /// Create a new Archive.
    pub fn init(allocator: Allocator, comment: []const u8) Self {
        return .{
            .comment = comment,
            .files = std.StringHashMap([]const u8).init(allocator),
        };
    }

    /// Deallocate the Archive.
    pub fn deinit(self: *Self) void {
        self.files.clearAndFree();
        self.* = undefined;
    }

    /// Check whether there is a file of a given name in the archive.
    pub fn contains(self: Self, name: []const u8) bool {
        return self.files.contains(strip(name));
    }

    /// Add a file to the archive.
    ///
    /// Calling add with the name of a file that already exists will
    /// overwrite the contents of that file.
    pub fn add(self: *Self, name: []const u8, contents: []const u8) !void {
        try self.files.put(strip(name), contents);
    }

    /// Read the contents of a file.
    pub fn read(self: Self, name: []const u8) ?[]const u8 {
        return self.files.get(strip(name));
    }

    /// Delete removes a file from the archive.
    pub fn delete(self: *Self, name: []const u8) void {
        _ = self.files.remove(name);
    }

    /// Size returns the number of files contained in the archive.
    pub fn size(self: Self) u32 {
        return self.files.count();
    }
};

/// Strip leading and trailing whitespace from the name.
fn strip(str: []const u8) []const u8 {
    return std.mem.trim(u8, str, "\r\n\t ");
}

test "add file" {
    var archive = Archive.init(testing.allocator, "A comment");
    defer archive.deinit();

    try testing.expectEqual(archive.size(), 0);

    try archive.add("test", "some stuff here");

    try testing.expect(archive.contains("test"));
    try testing.expectEqual(archive.size(), 1);
}

test "get file" {
    var archive = Archive.init(testing.allocator, "A comment");
    defer archive.deinit();

    try testing.expectEqual(archive.size(), 0);

    try archive.add("test", "some stuff here");
    try archive.add("test2", "some more stuff here");

    try testing.expect(archive.contains("test"));
    try testing.expect(archive.contains("test2"));

    try testing.expectEqual(archive.size(), 2);

    const got = archive.read("test");
    const got2 = archive.read("test2");

    try testing.expectEqualStrings("some stuff here", got.?);
    try testing.expectEqualStrings("some more stuff here", got2.?);
}

test "strip name" {
    var archive = Archive.init(testing.allocator, "A comment");
    defer archive.deinit();

    try testing.expectEqual(archive.size(), 0);

    try archive.add("  some name  ", "text");

    try testing.expect(archive.contains("some name"));

    try testing.expectEqual(archive.size(), 1);

    const got = archive.read("some name");

    try testing.expectEqualStrings("text", got.?);
}

test "delete file" {
    var archive = Archive.init(testing.allocator, "A comment");
    defer archive.deinit();

    try testing.expectEqual(archive.size(), 0);

    try archive.add("file1.txt", "Some contents here\n");

    // It should exist
    try testing.expect(archive.contains("file1.txt"));

    try testing.expectEqual(archive.size(), 1);

    // Remove it
    archive.delete("file1.txt");

    // It should no longer exist
    try testing.expect(!archive.contains("file1.txt"));

    try testing.expectEqual(archive.size(), 0);
}
