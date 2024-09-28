const std = @import("std");
const rl = @import("raylib");
const sm = @import("screen.zig");

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.setTraceLogLevel(.log_debug);

    rl.initWindow(screenWidth, screenHeight, "Game");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    const alloc = std.heap.page_allocator;

    var manager = try sm.ScreenManager.init(alloc);
    defer manager.destroy(alloc);

    manager.enter(sm.ScreenType.Game);
    defer manager.exit();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        manager.update();
    }
}
