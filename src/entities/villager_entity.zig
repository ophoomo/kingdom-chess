const rl = @import("raylib");

pub const VillagerEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,
    pub fn init(pos: rl.Vector3) VillagerEntity {
        return VillagerEntity{
            .hp = 100,
            .pos = pos,
        };
    }

    pub fn draw(self: *VillagerEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0.4, self.pos.z);
        rl.drawCube(new_pos, 1, 1, 1, rl.Color.yellow);
    }

    pub fn destroy(_: *VillagerEntity) void {}
};
