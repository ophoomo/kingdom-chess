const rl = @import("raylib");

pub const BishopEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,
    pub fn init(pos: rl.Vector3) BishopEntity {
        return BishopEntity{
            .hp = 100,
            .pos = pos,
        };
    }

    pub fn draw(self: *BishopEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0.4, self.pos.z);
        rl.drawCube(new_pos, 1, 1, 1, rl.Color.blue);
    }

    pub fn destroy(_: *BishopEntity) void {}
};
