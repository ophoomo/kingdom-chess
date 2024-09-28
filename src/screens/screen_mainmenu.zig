const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const sm = @import("../screen.zig");
const gui = @import("../gui.zig");

pub const ScreenMainMenu = struct {
    camera: rl.Camera3D,
    screen: *sm.ScreenManager,
    background: rl.Music,

    btnHover: rl.Sound,
    btnStart: gui.button,
    btnExit: gui.button,
    pub fn onEnter(self: *ScreenMainMenu, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter MainMenu");

        self.camera = rl.Camera3D{
            .position = rl.Vector3.init(0, 1, 6),
            .target = rl.Vector3.init(0, 0, 0),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .camera_perspective,
        };

        self.screen = screen;

        self.btnHover = rl.loadSound("resources/audio/button_hover.wav");

        self.background = rl.loadMusicStream("resources/music/mainmenu.mp3");
        rl.setMusicVolume(self.background, 0.4);
        rl.playMusicStream(self.background);

        const padding: f32 = 50.0;
        const btnSpacing: f32 = 10.0;
        const height: f32 = @floatFromInt(rl.getRenderHeight());
        const btnwidth = 200.0;
        const btnheight = 40.0;

        self.btnStart = gui.button{
            .rect = rl.Rectangle.init(padding, height - btnheight * 2 - btnSpacing - padding, btnwidth, btnheight),
            .text = "START GAME",
            .sound = self.btnHover,
        };

        self.btnExit = gui.button{
            .rect = rl.Rectangle.init(padding, height - btnheight - padding, btnwidth, btnheight),
            .text = "Exit",
            .sound = self.btnHover,
        };
    }

    pub fn onUpdate(self: *ScreenMainMenu) void {
        rl.updateMusicStream(self.background);
        rl.updateCamera(&self.camera, .camera_custom);

        rl.beginMode3D(self.camera);
        rl.drawCube(rl.Vector3.init(0, 0, 0), 2, 2, 2, rl.Color.red);
        rl.drawGrid(10, 1.0);
        rl.endMode3D();

        if (self.btnStart.draw() == 1) {
            self.screen.switchScreen(sm.ScreenType.Game);
        }

        if (self.btnExit.draw() == 1) {
            rl.closeWindow();
        }

        rl.drawText("alpha test", rl.getRenderWidth() - 100, rl.getRenderHeight() - 30, 16, rl.Color.white);
    }

    pub fn onExit(self: *ScreenMainMenu) void {
        rl.traceLog(.log_debug, "Exit MainMenu");
        rl.unloadMusicStream(self.background);
        rl.unloadSound(self.btnHover);
    }
};
