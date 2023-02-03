const std = @import("std");
const net = std.net;

pub fn main() !void {
    std.debug.print("Hello!\n", .{});
    const address = try net.Address.resolveIp("127.0.0.1", 8080);
    var server = net.StreamServer.init(.{});
    defer server.deinit();

    try server.listen(address);
    const client_con = try server.accept();
    const client_stream = client_con.stream;
    var fba_buffer: [512]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&fba_buffer);
    const allocator = fba.allocator();
    var buffer = try allocator.alloc(u8, 512);
    defer allocator.free(buffer);

    while (true) {
        const read_result = client_stream.reader().read(buffer) catch {
            std.debug.print("An error occured during read operation\n", .{});
            break;
        };
        if (read_result == 0) {
            break;
        }
        client_stream.writer().writeAll(buffer[0..read_result]) catch {
            std.debug.print("An error occured during write operation\n", .{});
            break;
        };
    }
    client_con.stream.close();
    server.close();
}
