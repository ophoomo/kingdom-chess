const rl = @import("raylib");
const gui = @import("../gui.zig");

pub const KingEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,

    model: rl.Model,
    healthUI: gui.HealthModel,

    pub fn init(pos: rl.Vector3, model: rl.Model) KingEntity {
        const healthUI = gui.HealthModel.init();
        return KingEntity{
            .hp = 100,
            .pos = pos,
            .model = model,
            .healthUI = healthUI,
        };
    }

    pub fn draw(self: *KingEntity) void {
        if (rl.isKeyPressed(.key_o)) {
            self.attack();
        }
        const new_pos = rl.Vector3.init(self.pos.x, 0, self.pos.z);
        rl.drawModel(self.model, new_pos, 0.7, rl.Color.white);
    }

    pub fn drawUI(self: *KingEntity, camera: *rl.Camera) void {
        self.healthUI.draw(camera);
    }

    pub fn attack(self: *KingEntity) void {
        self.hp -= 1;
        self.healthUI.show(&self.hp, &self.pos);
    }

    pub fn destroy(_: *KingEntity) void {}
};
