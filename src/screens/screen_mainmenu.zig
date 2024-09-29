const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const sm = @import("../screen.zig");
const gui = @import("../gui.zig");

pub const ScreenMainMenu = struct {
    camera: rl.Camera3D,
    screen: *sm.ScreenManager,
    background: rl.Music,

    btnHover: rl.Sound,
    btnStart: gui.button,
    btnExit: gui.button,

    shader: rl.Shader,
    pub fn onEnter(self: *ScreenMainMenu, screen: *sm.ScreenManager) void {
        rl.traceLog(.log_debug, "Enter MainMenu");

        self.camera = rl.Camera3D{
            .position = rl.Vector3.init(0, 1, 6),
            .target = rl.Vector3.init(0, 0, 0),
            .up = rl.Vector3.init(0, 1, 0),
            .fovy = 45,
            .projection = .camera_perspective,
        };

        self.shader = rl.loadShader("resources/shaders/lighting.vs", "resources/shaders/fog.fs");
        // self.shader.locs[rl.SHADER_LOC_MATRIX_MODEL] = rl.getShaderLocation(self.shader, "matModel");
        // self.shader.locs[rl.SHADER_LOC_VECTOR_VIEW] = rl.getShaderLocation(self.shader, "viewPos");

        const ambientLoc = rl.getShaderLocation(self.shader, "ambient");
        rl.setShaderValue(self.shader, ambientLoc, &[_]f32{ 0.2, 0.2, 0.2, 1.0 }, .shader_uniform_ivec4);

        const fogDensity: f32 = 0.15;
        const fogDensityLoc = rl.getShaderLocation(self.shader, "fogDensity");
        rl.setShaderValue(self.shader, fogDensityLoc, &fogDensity, .shader_uniform_float);

        self.screen = screen;
        self.btnHover = rl.loadSound("resources/audio/button_hover.ogg");
        self.background = rl.loadMusicStream("resources/music/mainmenu.mp3");
        rl.setMusicVolume(self.background, 0.4);
        rl.playMusicStream(self.background);

        const padding: f32 = 50.0;
        const btnSpacing: f32 = 10.0;
        const height: f32 = @floatFromInt(rl.getRenderHeight());
        const btnwidth = 200.0;
        const btnheight = 40.0;

        self.btnStart = gui.button{
            .rect = rl.Rectangle.init(padding, height - btnheight * 2 - btnSpacing - padding, btnwidth, btnheight),
            .text = "START GAME",
            .sound = self.btnHover,
        };

        self.btnExit = gui.button{
            .rect = rl.Rectangle.init(padding, height - btnheight - padding, btnwidth, btnheight),
            .text = "Exit",
            .sound = self.btnHover,
        };
    }

    pub fn onUpdate(self: *ScreenMainMenu) void {
        // rl.setShaderValue(self.shader, self.shader[rl.SHADER_LOC_VECTOR_VIEW], self.camera.position.x, .shader_uniform_vec3);
        rl.updateMusicStream(self.background);
        rl.updateCamera(&self.camera, .camera_custom);

        rl.beginMode3D(self.camera);
        rl.drawCube(rl.Vector3.init(0, 0, 0), 2, 2, 2, rl.Color.red);
        rl.drawGrid(10, 1.0);
        rl.endMode3D();

        if (self.btnStart.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_down)) {
            self.screen.switchScreen(sm.ScreenType.Game);
        }

        if (self.btnExit.draw() == 1 or rl.isGamepadButtonPressed(0, .gamepad_button_right_face_right)) {
            self.screen.close = true;
        }

        rl.drawText("Alpha Test", rl.getRenderWidth() - 100, rl.getRenderHeight() - 30, 16, rl.Color.white);
    }

    pub fn onExit(self: *ScreenMainMenu) void {
        rl.traceLog(.log_debug, "Exit MainMenu");
        rl.unloadMusicStream(self.background);
        rl.unloadShader(self.shader);
        rl.unloadSound(self.btnHover);
    }
};
