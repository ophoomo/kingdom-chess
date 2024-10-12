const rl = @import("raylib");
const rg = @import("raygui");

pub const button = struct {
    rect: rl.Rectangle,
    sound: rl.Sound,
    hover: bool = true,
    text: [*:0]const u8,
    pub fn draw(self: *button) i32 {
        if (rl.checkCollisionPointRec(rl.getMousePosition(), self.rect)) {
            if (self.hover) {
                rl.setSoundVolume(self.sound, 0.5);
                rl.playSound(self.sound);
                self.hover = false;
            }
        } else {
            self.hover = true;
        }
        return rg.guiButton(self.rect, self.text);
    }
};

pub const HealthModel = struct {
    timer: f32 = undefined,
    pos: *rl.Vector3 = undefined,
    hp: *i32 = undefined,

    pub fn init() HealthModel {
        return HealthModel{};
    }

    pub fn draw(self: *HealthModel, camera: *rl.Camera) void {
        if (self.timer > 0) {
            const modelScreenPosition = rl.getWorldToScreen(rl.Vector3.init(self.pos.*.x, 1.3, self.pos.*.z), camera.*);
            const text = rl.textFormat("%d / 100", .{self.hp.*});
            const text_size = 15;
            const text_offset = @as(f32, @floatFromInt(rl.measureText(text, text_size)));
            const pos_x: f32 = modelScreenPosition.x - text_offset / 2;

            const color = if (self.hp.* > 20) rl.Color.green else rl.Color.red;

            rl.drawText(text, @as(i32, @intFromFloat(pos_x)), @as(i32, @intFromFloat(modelScreenPosition.y)), text_size, rl.Color.alpha(color, self.timer));
            self.timer -= 0.1;
        }
    }

    pub fn show(self: *HealthModel, hp: *i32, pos: *rl.Vector3) void {
        self.timer = 10.0;
        self.hp = hp;
        self.pos = pos;
    }
};
