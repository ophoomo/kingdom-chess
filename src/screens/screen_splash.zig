const std = @import("std");
const rl = @import("raylib");
const sm = @import("../screen.zig");

pub const ScreenSplash = struct {
    screen: *sm.ScreenManager,
    timer: f32,
    pub fn onEnter(self: *ScreenSplash, screen: *sm.ScreenManager) void {
        self.screen = screen;
        self.timer = 100;
        rl.traceLog(.log_debug, "Enter Splash");
    }

    pub fn onUpdate(self: *ScreenSplash) void {
        self.timer -= 1;
        if (self.timer <= 0) {
            self.screen.switchScreen(sm.ScreenType.MainMenu);
        }
    }

    pub fn onExit(_: *ScreenSplash) void {
        rl.traceLog(.log_debug, "Exit Splash");
    }
};
