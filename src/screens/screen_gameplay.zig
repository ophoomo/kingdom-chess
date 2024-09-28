const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const sm = @import("../screen.zig");
const mc = @import("../components/menu_component.zig");

pub const ScreenGameplay = struct {
    camera: rl.Camera3D,
    menu: mc.MenuComponent,
    screen: *sm.ScreenManager,

    btnHoverAudio: rl.Sound,
    pub fn onEnter(self: *ScreenGameplay, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter Gameplay");

        self.btnHoverAudio = rl.loadSound("resources/audio/button_hover.wav");

        self.screen = screen;
        self.menu = mc.MenuComponent.init(screen, self.btnHoverAudio);
        self.camera = rl.Camera3D{
            .position = rl.Vector3.init(5, 5, 5),
            .target = rl.Vector3.init(0, 0, 0),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .camera_perspective,
        };
    }

    pub fn onUpdate(self: *ScreenGameplay) void {
        rl.clearBackground(rl.Color.white);

        rl.updateCamera(&self.camera, .camera_custom);
        // start draw 3d
        rl.beginMode3D(self.camera);

        rl.drawCube(rl.Vector3.init(0, 0, 0), 2, 2, 2, rl.Color.red);
        rl.drawGrid(10, 1.0);

        rl.endMode3D();
        // end draw 3d

        self.menu.draw();
    }

    pub fn onExit(self: *ScreenGameplay) void {
        rl.traceLog(.log_debug, "Exit Gameplay");
        rl.unloadSound(self.btnHoverAudio);
    }
};
