const rl = @import("raylib");

pub const KnightEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,
    pub fn init(pos: rl.Vector3) KnightEntity {
        return KnightEntity{
            .hp = 100,
            .pos = pos,
        };
    }

    pub fn draw(self: *KnightEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0.4, self.pos.z);
        rl.drawCube(new_pos, 1, 1, 1, rl.Color.green);
    }

    pub fn destroy(_: *KnightEntity) void {}
};
