//
//  IXVideoControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/16/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXMediaPlayer.h"
#import "IXAppManager.h"
#import "IXNavigationViewController.h"
#import "IXViewController.h"
#import "ALMoviePlayerController.h"

// IXMediaPlayer Attributes
IX_STATIC_CONST_STRING kIXAutoPlayEnabled = @"autoPlay.enabled";
IX_STATIC_CONST_STRING kIXBarColor = @"bar.color";
IX_STATIC_CONST_STRING kIXBarSize = @"bar.size.h";
IX_STATIC_CONST_STRING kIXPlayerControls = @"playerControls"; //default
IX_STATIC_CONST_STRING kIXVideoUrl = @"videoUrl";

// IXMediaPlayer Attribute Values
IX_STATIC_CONST_STRING kIXDefault = @"default";
IX_STATIC_CONST_STRING kIXEmbedded = @"embedded";
IX_STATIC_CONST_STRING kIXFullscreen = @"fullscreen";
IX_STATIC_CONST_STRING kIXNone = @"none";

// IXMediaPlayer Events
IX_STATIC_CONST_STRING kIXPlaybackStopped = @"playbackStopped";
IX_STATIC_CONST_STRING kIXPlaybackTimedOut = @"playbackTimedOut";
IX_STATIC_CONST_STRING kIXTouchUp = @"touchUp";

// IXMediaPlayer Functions
IX_STATIC_CONST_STRING kIXPause = @"pause";
IX_STATIC_CONST_STRING kIXPlay = @"play";
IX_STATIC_CONST_STRING kIXStop = @"stop";
IX_STATIC_CONST_STRING kIXGoTo = @"goTo";

// IXMediaPlayer Function parameters
IX_STATIC_CONST_STRING kIXGoToSeconds = @"seconds";

@interface  IXMediaPlayer() <ALMoviePlayerControllerDelegate>

@property (nonatomic,strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSURL* movieURL;
@property (nonatomic,assign) CGRect lastFrameForMovieControl;
@property (nonatomic,assign) MPMoviePlaybackState lastKnownState;
@property (nonatomic,assign) BOOL didFireStopped;

@end

@implementation IXMediaPlayer

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];

    [_moviePlayer setDelegate:nil];
    [_moviePlayer stop];
}

-(void)buildView
{
    [super buildView];
    
    _moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectZero];
    [_moviePlayer setShouldAutoplay:NO];
    [_moviePlayer setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStopped) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
    
    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:_moviePlayer style:ALMoviePlayerControlsStyleNone];
    [_moviePlayer setControls:movieControls];
    
    [[self contentView] addSubview:_moviePlayer.view];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return size;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [self setLastFrameForMovieControl:rect];
    if( ![[self moviePlayer] isFullscreen] )
    {
        [[self moviePlayer] setFrame:rect];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    ALMoviePlayerControls* movieControls = [[self moviePlayer] controls];
    NSString* controlsStyle = [[self propertyContainer] getStringPropertyValue:kIXPlayerControls defaultValue:kIX_DEFAULT];
    if( [controlsStyle isEqualToString:kIXEmbedded] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleEmbedded];
    }
    else if( [controlsStyle isEqualToString:kIXFullscreen] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleFullscreen];
    }
    else if( [controlsStyle isEqualToString:kIXNone] )
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleNone];
    }
    else
    {
        [movieControls setStyle:ALMoviePlayerControlsStyleDefault];
    }
    
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[[self propertyContainer] getColorPropertyValue:kIXBarColor defaultValue:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]]];
    [movieControls setBarHeight:[[self propertyContainer] getFloatPropertyValue:kIXBarSize defaultValue:30.0f]];
    [movieControls setTimeRemainingDecrements:YES];
    //[movieControls setFadeDelay:2.0];
    //[movieControls setBarHeight:100.f];
    //[movieControls setSeekRate:2.f];
    
    //delay initial load so statusBarOrientation returns correct value
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            //            self.navigationItem.leftBarButtonItem.enabled = YES;
            //            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    });
    
    //THEN set contentURL
    [self setMovieURL:[[self propertyContainer] getURLPathPropertyValue:kIXVideoUrl basePath:nil defaultValue:nil]];
    
    if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
    {
        [[self moviePlayer] setContentURL:[self movieURL]];
    }
    
    BOOL autoPlay = [[self propertyContainer] getBoolPropertyValue:kIXAutoPlayEnabled defaultValue:YES];
    if( autoPlay )
    {
        if( [[self moviePlayer] playbackState] != MPMoviePlaybackStatePlaying )
        {
            [[self moviePlayer] play];
        }
    }
}

-(void)moviePlayerWillMoveFromWindow
{
    if( [[[self moviePlayer] view] superview] != [self contentView] )
    {
        [[self contentView] addSubview:[[self moviePlayer] view]];
        [[self moviePlayer] setFrame:[self lastFrameForMovieControl]];
    }
}

-(void)movieTimedOut
{
    [[self actionContainer] executeActionsForEventNamed:kIXPlaybackTimedOut];
}

-(void)moviePlaybackStopped
{
    if( ![self didFireStopped] )
    {
        [self setDidFireStopped:YES];
        [[self actionContainer] executeActionsForEventNamed:kIXPlaybackStopped];
    }
}

-(void)moviePlaybackStateChanged
{
    MPMoviePlaybackState currentPlaybackState = [[self moviePlayer] playbackState];
    if( [self lastKnownState] != currentPlaybackState )
    {
        [self setLastKnownState:currentPlaybackState];
        switch (currentPlaybackState) {
            case MPMoviePlaybackStatePlaying:
                [self setDidFireStopped:NO];
                break;
            default:
                break;
        }
    }
}

-(void)applyFunction:(NSString*)functionName withParameters:(IXPropertyContainer*)parameterContainer
{
    if( [functionName compare:kIXPlay] == NSOrderedSame )
    {
        if( ![[[[self moviePlayer] contentURL] absoluteString] isEqualToString:[[self movieURL] absoluteString]] )
        {
            [[self moviePlayer] setContentURL:[self movieURL]];
        }        
        [[self moviePlayer] play];
    }
    else if( [functionName compare:kIXPause] == NSOrderedSame )
    {
        [[self moviePlayer] pause];
    }
    else if( [functionName compare:kIXStop] == NSOrderedSame )
    {
        [[self moviePlayer] stop];
    }
    else if( [functionName compare:kIXGoTo] == NSOrderedSame )
    {
        float seconds = [parameterContainer getFloatPropertyValue:kIXGoToSeconds defaultValue:[[self moviePlayer] currentPlaybackTime]];
        if( [[self moviePlayer] playbackState] != MPMoviePlaybackStatePlaying )
        {
            [[self moviePlayer] setInitialPlaybackTime:seconds];
            [[self moviePlayer] setCurrentPlaybackTime:seconds];
        }
        else
        {
            [[self moviePlayer] setCurrentPlaybackTime:seconds];
        }
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

@end
