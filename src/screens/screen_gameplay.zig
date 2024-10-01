const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const sm = @import("../screen.zig");
const mc = @import("../components/menu_component.zig");
const sp = @import("../components/shop_component.zig");

pub const ScreenGameplay = struct {
    allocator: std.mem.Allocator,
    camera: rl.Camera3D,
    postionCam: rl.Vector3,

    menu: mc.MenuComponent,
    shop: sp.ShopComponent,

    screen: *sm.ScreenManager,

    btnHoverAudio: rl.Sound,
    placeAudio: rl.Sound,
    removeObjectAudio: rl.Sound,

    gridVectors: std.ArrayList(rl.Vector3),
    gridSize: f32 = 8,
    cubeSize: f32 = 1.0,
    offset: f32 = 0,
    objects: std.ArrayList(rl.Vector3),
    pub fn onEnter(self: *ScreenGameplay, screen: *sm.ScreenManager) void {
        self.allocator = std.heap.page_allocator;
        rl.traceLog(.log_debug, "Enter Gameplay");

        self.btnHoverAudio = rl.loadSound("resources/audio/button_hover.ogg");
        self.placeAudio = rl.loadSound("resources/audio/place.wav");
        rl.setSoundVolume(self.placeAudio, 0.5);
        self.removeObjectAudio = rl.loadSound("resources/audio/remove_object.ogg");

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

        self.objects = std.ArrayList(rl.Vector3).init(self.allocator);
        self.gridVectors = std.ArrayList(rl.Vector3).init(self.allocator);

        self.initGrid();
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

            if (rl.isMouseButtonPressed(.mouse_button_left)) {
                const mousePos = rl.getMousePosition();
                const ray = rl.getScreenToWorldRay(mousePos, self.camera);
                for (self.gridVectors.items) |v| {
                    const max = rl.Vector3.init(v.x - self.cubeSize / 2, 0, v.z - self.cubeSize / 2);
                    const min = rl.Vector3.init(v.x + self.cubeSize / 2, 0, v.z + self.cubeSize / 2);
                    const collision = rl.getRayCollisionBox(ray, .{ .max = max, .min = min });
                    if (collision.hit) {
                        const index_in_object = self.checkObjectRepeat(v);
                        if (index_in_object == -1) {
                            self.objects.append(rl.Vector3.init(v.x, 0.4, v.z)) catch |err| {
                                std.debug.print("Caught error: {}\n", .{err});
                            };
                            rl.playSound(self.placeAudio);
                        } else {
                            const index_in_object_usize: usize = @intCast(index_in_object);
                            _ = self.objects.swapRemove(index_in_object_usize);
                            rl.playSound(self.removeObjectAudio);
                        }
                        break;
                    }
                }
            }
        }

        self.shop.draw();

        self.camera.position = rl.Vector3.lerp(self.camera.position, self.postionCam, 0.1);
        rl.updateCamera(&self.camera, .camera_custom);

        // start draw 3d
        rl.beginMode3D(self.camera);
        for (self.gridVectors.items) |value| {
            rl.drawCubeWires(value, self.cubeSize, 0, self.cubeSize, rl.Color.dark_gray);
        }

        // const box = rl.Vector3.init(0, 0, 0);
        // if (self.objects.items.len > 0) {
        //     var direction = box.subtract(self.objects.items[0]);
        //     direction = rl.Vector3.scale(direction.normalize(), 0.1);
        //     self.objects.items[0] = self.objects.items[0].add(direction);
        // }
        // rl.drawCube(box, 0.8, 0.8, 0.8, rl.Color.green);

        for (self.objects.items) |item| {
            rl.drawCube(item, 0.8, 0.8, 0.8, rl.Color.red);
        }

        rl.endMode3D();
        // end draw 3d

        self.menu.draw();
    }

    pub fn onExit(self: *ScreenGameplay) void {
        rl.traceLog(.log_debug, "Exit Gameplay");
        self.menu.destroy();
        self.shop.destroy();
        rl.unloadSound(self.btnHoverAudio);
        rl.unloadSound(self.placeAudio);
        rl.unloadSound(self.removeObjectAudio);
        self.objects.deinit();
        self.gridVectors.deinit();
    }

    fn initGrid(self: *ScreenGameplay) void {
        self.gridSize = 8;
        self.cubeSize = 1.0;
        self.offset = (self.gridSize - 1) * self.cubeSize / 2.0;
        for (0..8) |x| {
            for (0..8) |z| {
                const x_float: f32 = @floatFromInt(x);
                const z_float: f32 = @floatFromInt(z);
                const rect = rl.Vector3.init(x_float - self.offset, 0, z_float - self.offset);
                self.gridVectors.append(rect) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            }
        }
    }

    fn checkObjectRepeat(self: *ScreenGameplay, target: rl.Vector3) i32 {
        var index: i32 = -1;
        for (self.objects.items) |item| {
            index += 1;
            if (item.x == target.x and item.y == 0.4 and item.z == target.z) return index;
        }
        return -1;
    }
};
