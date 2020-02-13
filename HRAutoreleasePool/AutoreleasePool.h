//
//  AutoreleasePool.h
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/7/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoreleasePool : NSObject

+ (void)addObject:(id)anObject;
- (void)addObject:(id)anObject;
- (void)drain;

@end

@interface NSObject (HRAutoreleasePool)

- (id)hrAutorelease;

@end

NS_ASSUME_NONNULL_END
