const rl = @import("raylib");
const gui = @import("../gui.zig");

pub const VillagerEntity = struct {
    hp: i32 = 100,
    pos: rl.Vector3 = undefined,

    model: rl.Model,
    healthUI: gui.HealthModel,

    pub fn init(pos: rl.Vector3, model: rl.Model) VillagerEntity {
        const healthUI = gui.HealthModel.init();
        return VillagerEntity{
            .hp = 100,
            .pos = pos,
            .model = model,
            .healthUI = healthUI,
        };
    }

    pub fn draw(self: *VillagerEntity) void {
        const new_pos = rl.Vector3.init(self.pos.x, 0, self.pos.z);
        rl.drawModel(self.model, new_pos, 0.7, rl.Color.white);
    }

    pub fn drawUI(self: *VillagerEntity, camera: *rl.Camera) void {
        self.healthUI.draw(camera);
    }

    pub fn attack(self: *VillagerEntity) void {
        self.hp -= 1;
        self.healthUI.show(&self.hp, &self.pos);
    }

    pub fn earn(_: *VillagerEntity, money: *i32) void {
        money.* += 1;
    }

    pub fn destroy(_: *VillagerEntity) void {}
};
