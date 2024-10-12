const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const pe = @import("./particle_component.zig");
const king_entity = @import("../entities/king_entity.zig");
const bishop_entity = @import("../entities/bishop_entity.zig");
const knight_entity = @import("../entities/knight_entity.zig");
const villager_entity = @import("../entities/villager_entity.zig");
const object_enum = @import("../enums/object_enum.zig");
const go = @import("./game_over_component.zig");

const object_struct = struct {
    pos: rl.Vector3,
    unit: object_enum.object_enum,
};

pub const GridComponent = struct {
    gridSize: f32,
    cubeSize: f32,
    offset: f32,
    gridVectors: std.ArrayList(rl.Vector3),
    particles: pe.ParticleComponent,

    hoverGrid: rl.Vector3 = undefined,

    placeAudio: rl.Sound,
    removeObjectAudio: rl.Sound,
    destroySound: rl.Sound,

    slot_select: *object_enum.object_enum = undefined,
    gameOver: *go.GameOverComponent,

    king_model: rl.Model,
    knight_model: rl.Model,
    bishop_model: rl.Model,
    villager_model: rl.Model,

    objects: std.ArrayList(object_struct),
    king_object: std.ArrayList(king_entity.KingEntity),
    knight_object: std.ArrayList(knight_entity.KnightEntity),
    bishop_object: std.ArrayList(bishop_entity.BishopEntity),
    villager_object: std.ArrayList(villager_entity.VillagerEntity),

    pub fn init(gameOver: *go.GameOverComponent) GridComponent {
        const allocator = std.heap.page_allocator;

        const gridSize = 8;
        const cubeSize = 1.5;
        const offset = (gridSize - 1) * cubeSize / 2.0;
        var gridVectors = std.ArrayList(rl.Vector3).init(allocator);

        const particles = pe.ParticleComponent.init();

        // sound
        const placeAudio = rl.loadSound("resources/audio/place.ogg");
        rl.setSoundVolume(placeAudio, 0.5);
        const removeObjectAudio = rl.loadSound("resources/audio/remove_object.ogg");
        const destroySound = rl.loadSound("resources/audio/destroy_object.ogg");
        rl.setSoundVolume(destroySound, 0.5);

        // model
        const king_model = rl.loadModel("resources/models/king.glb");
        const knight_model = rl.loadModel("resources/models/knight.glb");
        const bishop_model = rl.loadModel("resources/models/bishop.glb");
        const villager_model = rl.loadModel("resources/models/villager.glb");

        // setup grid
        for (0..8) |x| {
            for (0..4) |z| {
                const x_float: f32 = @floatFromInt(x);
                const z_float: f32 = @floatFromInt(z);
                const rect = rl.Vector3.init((x_float * cubeSize) - offset, 0, 2 + (z_float * cubeSize) - offset);
                gridVectors.append(rect) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            }
        }

        return GridComponent{
            .gridSize = gridSize,
            .cubeSize = cubeSize,
            .offset = offset,
            .gridVectors = gridVectors,
            .particles = particles,
            .placeAudio = placeAudio,
            .removeObjectAudio = removeObjectAudio,
            .objects = std.ArrayList(object_struct).init(allocator),
            .king_object = std.ArrayList(king_entity.KingEntity).init(allocator),
            .knight_object = std.ArrayList(knight_entity.KnightEntity).init(allocator),
            .bishop_object = std.ArrayList(bishop_entity.BishopEntity).init(allocator),
            .villager_object = std.ArrayList(villager_entity.VillagerEntity).init(allocator),
            .gameOver = gameOver,
            .destroySound = destroySound,
            .king_model = king_model,
            .knight_model = knight_model,
            .bishop_model = bishop_model,
            .villager_model = villager_model,
        };
    }

    pub fn draw(
        self: *GridComponent,
        slot_select: *object_enum.object_enum,
    ) void {
        self.slot_select = slot_select;
        // draw grid line
        for (self.gridVectors.items) |value| {
            if (self.hoverGrid.equals(value) == 1) {
                const new_vec = rl.Vector3.init(value.x, 0.001, value.z);
                rl.drawCubeWires(new_vec, self.cubeSize, 0, self.cubeSize, rl.Color.red);
                self.hoverGrid = undefined;
            } else {
                rl.drawCubeWires(value, self.cubeSize, 0, self.cubeSize, rl.Color.dark_gray);
            }
        }

        self.particles.draw();
        self.updateObject();

        // draw object on top grid line
        for (self.king_object.items) |*v| {
            v.draw();
        }
        for (self.bishop_object.items) |*v| {
            v.draw();
        }
        for (self.knight_object.items) |*v| {
            v.draw();
        }
        for (self.villager_object.items) |*v| {
            v.draw();
        }
    }

    pub fn drawUI(
        self: *GridComponent,
        camera: *rl.Camera,
    ) void {
        for (self.king_object.items) |*v| {
            v.drawUI(camera);
        }
        for (self.bishop_object.items) |*v| {
            v.drawUI(camera);
        }
        for (self.knight_object.items) |*v| {
            v.drawUI(camera);
        }
        for (self.villager_object.items) |*v| {
            v.drawUI(camera);
        }
    }

    pub fn destroy(self: *GridComponent) void {
        self.gridVectors.deinit();
        self.particles.destroy();
        rl.unloadSound(self.placeAudio);
        rl.unloadSound(self.removeObjectAudio);
        rl.unloadSound(self.destroySound);

        self.objects.deinit();
        self.king_object.deinit();
        self.knight_object.deinit();
        self.villager_object.deinit();
        self.bishop_object.deinit();

        rl.unloadModel(self.king_model);
        rl.unloadModel(self.knight_model);
        rl.unloadModel(self.bishop_model);
        rl.unloadModel(self.villager_model);
    }

    pub fn mouseEvent(self: *GridComponent, ray: rl.Ray) void {
        for (self.gridVectors.items) |v| {
            const max = rl.Vector3.init(v.x - self.cubeSize / 2, 0, v.z - self.cubeSize / 2);
            const min = rl.Vector3.init(v.x + self.cubeSize / 2, 0, v.z + self.cubeSize / 2);
            const collision = rl.getRayCollisionBox(ray, .{ .max = max, .min = min });
            if (collision.hit) {
                if (rl.isMouseButtonPressed(.mouse_button_left)) {
                    const index_object = self.check_object(v);
                    if (index_object > -1) {
                        self.removeObject(index_object);
                        rl.playSound(self.removeObjectAudio);
                    } else {
                        if (self.slot_select.* != object_enum.object_enum.None) {
                            const object = object_struct{
                                .pos = v,
                                .unit = self.slot_select.*,
                            };
                            self.objects.append(object) catch |err| {
                                std.debug.print("Caught error: {}\n", .{err});
                            };
                            self.addObject(object);
                            self.particles.create(v, .Building);
                            rl.playSound(self.placeAudio);
                        }
                    }
                    break;
                } else {
                    self.hoverGrid = v;
                }
            }
        }
    }

    fn updateObject(self: *GridComponent) void {
        var count = self.objects.items.len;
        while (count > 0) object_loop: {
            count -= 1;
            const object = self.objects.items[count];
            var status: bool = false;
            switch (object.unit) {
                .None => {},
                .King => {
                    for (self.king_object.items, 0..) |*v, i| {
                        if (object.pos.equals(v.pos) == 1) {
                            if (v.hp <= 0) {
                                self.particles.create(object.pos, .Destroy);
                                _ = self.king_object.swapRemove(i);
                                status = true;
                                rl.playSound(self.destroySound);
                                self.gameOver.setGameOver();
                                break :object_loop;
                            }
                            break;
                        }
                    }
                },
                .Knight => {
                    for (self.knight_object.items, 0..) |*v, i| {
                        if (object.pos.equals(v.pos) == 1) {
                            if (v.hp <= 0) {
                                self.particles.create(object.pos, .Destroy);
                                _ = self.knight_object.swapRemove(i);
                                status = true;
                            }
                            break;
                        }
                    }
                },
                .Bishop => {
                    for (self.bishop_object.items, 0..) |*v, i| {
                        if (object.pos.equals(v.pos) == 1) {
                            if (v.hp <= 0) {
                                self.particles.create(object.pos, .Destroy);
                                _ = self.bishop_object.swapRemove(i);
                                status = true;
                            }
                            break;
                        }
                    }
                },
                .Villager => {
                    for (self.villager_object.items, 0..) |*v, i| {
                        if (object.pos.equals(v.pos) == 1) {
                            if (v.hp <= 0) {
                                self.particles.create(object.pos, .Destroy);
                                _ = self.villager_object.swapRemove(i);
                                status = true;
                            }
                            break;
                        }
                    }
                },
            }

            if (status) {
                rl.playSound(self.destroySound);
                _ = self.objects.swapRemove(count);
            }
        }
    }

    fn check_object(self: *GridComponent, target: rl.Vector3) i32 {
        for (self.objects.items, 0..) |v, i| {
            if (v.pos.equals(target) == 1) return @as(i32, @intCast(i));
        }

        return -1;
    }

    fn addObject(self: *GridComponent, object: object_struct) void {
        switch (object.unit) {
            .None => {},
            .King => {
                self.king_object.append(king_entity.KingEntity.init(object.pos, self.king_model)) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            },
            .Knight => {
                self.knight_object.append(knight_entity.KnightEntity.init(object.pos, self.knight_model)) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            },
            .Bishop => {
                self.bishop_object.append(bishop_entity.BishopEntity.init(object.pos, self.bishop_model)) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            },
            .Villager => {
                self.villager_object.append(villager_entity.VillagerEntity.init(object.pos, self.villager_model)) catch |err| {
                    std.debug.print("Caught error: {}\n", .{err});
                };
            },
        }
    }

    fn removeObject(self: *GridComponent, index: i32) void {
        const index_usize = @as(usize, @intCast(index));
        const object = self.objects.items[index_usize];
        switch (object.unit) {
            .None => {},
            .King => {
                for (self.king_object.items, 0..) |*v, i| {
                    if (object.pos.equals(v.pos) == 1) {
                        _ = self.king_object.swapRemove(i);
                        break;
                    }
                }
            },
            .Knight => {
                for (self.knight_object.items, 0..) |*v, i| {
                    if (object.pos.equals(v.pos) == 1) {
                        _ = self.knight_object.swapRemove(i);
                        break;
                    }
                }
            },
            .Bishop => {
                for (self.bishop_object.items, 0..) |*v, i| {
                    if (object.pos.equals(v.pos) == 1) {
                        _ = self.bishop_object.swapRemove(i);
                        break;
                    }
                }
            },
            .Villager => {
                for (self.villager_object.items, 0..) |*v, i| {
                    if (object.pos.equals(v.pos) == 1) {
                        _ = self.villager_object.swapRemove(i);
                        break;
                    }
                }
            },
        }
        _ = self.objects.swapRemove(index_usize);
    }
};
