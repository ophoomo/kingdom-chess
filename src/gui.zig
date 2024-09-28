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
                rl.playSound(self.sound);
                self.hover = false;
            }
        } else {
            self.hover = true;
        }
        return rg.guiButton(self.rect, self.text);
    }
};
