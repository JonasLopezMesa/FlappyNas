//
//  MyScene.h
//  FlappyJonas
//

//  Copyright (c) 2014 Jonás López Mesa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate> {
    SKSpriteNode *bird; //Objeto del pájaro
    SKSpriteNode *bg; //Objeto del fondo
    SKSpriteNode *flor; //Objeto del suelo
    SKSpriteNode *sky; //Objeto del cielo
    
    NSMutableArray *pipeArray; //vector de tuberías
    int score; //Variable que almacena la puntuación
    SKLabelNode *scoreLbl; //Label que mostrará la puntuación
    
    NSTimer *timer;
    BOOL firstTouch; //Variable que determinará si se ha empezado a jugar o no
}

-(void)spawnPipes;

@end
