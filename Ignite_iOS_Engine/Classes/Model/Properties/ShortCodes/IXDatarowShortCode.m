//
//  IXDatarowShortCode.m
//  Ignite_iOS_Engine
//
//  Created by Robert Walsh on 12/17/13.
//  Copyright (c) 2013 Ignite. All rights reserved.
//

#import "IXDatarowShortCode.h"
#import "IXPropertyContainer.h"
#import "IXProperty.h"
#import "IXSandbox.h"
#import "IXCoreDataDataProvider.h"
#import <RestKit/CoreData.h>

@implementation IXDatarowShortCode

-(NSString*)evaluate:(IXSandbox*)sandbox
{
    NSString* returnValue = nil;
    
    @try {
        IXCoreDataDataProvider* dp = [sandbox dataProviderForRowData];
        NSIndexPath* indexPath = [sandbox indexPathForRowData];
        NSManagedObject* object = [[dp fetchedResultsController] objectAtIndexPath:indexPath];
        
        NSString* keyPath = [self methodName];
        if( !keyPath )
        {
            IXProperty* parameterProperty = (IXProperty*)[[self parameters] firstObject];
            keyPath = [parameterProperty getPropertyValue:sandbox];
        }
        returnValue = [object valueForKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        
    }
    return returnValue;
}

@end
