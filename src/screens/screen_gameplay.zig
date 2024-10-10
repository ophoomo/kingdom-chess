const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const sm = @import("../screen.zig");
const mc = @import("../components/menu_component.zig");
const go = @import("../components/game_over_component.zig");
const sp = @import("../components/shop_component.zig");
const st = @import("../components/slot_component.zig");
const grid = @import("../components//grid_component.zig");

const object_struct = struct { pos: rl.Vector3 };

pub const ScreenGameplay = struct {
    camera: rl.Camera3D,
    postionCam: rl.Vector3,

    gameOver: go.GameOverComponent,
    menu: mc.MenuComponent,
    shop: sp.ShopComponent,
    slot: st.SlotComponent,
    grids: grid.GridComponent,

    screen: *sm.ScreenManager,

    pub fn onEnter(self: *ScreenGameplay, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter Gameplay");

        self.screen = screen;
        self.menu = mc.MenuComponent.init(screen);
        self.gameOver = go.GameOverComponent.init(screen);
        self.grids = grid.GridComponent.init(&self.gameOver);
        self.shop = sp.ShopComponent.init();
        self.slot = st.SlotComponent.init();
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

        if (self.menu.status == false and self.gameOver.status == false) {
            self.cameraController();

            const mousePos = rl.getMousePosition();
            const ray = rl.getScreenToWorldRay(mousePos, self.camera);
            self.grids.mouseEvent(ray);
        }

        self.shop.draw();
        self.slot.draw();

        self.camera.position = rl.Vector3.lerp(self.camera.position, self.postionCam, 0.1);
        rl.updateCamera(&self.camera, .camera_custom);

        // start draw 3d
        rl.beginMode3D(self.camera);

        self.grids.draw(&self.slot.select);

        rl.endMode3D();
        // end draw 3d

        if (self.gameOver.status) {
            self.gameOver.draw();
        } else {
            self.menu.draw();
        }
    }

    pub fn onExit(self: *ScreenGameplay) void {
        rl.traceLog(.log_debug, "Exit Gameplay");
        self.menu.destroy();
        self.shop.destroy();
        self.slot.destroy();
        self.grids.destroy();
        self.gameOver.destroy();
    }

    fn cameraController(self: *ScreenGameplay) void {
        if (rl.isGamepadAvailable(0)) {
            const axisY = rl.getGamepadAxisMovement(0, @intFromEnum(rl.GamepadAxis.gamepad_axis_right_y));
            self.postionCam.y -= axisY;
        } else {
            const scrollAmount = rl.getMouseWheelMove();
            self.postionCam.y -= scrollAmount;
        }

        if (self.postionCam.y >= 15) {
            self.postionCam.z -= 1;
        } else {
            self.postionCam.z += 1;
        }

        if (self.postionCam.y >= 15) {
            self.postionCam.y = 15;
        } else if (self.postionCam.y <= 3) {
            self.postionCam.y = 3;
        }

        if (self.postionCam.z <= 1) {
            self.postionCam.z = 1;
        } else if (self.postionCam.z >= 15) {
            self.postionCam.z = 15;
        }
    }
};
