const rl = @import("raylib");

pub const KingEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,
    pub fn init(pos: rl.Vector3) KingEntity {
        return KingEntity{
            .hp = 100,
            .pos = pos,
        };
    }

    pub fn draw(self: *KingEntity) void {
        if (rl.isKeyPressed(.key_d)) {
            self.hp = 0;
        }
        const new_pos = rl.Vector3.init(self.pos.x, 0.4, self.pos.z);
        rl.drawCube(new_pos, 1, 1, 1, rl.Color.red);
    }

    pub fn destroy(_: *KingEntity) void {}
};
