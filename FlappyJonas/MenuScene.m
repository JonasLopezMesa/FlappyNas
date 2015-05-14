//
//  MenuScene.m
//  FlappyJonas
//
//  Created by Jonás López Mesa on 22/06/14.
//  Copyright (c) 2014 Jonás López Mesa. All rights reserved.
//

#import "MenuScene.h"
#import "MyScene.h"

@implementation MenuScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg2.png"];
        bg.position = CGPointMake(160, 284);
        bg.size = CGSizeMake(320, 560);
        
        SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"play.png"];
        playButton.position = CGPointMake(self.size.width/2, self.size.height/2);
        playButton.size = CGSizeMake(100, 100);
        playButton.name = @"playButton";
        
        [self addChild:bg];
        [self addChild:playButton];
        
    }
    return self;
}

//Función que es llamada cuando se toca la pantalla
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    //Si se ha pulsado encima del botón de play
    if ([node.name isEqualToString:@"playButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"saltito.caf" waitForCompletion:NO]];
        //SKTransition *transition = [SKTransition fadeWithDuration:0.5]; //Se crea una transición de X segundos, la transición es fade.
        SKTransition *transition = [SKTransition doorsOpenHorizontalWithDuration:1]; //Transición de que se abra una puerta
        MyScene *gameScene = [[MyScene alloc]initWithSize:CGSizeMake(self.size.width, self.size.height)];
        [self.scene.view presentScene:gameScene transition:transition];
    }
}

@end
