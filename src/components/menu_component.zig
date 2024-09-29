const rl = @import("raylib");
const rg = @import("raygui");
const sm = @import("../screen.zig");
const gui = @import("../gui.zig");

pub const MenuComponent = struct {
    status: bool = false,
    screen: *sm.ScreenManager,
    hoverSound: rl.Sound,
    openSound: rl.Sound,

    openSoundStatus: bool = false,

    overlayAlpha: f32 = 0.0,
    btnBack: gui.button,
    pub fn init(screen: *sm.ScreenManager, hoverSound: rl.Sound) MenuComponent {
        const width: f32 = @floatFromInt(rl.getRenderWidth());
        const height: f32 = @floatFromInt(rl.getRenderHeight());
        const btnwidth = 180.0;
        const btnheight = 40.0;
        const openSound = rl.loadSound("resources/audio/open_menu.ogg");
        rl.setSoundVolume(openSound, 0.3);
        return MenuComponent{
            .screen = screen,
            .hoverSound = hoverSound,
            .btnBack = gui.button{
                .rect = rl.Rectangle.init((width - btnwidth) / 2, ((height - btnheight) / 2) + 50, btnwidth, btnheight),
                .text = "Back",
                .sound = hoverSound,
            },
            .openSound = openSound,
        };
    }

    pub fn draw(self: *MenuComponent) void {
        if (rl.isKeyPressed(.key_escape) or rl.isGamepadButtonPressed(0, .gamepad_button_middle_right)) {
            if (self.status == false) self.openSoundStatus = true;
            self.status = !self.status;
        }

        if (self.openSoundStatus) {
            if (self.overlayAlpha > 0.2) {
                rl.playSound(self.openSound);
                self.openSoundStatus = false;
            }
        }

        if (self.status) {
            if (self.overlayAlpha <= 0.6) self.overlayAlpha += 0.15;
        } else {
            if (self.overlayAlpha >= 0) self.overlayAlpha -= 0.15;
        }

        if (self.overlayAlpha > 0) {
            rl.drawRectangle(0, 0, rl.getRenderWidth(), rl.getRenderHeight(), rl.colorAlpha(rl.Color.black, self.overlayAlpha));
            if (self.overlayAlpha > 0.2) {
                if (self.btnBack.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_right)) {
                    self.screen.switchScreen(sm.ScreenType.MainMenu);
                }
            }
        }
    }

    pub fn destroy(self: *MenuComponent) void {
        rl.unloadSound(self.openSound);
    }
};
