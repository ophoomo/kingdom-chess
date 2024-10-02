const rl = @import("raylib");
const rg = @import("raygui");
const gui = @import("../gui.zig");

pub const ShopComponent = struct {
    pub fn init() ShopComponent {
        return ShopComponent{};
    }

    pub fn draw(_: *ShopComponent) void {}

    pub fn destroy(_: *ShopComponent) void {}
};
