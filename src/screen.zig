const std = @import("std");
const rl = @import("raylib");
const screen_gameplay = @import("screens/screen_gameplay.zig");
const screen_mainmenu = @import("screens/screen_mainmenu.zig");
const screen_splash = @import("screens/screen_splash.zig");

pub const ScreenType = enum {
    Splash,
    MainMenu,
    Game,
};

const Screen = union(ScreenType) {
    Splash: *screen_splash.ScreenSplash,
    MainMenu: *screen_mainmenu.ScreenMainMenu,
    Game: *screen_gameplay.ScreenGameplay,
};

pub const ScreenManager = struct {
    screens: [3]Screen,
    currentScreen: ScreenType,
    renderScreen: ScreenType,
    overlay: f32 = 0,
    close: bool = false,
    pub fn init(allocator: std.mem.Allocator) !ScreenManager {
        const splash = try allocator.create(screen_splash.ScreenSplash);
        const mainmenu = try allocator.create(screen_mainmenu.ScreenMainMenu);
        const gameplay = try allocator.create(screen_gameplay.ScreenGameplay);

        return ScreenManager{
            .screens = [_]Screen{
                Screen{ .Splash = splash },
                Screen{ .MainMenu = mainmenu },
                Screen{ .Game = gameplay },
            },
            .currentScreen = ScreenType.Splash,
            .renderScreen = ScreenType.Splash,
        };
    }

    pub fn enter(self: *ScreenManager, screen: ScreenType) void {
        const obj = self.screens[@intFromEnum(screen)];
        switch (obj) {
            .Splash => obj.Splash.onEnter(self),
            .MainMenu => obj.MainMenu.onEnter(self),
            .Game => obj.Game.onEnter(self),
        }
        self.renderScreen = screen;
        self.currentScreen = screen;
    }

    pub fn update(self: *ScreenManager) void {
        const obj = self.screens[@intFromEnum(self.renderScreen)];
        switch (obj) {
            .Splash => obj.Splash.onUpdate(),
            .MainMenu => obj.MainMenu.onUpdate(),
            .Game => obj.Game.onUpdate(),
        }
        if (self.currentScreen != self.renderScreen) {
            self.overlay += 0.1;
            if (self.overlay >= 1) {
                self.exit(self.renderScreen);
                self.renderScreen = self.currentScreen;
                self.enter(self.renderScreen);
            }
        } else {
            if (self.overlay > 0) {
                self.overlay -= 0.1;
            }
        }
        if (self.overlay > 0) {
            rl.drawRectangle(0, 0, rl.getRenderWidth(), rl.getRenderHeight(), rl.colorAlpha(rl.Color.black, self.overlay));
        }
    }

    pub fn exit(self: *ScreenManager, screen: ScreenType) void {
        const obj = self.screens[@intFromEnum(screen)];
        switch (obj) {
            .Splash => obj.Splash.onExit(),
            .MainMenu => obj.MainMenu.onExit(),
            .Game => obj.Game.onExit(),
        }
    }

    pub fn switchScreen(self: *ScreenManager, newScreen: ScreenType) void {
        if (self.currentScreen == newScreen) return;
        self.currentScreen = newScreen;
    }

    pub fn destroy(self: *ScreenManager, allocator: std.mem.Allocator) void {
        for (self.screens) |screen| {
            switch (screen) {
                .Splash => allocator.destroy(screen.Splash),
                .MainMenu => allocator.destroy(screen.MainMenu),
                .Game => allocator.destroy(screen.Game),
            }
        }
    }
};
