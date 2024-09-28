const rl = @import("raylib");
const rg = @import("raygui");
const sm = @import("../screen.zig");
const gui = @import("../gui.zig");

pub const MenuComponent = struct {
    status: bool = false,
    screen: *sm.ScreenManager,
    hoverSound: rl.Sound,

    btnBack: gui.button,
    pub fn init(screen: *sm.ScreenManager, hoverSound: rl.Sound) MenuComponent {
        const width: f32 = @floatFromInt(rl.getRenderWidth());
        const height: f32 = @floatFromInt(rl.getRenderHeight());
        const btnwidth = 180.0;
        const btnheight = 40.0;
        return MenuComponent{ .screen = screen, .hoverSound = hoverSound, .btnBack = gui.button{
            .rect = rl.Rectangle.init((width - btnwidth) / 2, ((height - btnheight) / 2) + 50, btnwidth, btnheight),
            .text = "Back",
            .sound = hoverSound,
        } };
    }

    pub fn draw(self: *MenuComponent) void {
        if (rl.isKeyPressed(.key_escape)) {
            self.status = !self.status;
        }

        if (self.status) {
            rl.drawRectangle(0, 0, rl.getRenderWidth(), rl.getRenderHeight(), rl.colorAlpha(rl.Color.black, 0.6));
            if (self.btnBack.draw() == 1) {
                self.screen.switchScreen(sm.ScreenType.MainMenu);
            }
        }
    }
};
