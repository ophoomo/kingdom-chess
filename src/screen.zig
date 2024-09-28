const std = @import("std");
const screen_gameplay = @import("screens/screen_gameplay.zig");
const screen_mainmenu = @import("screens/screen_mainmenu.zig");

pub const ScreenType = enum {
    MainMenu,
    Game,
};

const Screen = union(ScreenType) {
    MainMenu: *screen_mainmenu.ScreenMainMenu,
    Game: *screen_gameplay.ScreenGameplay,
};

pub const ScreenManager = struct {
    screens: [2]Screen,
    currentScreen: ScreenType,

    pub fn init(allocator: std.mem.Allocator) !ScreenManager {
        const mainmenu = try allocator.create(screen_mainmenu.ScreenMainMenu);
        const gameplay = try allocator.create(screen_gameplay.ScreenGameplay);

        return ScreenManager{
            .screens = [_]Screen{
                Screen{ .MainMenu = mainmenu },
                Screen{ .Game = gameplay },
            },
            .currentScreen = ScreenType.MainMenu,
        };
    }

    pub fn enter(self: *ScreenManager, screen: ScreenType) void {
        const obj = self.screens[@intFromEnum(screen)];
        switch (obj) {
            .MainMenu => obj.MainMenu.onEnter(self),
            .Game => obj.Game.onEnter(self),
        }
        self.currentScreen = screen;
    }

    pub fn update(self: *ScreenManager) void {
        const obj = self.screens[@intFromEnum(self.currentScreen)];
        switch (obj) {
            .MainMenu => obj.MainMenu.onUpdate(),
            .Game => obj.Game.onUpdate(),
        }
    }

    pub fn exit(self: *ScreenManager) void {
        const obj = self.screens[@intFromEnum(self.currentScreen)];
        switch (obj) {
            .MainMenu => obj.MainMenu.onExit(),
            .Game => obj.Game.onExit(),
        }
    }

    pub fn switchScreen(self: *ScreenManager, newScreen: ScreenType) void {
        if (self.currentScreen == newScreen) return;
        self.currentScreen = newScreen;
        self.enter(self.currentScreen);
    }

    pub fn destroy(self: *ScreenManager, allocator: std.mem.Allocator) void {
        allocator.destroy(self.screens[0].MainMenu);
        allocator.destroy(self.screens[1].Game);
    }
};
