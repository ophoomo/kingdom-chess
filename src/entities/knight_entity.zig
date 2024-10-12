const rl = @import("raylib");
const gui = @import("../gui.zig");

pub const KnightEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,

    model: rl.Model,
    healthUI: gui.HealthModel,

    pub fn init(pos: rl.Vector3, model: rl.Model) KnightEntity {
        const healthUI = gui.HealthModel.init();
        return KnightEntity{
            .hp = 100,
            .pos = pos,
            .model = model,
            .healthUI = healthUI,
        };
    }

    pub fn draw(self: *KnightEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0, self.pos.z);
        rl.drawModel(self.model, new_pos, 0.7, rl.Color.white);
    }

    pub fn drawUI(self: *KnightEntity, camera: *rl.Camera) void {
        self.healthUI.draw(camera);
    }

    pub fn attack(self: *KnightEntity) void {
        self.hp -= 1;
        self.healthUI.show(&self.hp, &self.pos);
    }

    pub fn destroy(_: *KnightEntity) void {}
};
