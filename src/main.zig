// https://www.youtube.com/watch?v=bD7yZ2GmF5Y&list=PLYA3HD4nElQnxWnznih9w0RloSw0hFaYQ&index=7
const std = @import("std");
const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
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


const Invader = struct {
    positionX:f32,
    positionY:f32,
    width:f32,
    height:f32,
    speed:f32,
    alive: bool,

    pub fn init(positionX: f32, positionY: f32, width: f32, height: f32) @This() {
        return .{
            .positionX = positionX,
            .positionY = positionY,
            .width = width,
            .height = height,
            .speed = 2.0,
            .alive = true
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
    pub fn draw(self: @This())void{
        if(self.alive){
            rl.drawRectangle(
                @as(i32,@intFromFloat(self.positionX)),
                @as(i32,@intFromFloat(self.positionY)), 
                @as(i32,@intFromFloat(self.width)), 
                @as(i32,@intFromFloat(self.height)),
                rl.Color.green
            );
        }
    }

    pub fn update(self: *@This(), dx:f32,dy:f32)void{
        self.positionX += dx;
        self.positionY += dy;
        
    }
};

const Bullet = struct {
    positionX:f32,
    positionY:f32,
    width:f32,
    height:f32,
    speed:f32,
    active: bool,

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.positionX,
            .y = self.positionY,
            .width = self.width,
            .height = self.height
        };
    }

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

fn drawInvaders(invaders: anytype)void{
    for(invaders)|*row|{
        for(row)|*bullet|{
            bullet.draw();
        }
    }
}

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
    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth= 40;
    const invaderHeight = 30;
    const invaderStartX = 100;
    const invaderStartY = 50;
    const invaderSpacingX = invaderWidth + 20;
    const invaderSpacingY = invaderHeight + 10;
    const invaderSpeed = 5.0;
    const invaderMoveDelay = 30;
    const invaderDropDistance = 20;
    var invader_direction:f32 = 1.0;
    var move_timer:i32 = 0;
    var score = 0;

    var bullets:[maxBullet]Bullet = undefined;

    for(&bullets)|*bullet|{
        bullet.* = Bullet.init(0.0, 0.0, bulletWidth, bulletHeight);
    }
    var invaders: [invaderRows][invaderCols]Invader = undefined;

    for(&invaders,0..) |*row,i|{
        for(row,0..)|*invader,j| {
            const x = invaderStartX + @as(i32,@intFromFloat(invaderSpacingX)) * j;
            const y = invaderStartY + @as(i32,@intFromFloat(invaderSpacingY)) * i;
            invader.* = Invader.init(
                @as(f32,@floatFromInt(x)),
                @as(f32,@floatFromInt(y)),
                @as(f32,@floatFromInt(invaderWidth)),
                @as(f32,@floatFromInt(invaderHeight))
            );
            
        }
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
        for(&bullets)|*bullet|{
            if(bullet.active){
                for(&invaders)|*row|{
                    for(row)|invader|{
                        if(invader.alive){
                            if(invader.getRect().intersects(bullet.getRect())){
                                invader.alive = false;
                                bullet.active = false;
                                score += 10;
                                break;
                            }
                        }

                    }
                }
            }

        }

        move_timer += 1;
        if(move_timer >= invaderMoveDelay){
            move_timer = 0;
            //check edges
            var hitEdge = false;
            for(&invaders) |*row|{
                for(row)|*invader| {
                    if(invader.alive){
                        const nextX = invader.positionX + invader_direction * invaderSpeed;
                        if(nextX < 0  or nextX+invader.width > @as(f32,@floatFromInt(screenWidth))){
                            hitEdge = true;
                            break;
                        }
                    }
                }
                if(hitEdge) break; 
            }
            if(hitEdge){
                invader_direction *= -1.0;
                for(&invaders) |*row|{
                    for(row)|*invader| {
                        invader.update(0.0, invaderDropDistance);
                    }
                }
            } else {
                for(&invaders) |*row|{
                    for(row)|*invader| {
                        invader.update(invader_direction * invaderSpeed, 0.0);
                    }
                }
            }
        }


        //DRAW
        player.draw();
        for(&bullets)|*bullet|{
            bullet.draw();
        }
        drawInvaders(&invaders);
        const score_text = rl.textFormat("Store %d",.{score});
        rl.drawText(score_text, 20, screenHeight-20, 20, rl.Color.white);
        rl.drawText("Press SPACE to shoot, ESC to exit", 20, 50, 20, rl.Color.green);
    }
}
