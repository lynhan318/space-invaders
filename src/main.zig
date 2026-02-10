// https://www.youtube.com/watch?v=bD7yZ2GmF5Y&list=PLYA3HD4nElQnxWnznih9w0RloSw0hFaYQ&index=7
const std = @import("std");
const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn interects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width 
        and self.x + self.width > other.x 
        and self.y < other.y + other.height 
        and self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32
};


const Player = struct {
    positionX:f32,
    positionY:f32,
    width:f32,
    height:f32,
    speed:f32,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 10.0
        };
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height
        };
    }

    pub fn update(self: *@This())void{
        if (rl.isKeyDown(rl.KeyboardKey.right)){
            self.positionX += self.speed;
        }
        if(rl.isKeyDown(rl.KeyboardKey.left)){
            self.positionX -= self.speed;
        }
        if(self.positionX < 0){
            self.positionX = 0;
        }
        if(self.positionX + self.width  > @as(f32,@floatFromInt(rl.getScreenWidth()))){
            self.positionX = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }
    pub fn draw(self: @This())void{
        rl.drawRectangle(
            @as(i32,@intFromFloat(self.positionX)),
            @as(i32,@intFromFloat(self.positionY)), 
            @as(i32,@intFromFloat(self.width)), 
            @as(i32,@intFromFloat(self.height)),
            rl.Color.blue
        );
    }
};

const Bullet = struct {
    positionX:f32,
    positionY:f32,
    width:f32,
    height:f32,
    speed:f32,
    active: bool,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 7.0,
            .active = false
        };
    }
    pub fn update(self: *@This())void{
        if(self.active){
            self.positionY -= self.speed;
            if(self.positionY + self.height < 0){
                self.active = false;
            }
        }
    }
    pub fn draw(self: @This())void{
        if(self.active){
            rl.drawRectangle(
                @as(i32,@intFromFloat(self.positionX)),
                @as(i32,@intFromFloat(self.positionY)), 
                @as(i32,@intFromFloat(self.width)), 
                @as(i32,@intFromFloat(self.height)),
                rl.Color.red
            );
        }
    }
};

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;
    rl.initWindow(screenWidth, screenHeight, "Zig Space Invaders");
    defer rl.closeWindow();

    const playerWidth = 50.0;
    const playerHeight = 30.0;
    const maxBullet = 10;
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    var bullets:[maxBullet]Bullet = undefined;

    for(&bullets)|*bullet|{
        bullet.* = Bullet.init(0.0, 0.0, bulletWidth, bulletHeight);
    }

    var player = Player.init(
        @as(f32,@floatFromInt(screenWidth / 2)) - playerWidth / 2,
        @as(f32,@floatFromInt(screenHeight)) - 60.0,
        playerWidth,
        playerHeight
    );

    rl.setTargetFPS(64);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        //UPDATE
        player.update();
        if(rl.isKeyPressed(rl.KeyboardKey.space)){
            for(&bullets)|*bullet|{
                if(!bullet.active){
                    bullet.positionX = player.positionX + player.width / 2 - bullet.width / 2;
                    bullet.positionY = player.positionY;
                    bullet.active = true;
                    break;
                }
            }
        }
        for(&bullets)|*bullet|{
            bullet.update();
        }
        //DRAW
        player.draw();
        for(&bullets)|*bullet|{
            bullet.draw();
        }
        rl.drawText("Space Invaders", 300, 250, 40, rl.Color.green);
    }
}
