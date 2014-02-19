//
//  IXJSONParser.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/10/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IXCustom;
@class IXProperty;
@class IXBaseAction;
@class IXBaseControl;
@class IXViewController;
@class IXActionContainer;
@class IXPropertyContainer;

@interface IXJSONParser : NSObject

+(void)clearCache;

+(UIInterfaceOrientationMask)orientationMaskForValue:(id)orientationValue;
+(IXProperty*)conditionalPropertyForConditionalValue:(id)conditionalValue;

+(IXPropertyContainer*)propertyContainerWithPropertyDictionary:(NSDictionary*)propertDictionary;
+(NSArray*)propertiesWithPropertyName:(NSString*)propertyName propertyValueArray:(NSArray*)propertyValueArray;
+(IXProperty*)propertyWithPropertyName:(NSString*)propertyName propertyValueDict:(NSDictionary*)propertyValueDict;

+(IXActionContainer*)actionContainerWithJSONActionsArray:(NSArray*)actionsArray;
+(NSArray*)actionsWithEventNames:(NSArray*)eventNames actionValueDictionary:(NSDictionary*)actionValueDict;
+(IXBaseAction*)actionWithEventName:(NSString*)eventName valueDictionary:(NSDictionary*)actionValueDict;

+(NSArray*)controlsWithJSONControlArray:(NSArray*)controlsValueArray;
+(IXBaseControl*)controlWithValueDictionary:(NSDictionary*)controlValueDict;
+(void)populateCustomControl:(IXCustom*)customControl withJSONAtPath:(NSString*)pathToJSON async:(BOOL)async;

+(IXViewController*)viewControllerWithViewDictionary:(NSDictionary*)viewDictionary pathToJSON:(NSString*)pathToJSON;

@end
