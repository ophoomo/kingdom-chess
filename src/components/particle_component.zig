const std = @import("std");
const rl = @import("raylib");
const pt = @import("../enums/particle_type.zig");

const Particle = struct {
    position: rl.Vector3,
    target: rl.Vector3,
    state: u8,
    lifetime: u8,
    particle_type: pt.ParticleType,
};

pub const ParticleComponent = struct {
    list: std.ArrayList(Particle),

    pub fn init() ParticleComponent {
        const allocator = std.heap.page_allocator;
        return ParticleComponent{
            .list = std.ArrayList(Particle).init(allocator),
        };
    }

    pub fn create(self: *ParticleComponent, pos: rl.Vector3, p: pt.ParticleType) void {
        var count: f32 = 0.0;
        for (0..25) |_| {
            self.list.append(createParticle(pos, count, p)) catch |err| {
                std.debug.print("Caught error: {}\n", .{err});
            };
            count += 0.08;
        }
    }

    pub fn draw(self: *ParticleComponent) void {
        var count = self.list.items.len;
        if (count == 0) return;
        while (count > 0) {
            count -= 1;
            const item = &self.list.items[count];
            if (item.lifetime > 0) {
                var direction = item.target.subtract(item.position);
                direction = rl.Vector3.scale(direction.normalize(), 0.05);
                item.position = item.position.add(direction);
                var size: f32 = 0.1;
                var color: rl.Color = switch (item.particle_type) {
                    .Building => rl.Color.brown,
                    .Destroy => rl.Color.yellow,
                };
                if (item.state == 1) {
                    size = 0.15;
                    color = switch (item.particle_type) {
                        .Building => rl.Color.light_gray,
                        .Destroy => rl.Color.orange,
                    };
                } else if (item.state == 2) {
                    size = 0.2;
                    color = rl.Color.gray;
                    color = switch (item.particle_type) {
                        .Building => rl.Color.gray,
                        .Destroy => rl.Color.gold,
                    };
                }

                rl.drawCube(item.position, size, size, size, color);
                item.lifetime -= 1;
            } else {
                _ = self.list.swapRemove(count);
            }
        }
    }

    pub fn destroy(self: *ParticleComponent) void {
        self.list.deinit();
    }

    fn createParticle(pos: rl.Vector3, i: f32, p: pt.ParticleType) Particle {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Caught error: {}\n", .{err});
        };

        var prng = std.Random.DefaultPrng.init(seed);
        const rand = prng.random();

        const angle = i * std.math.pi;
        const radius = 1.0;
        var targetPos = rl.Vector3{
            .x = pos.x + radius * std.math.cos(angle),
            .y = pos.y,
            .z = pos.z + radius * std.math.sin(angle),
        };

        if (rand.intRangeAtMost(u8, 0, 3) > 2) {
            targetPos.y += switch (p) {
                .Building => 0.2,
                .Destroy => 0.6,
            };
        }

        return Particle{
            .position = pos,
            .target = targetPos,
            .state = rand.intRangeAtMostBiased(u8, 0, 3),
            .lifetime = rand.intRangeAtMost(u8, 15, 21),
            .particle_type = p,
        };
    }
};
