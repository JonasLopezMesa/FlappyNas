//
//  ViewController.m
//  FlappyJonas
//
//  Created by Jonás López Mesa on 22/06/14.
//  Copyright (c) 2014 Jonás López Mesa. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "MenuScene.h"
@import AVFoundation;

@interface ViewController ()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MenuScene sceneWithSize:skView.bounds.size]; //configura que la primera escena que se vea sea la del menú.
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.physicsWorld.gravity = CGVectorMake(0.0, -6.0); //configura la gravedad que va a estar activa en la escena.
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
