const std = @import("std");
const rl = @import("raylib");

const Particle = struct {
    position: rl.Vector3,
    target: rl.Vector3,
    state: u8,
    lifetime: u8,
};

pub const ParticleComponent = struct {
    list: std.ArrayList(Particle),

    pub fn init() ParticleComponent {
        const allocator = std.heap.page_allocator;
        return ParticleComponent{
            .list = std.ArrayList(Particle).init(allocator),
        };
    }

    pub fn create(self: *ParticleComponent, pos: rl.Vector3) void {
        var count: f32 = 0.0;
        for (0..25) |_| {
            self.list.append(createParticle(pos, count)) catch |err| {
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
                var color: rl.Color = rl.Color.brown;
                if (item.state == 1) {
                    size = 0.15;
                    color = rl.Color.light_gray;
                } else if (item.state == 2) {
                    size = 0.2;
                    color = rl.Color.gray;
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

    fn createParticle(pos: rl.Vector3, i: f32) Particle {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Caught error: {}\n", .{err});
        };

        var prng = std.Random.DefaultPrng.init(seed);
        const rand = prng.random();

        const angle = i * std.math.pi;
        const radius = 1.0;
        const targetPos = rl.Vector3{
            .x = pos.x + radius * std.math.cos(angle),
            .y = pos.y,
            .z = pos.z + radius * std.math.sin(angle),
        };

        return Particle{
            .position = pos,
            .target = targetPos,
            .state = rand.intRangeAtMostBiased(u8, 0, 3),
            .lifetime = rand.intRangeAtMost(u8, 15, 21),
        };
    }
};
