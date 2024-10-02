const std = @import("std");
const rl = @import("raylib");
const sm = @import("../screen.zig");

pub const ScreenSplash = struct {
    screen: *sm.ScreenManager,
    timer: f32,
    overlayAlpha: f32 = 1,
    logoImage: rl.Texture2D,
    beachSound: rl.Sound,
    pub fn onEnter(self: *ScreenSplash, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter Splash");
        self.screen = screen;
        self.timer = 200;
        self.overlayAlpha = 1;
        self.logoImage = rl.loadTextureFromImage(rl.loadImage("resources/images/logo.png"));
        self.beachSound = rl.loadSound("resources/audio/intro.ogg");
        rl.playSound(self.beachSound);
    }

    pub fn onUpdate(self: *ScreenSplash) void {
        rl.clearBackground(rl.Color.white);
        self.timer -= 1;
        self.overlayAlpha -= 0.02;
        if (self.timer <= 0) {
            self.screen.switchScreen(sm.ScreenType.MainMenu);
        }

        const widthLogo: f32 = @floatFromInt(rl.getScreenWidth() - self.logoImage.width);
        const heightLogo: f32 = @floatFromInt(rl.getScreenHeight() - self.logoImage.height);
        rl.drawTexture(self.logoImage, @as(i32, @intFromFloat(widthLogo / 2)), @as(i32, @intFromFloat(heightLogo / 2)), rl.Color.white);

        if (self.overlayAlpha > 0) {
            rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.colorAlpha(rl.Color.white, self.overlayAlpha));
        }
    }

    pub fn onExit(self: *ScreenSplash) void {
        rl.traceLog(.log_debug, "Exit Splash");
        rl.unloadTexture(self.logoImage);
        rl.unloadSound(self.beachSound);
    }
};
