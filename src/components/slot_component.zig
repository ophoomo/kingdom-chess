const rl = @import("raylib");
const rg = @import("raygui");
const gui = @import("../gui.zig");
const object_enum = @import("../enums/object_enum.zig");

pub const SlotComponent = struct {
    select: object_enum.object_enum = undefined,
    slots: [6]i32 = undefined,

    pub fn init() SlotComponent {
        return SlotComponent{
            .select = undefined,
        };
    }

    pub fn draw(self: *SlotComponent) void {
        if (rl.isKeyPressed(.key_a)) {
            self.select = .King;
        }
        if (rl.isKeyPressed(.key_b)) {
            self.select = .Bishop;
        }
        if (rl.isKeyPressed(.key_c)) {
            self.select = .Knight;
        }
    }

    pub fn destroy(_: *SlotComponent) void {}

    pub fn mouseEvent(_: *SlotComponent, _: rl.Ray) void {}
};
