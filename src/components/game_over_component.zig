const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const sm = @import("../screen.zig");
const gui = @import("../gui.zig");

pub const GameOverComponent = struct {
    status: bool = false,
    screen: *sm.ScreenManager,

    openSoundStatus: bool = false,
    btnHoverAudio: rl.Sound,
    gameOverSound: rl.Sound,

    overlayAlpha: f32 = 0.0,
    btnBack: gui.button,
    pub fn init(screen: *sm.ScreenManager) GameOverComponent {
        const width: f32 = @floatFromInt(rl.getScreenWidth());
        const height: f32 = @floatFromInt(rl.getScreenHeight());
        const btnwidth = 180.0;
        const btnheight = 40.0;
        const btnHoverAudio = rl.loadSound("resources/audio/button_hover.ogg");
        const gameOverSound = rl.loadSound("resources/audio/game_over.ogg");
        return GameOverComponent{
            .screen = screen,
            .btnHoverAudio = btnHoverAudio,
            .gameOverSound = gameOverSound,
            .btnBack = gui.button{
                .rect = rl.Rectangle.init((width - btnwidth) / 2, ((height - btnheight) / 2) + 50, btnwidth, btnheight),
                .text = "Back",
                .sound = btnHoverAudio,
            },
        };
    }

    pub fn draw(self: *GameOverComponent) void {
        if (self.openSoundStatus) {
            rl.playSound(self.gameOverSound);
            self.openSoundStatus = false;
        }

        if (self.status) {
            if (self.overlayAlpha <= 0.6) self.overlayAlpha += 0.01;
        } else {
            if (self.overlayAlpha >= 0) self.overlayAlpha -= 0.01;
        }

        if (self.overlayAlpha > 0) {
            rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.colorAlpha(rl.Color.black, self.overlayAlpha));
            const text_game_over = "GAME OVER";
            const text_size_game_over = 70;
            const text_width: f32 = @floatFromInt(rl.getScreenWidth() - rl.measureText(text_game_over, text_size_game_over));
            const text_center: i32 = @intFromFloat(text_width / 2);
            rl.drawText(text_game_over, text_center, 200, text_size_game_over, rl.colorAlpha(rl.Color.white, self.overlayAlpha * 2));
            if (self.btnBack.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_right)) {
                self.screen.switchScreen(sm.ScreenType.MainMenu);
            }
        }
    }

    pub fn setGameOver(self: *GameOverComponent) void {
        if (!self.status) {
            self.status = true;
            self.openSoundStatus = true;
        }
    }

    pub fn destroy(self: *GameOverComponent) void {
        rl.unloadSound(self.btnHoverAudio);
        rl.unloadSound(self.gameOverSound);
    }
};
