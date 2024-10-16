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

    kingModel: rl.Model,
    pub fn onEnter(self: *ScreenMainMenu, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter MainMenu");

        self.kingModel = rl.loadModel("resources/models/demo.iqm");

        self.camera = rl.Camera3D{
            .position = rl.Vector3.init(0, 1, 6),
            .target = rl.Vector3.init(0, 1, 0),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .camera_perspective,
        };

        self.screen = screen;
        self.btnHover = rl.loadSound("resources/audio/button_hover.ogg");
        self.background = rl.loadMusicStream("resources/music/mainmenu.mp3");
        rl.setMusicVolume(self.background, 0.4);
        rl.playMusicStream(self.background);

        const padding: f32 = 50.0;
        const btnSpacing: f32 = 10.0;
        const height: f32 = @floatFromInt(rl.getScreenHeight());
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
        rl.clearBackground(rl.Color.white);
        rl.updateMusicStream(self.background);
        rl.updateCamera(&self.camera, .camera_custom);

        rl.beginMode3D(self.camera);
        rl.drawModel(self.kingModel, rl.Vector3.init(1, 0, 3), 1, rl.Color.white);
        rl.endMode3D();

        if (self.btnStart.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_down)) {
            self.screen.switchScreen(sm.ScreenType.Game);
        }

        if (self.btnExit.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_right)) {
            self.screen.close = true;
        }

        rl.drawText("Alpha Test", rl.getScreenWidth() - 100, rl.getScreenHeight() - 30, 16, rl.Color.white);
    }

    pub fn onExit(self: *ScreenMainMenu) void {
        rl.traceLog(.log_debug, "Exit MainMenu");
        rl.unloadMusicStream(self.background);
        rl.unloadSound(self.btnHover);
        rl.unloadModel(self.kingModel);
    }
};
