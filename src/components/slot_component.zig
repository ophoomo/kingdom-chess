const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const gui = @import("../gui.zig");
const object_enum = @import("../enums/object_enum.zig");

const slot_struct = struct {
    rect: rl.Rectangle,
    slot: object_enum.object_enum,
};

pub const SlotComponent = struct {
    select: object_enum.object_enum = .None,
    hover: i32 = -1,
    slots: [6]slot_struct,

    pub fn init() SlotComponent {
        var slots: [6]slot_struct = undefined;
        const rect_size = 150;
        const height = @as(f32, @floatFromInt(rl.getScreenHeight() - 160));

        for (&slots, 0..) |*item, i| {
            const offset: f32 = @as(f32, @floatFromInt(i)) * 10.0;
            const width: f32 = 100.0 + offset + (@as(f32, @floatFromInt(i)) * rect_size);
            const rect = rl.Rectangle.init(width, height, rect_size, rect_size);
            item.* = slot_struct{
                .rect = rect,
                .slot = switch (i) {
                    0 => .King,
                    else => .None,
                },
            };
        }

        return SlotComponent{
            .select = .None,
            .slots = slots,
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
        if (rl.isKeyPressed(.key_d)) {
            self.select = .Villager;
        }

        for (0..self.slots.len) |i| {
            const item = self.slots[i];
            if (self.select != .None and self.select == item.slot) {
                rl.drawRectangleRec(item.rect, rl.Color.green);
            } else {
                if (self.hover == @as(i32, @intCast(i))) {
                    rl.drawRectangleRec(item.rect, rl.Color.light_gray);
                } else {
                    rl.drawRectangleRec(item.rect, rl.Color.gray);
                }
            }
            switch (item.slot) {
                .King => {
                    const rect = rl.Rectangle.init(item.rect.x, item.rect.y, item.rect.width - 20, item.rect.height - 20);
                    rl.drawRectangleRec(rect, rl.Color.yellow);
                },
                .Bishop => {},
                .Knight => {},
                .Villager => {},
                .None => {},
            }
        }
    }

    pub fn destroy(_: *SlotComponent) void {}

    pub fn mouseEvent(self: *SlotComponent, vec2: rl.Vector2) void {
        for (self.slots, 0..) |item, i| {
            if (rl.checkCollisionPointRec(vec2, item.rect)) {
                if (rl.isMouseButtonPressed(.mouse_button_left)) {
                    self.select = item.slot;
                }
                self.hover = @as(i32, @intCast(i));
                break;
            } else {
                self.hover = -1;
            }
        }
    }
};
