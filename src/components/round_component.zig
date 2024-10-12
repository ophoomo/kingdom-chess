const rl = @import("raylib");
const rg = @import("raygui");
const gui = @import("../gui.zig");

pub const RoundComponent = struct {
    btnHoverAudio: rl.Sound,

    btnStart: gui.button,

    king_ready: bool = false,

    round: i32 = 0,

    status: bool = false,

    pub fn init() RoundComponent {
        const btnHoverAudio = rl.loadSound("resources/audio/button_hover.ogg");
        const width: f32 = @floatFromInt(rl.getScreenWidth());
        const btnwidth = 180.0;
        const btnheight = 40.0;
        return RoundComponent{
            .round = 1,
            .btnHoverAudio = btnHoverAudio,
            .btnStart = gui.button{
                .rect = rl.Rectangle.init((width - btnwidth) / 2, 30, btnwidth, btnheight),
                .text = "Start Round",
                .sound = btnHoverAudio,
            },
        };
    }

    pub fn draw(self: *RoundComponent) void {
        if (self.status) {
            const text = rl.textFormat("Round %d", .{self.round});
            const text_size = 30;
            const text_offset = rl.measureText(text, text_size);
            const pos_x = @as(f32, @floatFromInt((rl.getScreenWidth() - text_offset))) / 2;
            rl.drawText(text, @as(i32, @intFromFloat(pos_x)), 30, text_size, rl.Color.red);
        } else {
            if (self.king_ready) {
                if (self.btnStart.draw() == 1) {
                    self.status = true;
                }
            }
        }
    }

    pub fn endRound(self: *RoundComponent) void {
        self.status = false;
        self.round += 1;
    }

    pub fn destroy(self: *RoundComponent) void {
        rl.unloadSound(self.btnHoverAudio);
    }

    pub fn mouseEvent(_: *RoundComponent, _: rl.Ray) void {}
};
