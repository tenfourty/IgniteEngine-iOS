//
//  IXImageControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Jeremy Anticouni on 11/15/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

/*  -----------------------------  */
//  [Documentation]
//
//  Author:     Jeremy Anticouni
//  Date:       1/28/2015
//
//  Copyright (c) 2015 Apigee. All rights reserved.
//
/*  -----------------------------  */
/**
 
 ###    Native iOS UI control that displays a menu from the bottom of the screen.
  
 <a href="#attributes">Attributes</a>,
 <a href="#readonly">Read-Only</a>,
 <a href="#inherits">Inherits</a>,
 <a href="#events">Events</a>,
 <a href="#functions">Functions</a>,
 <a href="#example">Example JSON</a>
 
 ##  <a name="attributes">Attributes</a>
 
 | Name                           | Type        | Description                                | Default |
 |--------------------------------|-------------|--------------------------------------------|---------|
 | images.default                 | *(string)*  | /path/to/image.png                         |         |
 | images.default.tintColor       | *(color)*   | Color to overlay transparent png           |         |
 | images.default.blur.radius     | *(float)*   | Blur image                                 |         |
 | images.default.blur.tintColor  | *(color)*   | Blur tint                                  |         |
 | images.default.blur.saturation | *(float)*   | Blur saturation                            |         |
 | images.default.force_refresh   | *(bool)*    | Force image to reload when enters view     |         |
 | images.height.max              | *(int)*     | Maximum height of image                    |         |
 | images.width.max               | *(int)*     | Maximum width of image                     |         |
 | gif_duration                   | *(float)*   | Duration of GIF (pronounced JIF) animation |         |
 | flip_horizontal                | *(bool)*    | Flip image horizontally                    | false   |
 | flip_vertical                  | *(bool)*    | Flip image vertically                      | false   |
 | rotate                         | *(int)*     | Rotate image in degrees                    |         |
 | image.binary                   | *(string)*  | Binary data of image file                  |         |
 | images.default.resize          | *(special)* | Dynamically resize image using imageMagick |         |
 

 ##  <a name="readonly">Read Only Attributes</a>
 
 | Name         | Type     | Description            |
 |--------------|----------|------------------------|
 | is_animating | *(bool)* | Is it animating?       |
 | image.height | *(int)*  | Actual height of image |
 | image.width  | *(int)*  | Actual width of image  |
 
 ##  <a name="inherits">Inherits</a>
 
>  IXBaseControl
 
 ##  <a name="events">Events</a>

 | Name                  | Description                             |
 |-----------------------|-----------------------------------------|
 | images_default_loaded | Fires when the image loads successfully |
 | images_default_failed | Fires when the image fails to load      |
 

 ##  <a name="functions">Functions</a>
 
Start GIF animation: *start_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "start_animation"
      }
    }

Restart GIF animation: *restart_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "restart_animation"
      }
    }
 
Stop GIF animation: *stop_animation*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "stop_animation"
      }
    }

 Not really sure: *load_last_photo*

    {
      "_type": "Function",
      "on": "touch_up",
      "attributes": {
        "_target": "imageTest",
        "function_name": "load_last_photo"
      }
    }


 
 ##  <a name="example">Example JSON</a> 
 
    {
      "_id": "imageTest",
      "_type": "Image",
      "attributes": {
        "height": 100,
        "width": 100,
        "horizontal_alignment": "center",
        "vertical_alignment": "middle",
        "images.default": "/images/btn_notifications_25x25.png",
        "images.default.tintColor": "#a9d5c7"
      }
    }
 
 */
//
//  [/Documentation]
/*  -----------------------------  */


/*
 
 CONTROL
 
 - TYPE : "Map"
 
 
 - PROPERTIES
 
 * name="placemark.latitude"            default=37.331789               type="Float"
 * name="placemark.longitude"           default=37.331789               type="Float"
 * name="placemark.title"               default=""                      type="String"
 * name="placemark.subtitle"            default=""                      type="String"

 
 */

#import "IXMap.h"

@import MapKit;

#import "MKMapView+IXAdditions.h"

#import "IXDataRowDataProvider.h"

#import "SVPulsingAnnotationView.h"

// IXMap Attributes
IX_STATIC_CONST_STRING kIXDataProviderID = @"dataprovider_id";
IX_STATIC_CONST_STRING kIXShowsUserLocation = @"shows_user_location";
IX_STATIC_CONST_STRING kIXShowsPointsOfInterest = @"shows_points_of_interest";
IX_STATIC_CONST_STRING kIXShowsBuildings = @"shows_buildings";
IX_STATIC_CONST_STRING kIXMapType = @"map_type";
IX_STATIC_CONST_STRING kIXZoomLevel = @"zoom_level";
IX_STATIC_CONST_STRING kIXCenterLatitude = @"center.latitude";
IX_STATIC_CONST_STRING kIXCenterLongitude = @"center.longitude";

IX_STATIC_CONST_STRING kIXAnnotationImage = @"annotation.image";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetX = @"annotation.image.center.offset.x";
IX_STATIC_CONST_STRING kIXAnnotationImageCenterOffsetY = @"annotation.image.center.offset.y";
IX_STATIC_CONST_STRING kIXAnnotationTitle = @"annotation.title";
IX_STATIC_CONST_STRING kIXAnnotationSubTitle = @"annotation.subtitle";
IX_STATIC_CONST_STRING kIXAnnotationLatitude = @"annotation.latitude";
IX_STATIC_CONST_STRING kIXAnnotationLongitude = @"annotation.longitude";
IX_STATIC_CONST_STRING kIXAnnoationAccessoryLeftImage = @"annotation.accessory.left.image";
IX_STATIC_CONST_STRING kIXAnnoationPinColor = @"annotation.pin.color";
IX_STATIC_CONST_STRING kIXAnnoationPinAnimatesDrop = @"annotation.pin.animates_drop";

// kIXMapType Accepted Values
IX_STATIC_CONST_STRING kIXMapTypeStandard = @"standard";
IX_STATIC_CONST_STRING kIXMapTypeSatellite = @"satellite";
IX_STATIC_CONST_STRING kIXMapTypeHybrid = @"hybrid";

// kIXAnnoationPinColor Accepted Values
IX_STATIC_CONST_STRING kIXAnnoationPinColorRed = @"red";
IX_STATIC_CONST_STRING kIXAnnoationPinColorGreen = @"green";
IX_STATIC_CONST_STRING kIXAnnoationPinColorPurple = @"purple";

// IXMap Functions
IX_STATIC_CONST_STRING kIXReloadAnnotations = @"reload_annotations";
IX_STATIC_CONST_STRING kIXShowAllAnnotations = @"show_all_annotations";

// IXMap Events
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXTouchUp = @"touch_up";

// Reuseable Annotation Ident
IX_STATIC_CONST_STRING kIXMapPinAnnotationIdentifier = @"kIXMapPinAnnotationIdentifier";
IX_STATIC_CONST_STRING kIXMapImageAnnotationIdentifier = @"kIXMapImageAnnotationIdentifier";

@interface IXMapAnnotation : NSObject <MKAnnotation>

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                          subtitle:(NSString*)subTitle
                  dataRowIndexPath:(NSIndexPath*)dataRowIndexPath;

+(instancetype)mapAnnotationWithPropertyContainer:(IXPropertyContainer*)propertyContainer
                                     rowIndexPath:(NSIndexPath*)rowIndexPath;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSIndexPath *dataRowIndexPath;

@end

@implementation IXMapAnnotation

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                          subtitle:(NSString*)subTitle
                  dataRowIndexPath:(NSIndexPath*)dataRowIndexPath
{
    self = [super init];
    if( self )
    {
        _coordinate = coordinate;
        _title = [title copy];
        _subtitle = [subTitle copy];
        _dataRowIndexPath = dataRowIndexPath;
    }
    return self;
}

+(instancetype)mapAnnotationWithPropertyContainer:(IXPropertyContainer*)propertyContainer
                                     rowIndexPath:(NSIndexPath*)rowIndexPath
{
    CGFloat annotationLatitude = [propertyContainer getFloatPropertyValue:kIXAnnotationLatitude defaultValue:0.0f];
    CGFloat annotationLongitude = [propertyContainer getFloatPropertyValue:kIXAnnotationLongitude defaultValue:0.0f];
    
    IXMapAnnotation *annotation = [[[self class] alloc] initWithCoordinate:CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
                                                                     title:[propertyContainer getStringPropertyValue:kIXAnnotationTitle
                                                                                                                  defaultValue:nil]
                                                                  subtitle:[propertyContainer getStringPropertyValue:kIXAnnotationSubTitle
                                                                                                                  defaultValue:nil]
                                                          dataRowIndexPath:rowIndexPath];
    
    return annotation;
}

@end

@interface IXMap () <MKMapViewDelegate>

@property (nonatomic,weak) IXDataRowDataProvider* dataProvider;
@property (nonatomic,assign) BOOL usesDataProviderForAnnotationData;

@property (nonatomic,strong) MKMapView* mapView;
@property (nonatomic,strong) NSMutableArray* annotations;
@property (nonatomic,assign) CGPoint imageCenterOffset;

@end

@implementation IXMap

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    [_mapView setDelegate:nil];
}

-(void)buildView
{
    [super buildView];
    
    _annotations = [[NSMutableArray alloc] init];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    [_mapView setDelegate:self];
    
    [[self contentView] addSubview:_mapView];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [[self mapView] sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self mapView] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];

    float centerOffsetX = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationImageCenterOffsetX defaultValue:0.0f];
    float centerOffsetY = [[self propertyContainer] getFloatPropertyValue:kIXAnnotationImageCenterOffsetY defaultValue:0.0f];
    [self setImageCenterOffset:CGPointMake(centerOffsetX, centerOffsetY)];

    [[self mapView] setShowsUserLocation:[[self propertyContainer] getBoolPropertyValue:kIXShowsUserLocation defaultValue:NO]];
    [[self mapView] setShowsPointsOfInterest:[[self propertyContainer] getBoolPropertyValue:kIXShowsPointsOfInterest defaultValue:YES]];
    [[self mapView] setShowsBuildings:[[self propertyContainer] getBoolPropertyValue:kIXShowsBuildings defaultValue:YES]];

    NSString* mapType = [[self propertyContainer] getStringPropertyValue:kIXMapType defaultValue:kIXMapTypeStandard];
    if( [mapType isEqualToString:kIXMapTypeSatellite] ) {
        [[self mapView] setMapType:MKMapTypeSatellite];
    } else if( [mapType isEqualToString:kIXMapTypeHybrid] ) {
        [[self mapView] setMapType:MKMapTypeHybrid];
    } else {
        [[self mapView] setMapType:MKMapTypeStandard];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IXBaseDataProviderDidUpdateNotification
                                                  object:[self dataProvider]];
    
    NSString* dataProviderID = [[self propertyContainer] getStringPropertyValue:kIXDataProviderID defaultValue:nil];
    [self setUsesDataProviderForAnnotationData:([dataProviderID length] > 0)];
    
    if( [self usesDataProviderForAnnotationData] )
    {
        [self setDataProvider:[[self sandbox] getDataRowDataProviderWithID:dataProviderID]];
        
        if( [self dataProvider] )
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(dataProviderNotification:)
                                                         name:IXBaseDataProviderDidUpdateNotification
                                                       object:[self dataProvider]];
        }
    }
    
    [self reloadMapAnnotations];
}

-(void)dataProviderNotification:(NSNotification*)notification
{
    [self reloadMapAnnotations];
}

-(void)reloadMapAnnotations
{
    [[self mapView] removeAnnotations:[self annotations]];
    [[self annotations] removeAllObjects];
    
    if( [self usesDataProviderForAnnotationData] && [[self dataProvider] rowCount:nil] > 0 )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
        
        [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        for( int i = 0; i < [[self dataProvider] rowCount:nil]; i++ )
        {
            NSIndexPath* rowIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [[self sandbox] setIndexPathForRowData:rowIndexPath];
            
            IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self propertyContainer]
                                                                                 rowIndexPath:rowIndexPath];
            if( annotation )
            {
                [[self annotations] addObject:annotation];
            }
        }
        
        // Reset the Map controls sandbox values.
        [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
        [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
    }
    else if( [self dataProvider] == nil )
    {
        IXMapAnnotation* annotation = [IXMapAnnotation mapAnnotationWithPropertyContainer:[self propertyContainer]
                                                                             rowIndexPath:nil];
        if( annotation )
        {
            [[self annotations] addObject:annotation];
        }
    }

    if( [[self annotations] count] > 0 )
    {
        [self zoomToFitAnnotationsAndZoomLevel];
    }
}

-(void)zoomToFitAnnotationsAndZoomLevel
{
    [[self mapView] showAnnotations:[self annotations] animated:NO];

    int zoomLevel = [[self propertyContainer] getIntPropertyValue:kIXZoomLevel
                                                     defaultValue:(int)[[self mapView] ix_zoomLevel]];

    CLLocationCoordinate2D centerCoord = [[self mapView] centerCoordinate];

    CGFloat centerCoordinateLat = [[self propertyContainer] getFloatPropertyValue:kIXCenterLatitude
                                                                     defaultValue:centerCoord.latitude];

    CGFloat centerCoordinateLong = [[self propertyContainer] getFloatPropertyValue:kIXCenterLongitude
                                                                      defaultValue:centerCoord.longitude];

    [[self mapView] ix_setCenterCoordinate:CLLocationCoordinate2DMake(centerCoordinateLat, centerCoordinateLong)
                                 zoomLevel:zoomLevel
                                  animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* annotationView = nil;
    if( [annotation isKindOfClass:[IXMapAnnotation class]] )
    {
        // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we set up the annotations views.
        NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
        IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];

        IXMapAnnotation* mapAnnotation = (IXMapAnnotation*)annotation;
        NSIndexPath* indexPathForAnnotation = [mapAnnotation dataRowIndexPath];
        
        if( [self usesDataProviderForAnnotationData] )
        {
            [[self sandbox] setIndexPathForRowData:indexPathForAnnotation];
            [[self sandbox] setDataProviderForRowData:[self dataProvider]];
        }
        
        NSString* imageLocation = [[self propertyContainer] getStringPropertyValue:kIXAnnotationImage defaultValue:nil];
        if( [imageLocation length] > 0 )
        {
            annotationView = [[self mapView] dequeueReusableAnnotationViewWithIdentifier:kIXMapImageAnnotationIdentifier];
            
            if( annotationView == nil )
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIXMapImageAnnotationIdentifier];
                [annotationView setCanShowCallout:YES];
            }
            
            if( annotationView )
            {
                [[self propertyContainer] getImageProperty:kIXAnnotationImage
                                              successBlock:^(UIImage *image) {
                                                  [annotationView setImage:image];
                                              } failBlock:^(NSError *error) {
                                                  [annotationView setImage:nil];
                                              }];
            }
        }
        else
        {
            annotationView = (MKPinAnnotationView*)[[self mapView] dequeueReusableAnnotationViewWithIdentifier:kIXMapPinAnnotationIdentifier];
            
            if( annotationView == nil )
            {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kIXMapPinAnnotationIdentifier];
                [annotationView setCanShowCallout:YES];
                
                BOOL animatesDrop = [[self propertyContainer] getBoolPropertyValue:kIXAnnoationPinAnimatesDrop defaultValue:YES];
                [(MKPinAnnotationView*)annotationView setAnimatesDrop:animatesDrop];
                
                NSString* pinColor = [[self propertyContainer] getStringPropertyValue:kIXAnnoationPinColor defaultValue:kIXAnnoationPinColorRed];
                if( [pinColor isEqualToString:kIXAnnoationPinColorGreen] ) {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorGreen];
                } else if( [pinColor isEqualToString:kIXAnnoationPinColorPurple] ) {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorPurple];
                } else {
                    [(MKPinAnnotationView*)annotationView setPinColor:MKPinAnnotationColorRed];
                }
            }
        }
        
        if( [[self actionContainer] hasActionsForEvent:kIXTouch] || [[self actionContainer] hasActionsForEvent:kIXTouchUp] )
        {
            [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        }
        else
        {
            [annotationView setRightCalloutAccessoryView:nil];
        }

        NSString* leftAccessoryImage = [[self propertyContainer] getStringPropertyValue:kIXAnnoationAccessoryLeftImage defaultValue:nil];
        if( [leftAccessoryImage length] > 0 )
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
            [annotationView setLeftCalloutAccessoryView:imageView];
            [[self propertyContainer] getImageProperty:kIXAnnoationAccessoryLeftImage
                                          successBlock:^(UIImage *image) {
                                              [imageView setImage:image];
                                          } failBlock:^(NSError *error) {
                                              [imageView setImage:nil];
                                          }];
        }
        else
        {
            [annotationView setLeftCalloutAccessoryView:nil];
        }

        if( [self usesDataProviderForAnnotationData] )
        {
            // Reset the Map controls sandbox values.
            [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
            [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
        }
    }

    if( !CGPointEqualToPoint([self imageCenterOffset], CGPointZero) ) {
        [annotationView setCenterOffset:[self imageCenterOffset]];
    }

    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if( [control isEqual:[view rightCalloutAccessoryView]] && [[view annotation] isKindOfClass:[IXMapAnnotation class]] )
    {
        if( [self usesDataProviderForAnnotationData] )
        {
            // Save off the Map controls original index path and dataprovider for the row data so we can reset it after we fire the actions on the annotations.
            NSIndexPath* currentSandboxIndexPath = [[self sandbox] indexPathForRowData];
            IXDataRowDataProvider* currentSandboxDataProvider = [[self sandbox] dataProviderForRowData];
            
            IXMapAnnotation* mapAnnotation = (IXMapAnnotation*)[view annotation];
            NSIndexPath* indexPathForAnnotation = [mapAnnotation dataRowIndexPath];
            
            [[self sandbox] setIndexPathForRowData:indexPathForAnnotation];
            [[self sandbox] setDataProviderForRowData:[self dataProvider]];
            
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
            
            // Reset the Map controls sandbox values.
            [[self sandbox] setIndexPathForRowData:currentSandboxIndexPath];
            [[self sandbox] setDataProviderForRowData:currentSandboxDataProvider];
        }
        else
        {
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
            [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
        }
    }
}

-(void)applyFunction:(NSString *)functionName withParameters:(IXPropertyContainer *)parameterContainer
{
    if( [functionName isEqualToString:kIXReloadAnnotations] )
    {
        [self reloadMapAnnotations];
    }
    else if( [functionName isEqualToString:kIXShowAllAnnotations] )
    {
        BOOL animated = (parameterContainer == nil) ? YES : [parameterContainer getBoolPropertyValue:kIX_ANIMATED defaultValue:YES];
        [[self mapView] showAnnotations:[self annotations]
                               animated:animated];
    }
    else
    {
        [super applyFunction:functionName withParameters:parameterContainer];
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    // Map doesnt need to fire any touch actions.
}
-(void)processBeginTouch:(BOOL)fireTouchActions
{
    // Map doesnt need to fire any touch actions.
}

@end
