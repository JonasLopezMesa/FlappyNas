//
//  MyScene.m
//  FlappyJonas
//
//  Created by Jonás López Mesa on 22/06/14.
//  Copyright (c) 2014 Jonás López Mesa. All rights reserved.
//

#import "MyScene.h"
#import "MenuScene.h"

@import AVFoundation; //Usado para reproducir audio
@implementation MyScene

static const uint32_t birdCategory = 0x1 << 0;  //Categoría pájaro; para las colisiones
static const uint32_t pipeCategory = 0x1 << 1;  //Categoría tubería; para las colisiones

//Función que crea y muestra por pantalla las tuberías
-(void)spawnPipes{
    int random = (arc4random()%(int)self.frame.size.height-150)+200;
    
    //Colocación del final de la tubería superior.
    SKSpriteNode *upperPipe = [SKSpriteNode spriteNodeWithImageNamed:@"alto.png"];
    upperPipe.size = CGSizeMake(70, 25);
    upperPipe.position = CGPointMake(450, random);
    
    //Colocación del final de la tubería inferior
    SKSpriteNode *lowerPipe = [SKSpriteNode spriteNodeWithImageNamed:@"alto.png"];
    lowerPipe.size = CGSizeMake(70, 25);
    lowerPipe.position = CGPointMake(upperPipe.position.x, upperPipe.position.y-150);
    
    //Colocación del medio de la tubería superior
    SKSpriteNode *restBelow = [SKSpriteNode spriteNodeWithImageNamed:@"medio.png"];
    restBelow.size = CGSizeMake(60, lowerPipe.position.y);
    restBelow.position = CGPointMake(lowerPipe.position.x, ((lowerPipe.position.y-restBelow.size.height/2))-(lowerPipe.size.height/2+1));
    
    //Colocación del medio de la tubería inferior
    SKSpriteNode *restAbove = [SKSpriteNode spriteNodeWithImageNamed:@"medio.png"];
    restAbove.size = CGSizeMake(60, self.frame.size.height+upperPipe.position.y);
    restAbove.position = CGPointMake(upperPipe.position.x, (upperPipe.position.y+restAbove.size.height/2)+((upperPipe.size.height/2)-2));
    
    //Crea los objetos hijos
    [self addChild:upperPipe];
    [self addChild:lowerPipe];
    [self addChild:restBelow];
    [self addChild:restAbove];
    
    //Introduce en el vector de tuberías las dos tuberías completas generadas
    [pipeArray addObject:upperPipe];
    [pipeArray addObject:lowerPipe];
    [pipeArray addObject:restBelow];
    [pipeArray addObject:restAbove];
    
    //Configuración de la física de las tuberías
    for (int i = 0; i < [pipeArray count] ; i++) {
        SKSpriteNode *sprite = [pipeArray objectAtIndex:i];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.frame.size];
        sprite.physicsBody.usesPreciseCollisionDetection = YES;
        sprite.physicsBody.categoryBitMask = pipeCategory; //Categoría de tubería
        sprite.physicsBody.affectedByGravity = NO;
        sprite.physicsBody.dynamic = NO;
        sprite.physicsBody.mass = 1000.0;
        sprite.name = [NSString stringWithFormat:@"beforeBird"];
    }
}

//configuración de inicio de la escena
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        pipeArray = [[NSMutableArray alloc]init];
        score = 0; //puntuación de inicio
        
        //Instanciar el pájaro y su física
        bird = [SKSpriteNode spriteNodeWithImageNamed:@"bird.png"];
        bird.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        bird.size = CGSizeMake(30, 30);
        bird.zPosition = 3;
        
        bird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bird.frame.size];
        bird.physicsBody.usesPreciseCollisionDetection = YES;
        bird.physicsBody.mass = 0.2;
        bird.physicsBody.affectedByGravity = NO;
        bird.physicsBody.categoryBitMask = birdCategory;
        bird.physicsBody.dynamic = YES;
        
        bird.physicsBody.collisionBitMask = birdCategory | pipeCategory;
        bird.physicsBody.contactTestBitMask = birdCategory | pipeCategory;
        [self addChild:bird];
        
        //Instanciar el Label de la puntuación de inicio
        scoreLbl = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLbl.text = [NSString stringWithFormat:@"%d",score];
        scoreLbl.fontColor = [SKColor blackColor];
        scoreLbl.fontSize = 40;
        scoreLbl.position = CGPointMake(self.size.width/2, self.size.height/1.5);
        scoreLbl.zPosition = 2;
        [self addChild:scoreLbl];
        
        //Instanciar el fondo
        bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg2.png"];
        bg.position = CGPointMake(160, 200);
        bg.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self addChild:bg];
        
        //Instanciar cielo
        sky = [SKSpriteNode spriteNodeWithImageNamed:@"cielo.png"];
        sky.position = CGPointMake(160, 420);
        sky.size = CGSizeMake(self.frame.size.width, 120);
        [self addChild:sky];
        
        //Instanciar el suelo
        flor = [SKSpriteNode spriteNodeWithImageNamed:@"suelo.png"];
        flor.position = CGPointMake(160, 1);
        flor.size = CGSizeMake(self.frame.size.width, 10);
        flor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:flor.frame.size];
        flor.physicsBody.usesPreciseCollisionDetection = YES;
        flor.physicsBody.mass = 100000.0;
        flor.physicsBody.dynamic = NO;
        flor.physicsBody.affectedByGravity = NO;
        [self addChild:flor];
        
        [self spawnPipes];
        
        //Función que hace que las tuberías avancen con el tiempo
        timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(spawnPipes) userInfo:nil repeats:YES];
        
        firstTouch = YES;
        
    }
    return self;
}

//Función que actúa cuando se realiza un contacto entre dos objetos
-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKSpriteNode *firstSprite;
    SKSpriteNode *secondSprite;
    
    firstSprite = (SKSpriteNode *)contact.bodyA.node;
    secondSprite = (SKSpriteNode *)contact.bodyB.node;
    //Si un objeto de la categoría pájaro y otro de la categoría tubería contactan, colisionan:
    if ((contact.bodyA.categoryBitMask == birdCategory) && (contact.bodyB.categoryBitMask == pipeCategory)) {
        [self runAction:[SKAction playSoundFileNamed:@"fracaso.caf" waitForCompletion:NO]]; //Sonido de game over
        [pipeArray removeAllObjects]; //Vacía el vector de tuberías
        //[bird.physicsBody setAffectedByGravity:NO]; //El pájaro deja de ser afectado por la Gravedad
        [timer invalidate]; //Se deja de avanzar
        scoreLbl.fontSize = 30; //Se configura el tamaño del label de la puntuación
        scoreLbl.text = [NSString stringWithFormat:@"GAME OVER %d", score/2]; //Se escribe Game Over y la puntuación en la puntuación
        //Guardar la puntuación en un fichero
        
        
        //Instanciación del objeto Game Over
        SKSpriteNode *gameOverMenu = [SKSpriteNode spriteNodeWithImageNamed:@"gameover.png"];
        gameOverMenu.position = CGPointMake(self.size.width/2, self.size.height/2);
        gameOverMenu.size = CGSizeMake(300, 250);
        [self addChild:gameOverMenu];
        //Instanciación del objeto que muestra la puntuación sobre el objeto Game Over
        SKLabelNode *gameOverLbl = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        gameOverLbl.text = [NSString stringWithFormat:@"Score: %d", score];
        gameOverLbl.fontSize = 30;
        gameOverLbl.fontColor = [SKColor blackColor];
        gameOverLbl.position = CGPointMake(gameOverMenu.position.x, gameOverMenu.position.y);
        [self addChild:gameOverLbl];
        //Instanciación del objeto del botón replay
        SKSpriteNode *replayButton = [SKSpriteNode spriteNodeWithImageNamed:@"replay.png"];
        replayButton.position = CGPointMake(gameOverMenu.position.x-80, gameOverMenu.position.y-70);
        replayButton.size = CGSizeMake(70, 70);
        replayButton.name = @"replayButton";
        [self addChild:replayButton];
        //Instanciación del objeto del botón de home
        SKSpriteNode *homeButton = [SKSpriteNode spriteNodeWithImageNamed:@"home.png"];
        homeButton.position = CGPointMake(gameOverMenu.position.x+80, gameOverMenu.position.y-70);
        homeButton.size = CGSizeMake(70, 70);
        homeButton.name = @"homeButton";
        [self addChild:homeButton];
    }
}
-(void)didMoveToView:(SKView *)view {
    self.physicsWorld.contactDelegate = self;
}
//Función que se ejecuta al pulsar sobre la pantalla
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self runAction:[SKAction playSoundFileNamed:@"saltito.caf" waitForCompletion:NO]]; //Sonido de salto
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    if ([node.name isEqualToString:@"replayButton"]) {
        [self removeFromParent];
        
        SKTransition *transition = [SKTransition fadeWithDuration:0.5];
        MyScene *gameScene = [[MyScene alloc]initWithSize:CGSizeMake(self.size.width, self.size.height)];
        [self.scene.view presentScene:gameScene transition:transition];
    } else if ([node.name isEqualToString:@"homeButton"]){
        SKTransition *transition = [SKTransition fadeWithDuration:0.5];
        MenuScene *gameScene = [[MenuScene alloc]initWithSize:CGSizeMake(self.size.width, self.size.height)];
        [self.scene.view presentScene:gameScene transition:transition];
    }
    [bird.physicsBody applyImpulse:CGVectorMake(0.0, 100)];
    if (firstTouch == YES) { //Control de la primera pulsación.
        firstTouch = NO;
        bird.physicsBody.affectedByGravity = YES;
    }
    
}
//Función que se ejecuta antes de que se renderize cada Frame
-(void)update:(CFTimeInterval)currentTime {
    //Si hay más de un par de tuberías
    if ([pipeArray count] > 1) {
        SKSpriteNode *sprite = [pipeArray objectAtIndex:1];
        //If que controla la puntuación
        if ((sprite.position.x < bird.position.x) && ([sprite.name isEqualToString:@"beforeBird"]) && (sprite.position.x > 0)) {
            score++; //Incrementa la puntuación
            scoreLbl.text = [NSString stringWithFormat:@"%d", score/2]; //Muestra en el Lbl la puntuación
            sprite.name = @"afterBird";
        }
    }
    //Parte de la función que elimina las tuberías que ya han salido de la pantalla de el vector de tuberías
    for (int i = 0; i < [pipeArray count]; i++) {
        SKSpriteNode *pipe = [pipeArray objectAtIndex:i];
        //If que controla la posición de la tubería
        if (pipe.position.x < -50) { // Si la posición de la tubería desaparece de la pantalla
            SKSpriteNode *spNext = [[SKSpriteNode alloc]init];
            spNext = [pipeArray objectAtIndex:i+1];
            spNext.position = CGPointMake(spNext.position.x-3, spNext.position.y);
            [pipe removeFromParent];
            [pipeArray removeObject:pipe];
        }
        pipe.position = CGPointMake(pipe.position.x-3, pipe.position.y);
    }
}

@end
