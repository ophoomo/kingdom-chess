const rl = @import("raylib");
const rg = @import("raygui");
const gui = @import("../gui.zig");

pub const ShopComponent = struct {
    money: i32,
    pub fn init() ShopComponent {
        return ShopComponent{
            .money = 0,
        };
    }

    pub fn draw(self: *ShopComponent) void {
        rl.drawText(rl.textFormat("Money %d", .{self.money}), 30, 50, 16, rl.Color.red);
    }

    pub fn destroy(_: *ShopComponent) void {}

    pub fn mouseEvent(_: *ShopComponent, _: rl.Ray) void {}
};
