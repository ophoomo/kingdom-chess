const rl = @import("raylib");
const gui = @import("../gui.zig");

pub const BishopEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,

    model: rl.Model,
    healthUI: gui.HealthModel,

    pub fn init(pos: rl.Vector3, model: rl.Model) BishopEntity {
        const healthUI = gui.HealthModel.init();
        return BishopEntity{
            .hp = 100,
            .pos = pos,
            .model = model,
            .healthUI = healthUI,
        };
    }

    pub fn draw(self: *BishopEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0, self.pos.z);
        rl.drawModel(self.model, new_pos, 0.7, rl.Color.white);
    }

    pub fn drawUI(self: *BishopEntity, camera: *rl.Camera) void {
        self.healthUI.draw(camera);
    }

    pub fn attack(self: *BishopEntity) void {
        self.hp -= 1;
        self.healthUI.show(&self.hp, &self.pos);
    }

    pub fn destroy(_: *BishopEntity) void {}
};
