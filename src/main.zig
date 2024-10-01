const std = @import("std");
const rl = @import("raylib");
const sm = @import("screen.zig");

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.setTraceLogLevel(.log_debug);

    rl.initWindow(screenWidth, screenHeight, "Kingdom Chess");
    defer rl.closeWindow();

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    rl.setTargetFPS(60);
    rl.setExitKey(.key_null);

    const windowIcon = rl.loadImage("resources/images/icon.png");
    defer rl.unloadImage(windowIcon);
    rl.setWindowIcon(windowIcon);

    const soundClick = rl.loadSound("resources/audio/mouse_click.ogg");
    defer rl.unloadSound(soundClick);

    const alloc = std.heap.page_allocator;

    var manager = try sm.ScreenManager.init(alloc);
    defer manager.destroy(alloc);

    // Set Starter Screen
    // manager.enter(sm.ScreenType.MainMenu);
    manager.enter(sm.ScreenType.Splash);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (rl.isMouseButtonPressed(.mouse_button_left) or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_up) or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_down) or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_right) or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_left)) {
            rl.playSound(soundClick);
        }

        manager.update();

        if (manager.close) break;
    }
}
