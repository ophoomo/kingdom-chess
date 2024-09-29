const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const sm = @import("../screen.zig");
const mc = @import("../components/menu_component.zig");
const sp = @import("../components/shop_component.zig");

pub const ScreenGameplay = struct {
    camera: rl.Camera3D,
    postionCam: rl.Vector3,

    menu: mc.MenuComponent,
    shop: sp.ShopComponent,

    screen: *sm.ScreenManager,

    btnHoverAudio: rl.Sound,
    pub fn onEnter(self: *ScreenGameplay, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter Gameplay");

        self.btnHoverAudio = rl.loadSound("resources/audio/button_hover.ogg");

        self.screen = screen;
        self.menu = mc.MenuComponent.init(screen, self.btnHoverAudio);
        self.shop = sp.ShopComponent.init();
        self.camera = rl.Camera3D{
            .position = rl.Vector3.init(0, 10, 15),
            .target = rl.Vector3.init(0, 0, 0),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .camera_perspective,
        };
        self.postionCam = self.camera.position;
    }

    pub fn onUpdate(self: *ScreenGameplay) void {
        rl.clearBackground(rl.Color.white);

        if (!self.menu.status) {
            if (rl.isGamepadAvailable(0)) {
                const axisY = rl.getGamepadAxisMovement(0, @intFromEnum(rl.GamepadAxis.gamepad_axis_right_y));
                self.postionCam.y -= axisY;
            } else {
                const scrollAmount = rl.getMouseWheelMove();
                self.postionCam.y -= scrollAmount;
            }
            if (self.postionCam.y >= 15) {
                self.postionCam.y = 15;
            } else if (self.postionCam.y <= 3) {
                self.postionCam.y = 3;
            }

            if (rl.isKeyDown(.key_w) or rl.isGamepadButtonDown(0, .gamepad_button_left_face_up)) self.postionCam.z -= 1;
            if (rl.isKeyDown(.key_s) or rl.isGamepadButtonDown(0, .gamepad_button_left_face_down)) self.postionCam.z += 1;
            if (self.postionCam.z <= 1) {
                self.postionCam.z = 1;
            } else if (self.postionCam.z >= 15) {
                self.postionCam.z = 15;
            }

            if (rl.isMouseButtonPressed(.mouse_button_left)) {
                const mousePos = rl.getMousePosition();
                std.debug.print("{}", .{mousePos.x});
            }
        }

        self.shop.draw();

        self.camera.position = rl.Vector3.lerp(self.camera.position, self.postionCam, 0.1);
        rl.updateCamera(&self.camera, .camera_custom);

        // start draw 3d
        rl.beginMode3D(self.camera);

        drawGrid();

        rl.endMode3D();
        // end draw 3d

        self.menu.draw();
    }

    pub fn onExit(self: *ScreenGameplay) void {
        rl.traceLog(.log_debug, "Exit Gameplay");
        self.menu.destroy();
        self.shop.destroy();
        rl.unloadSound(self.btnHoverAudio);
    }

    fn drawGrid() void {
        const gridSize = 12;
        const cubeSize = 1.0;
        const offset = (gridSize - 1) * cubeSize / 2.0;

        for (1..gridSize) |x| {
            for (1..gridSize) |z| {
                const x_float: f32 = @floatFromInt(x);
                const z_float: f32 = @floatFromInt(z);
                const rect = rl.Vector3.init(x_float - offset, 0, z_float - offset);
                rl.drawCubeWires(rect, cubeSize, 0, cubeSize, rl.Color.dark_gray);
            }
        }
    }
};
