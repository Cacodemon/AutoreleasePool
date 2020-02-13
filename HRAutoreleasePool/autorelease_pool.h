//
//  autorelease_pool.h
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/13/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#ifndef autorelease_pool_h
#define autorelease_pool_h

#import <Foundation/Foundation.h>

#define AUTORELEASE_POOL_SIZE 100

typedef struct autorelease_pool {
    int count;
    id objects[AUTORELEASE_POOL_SIZE];
    struct autorelease_pool *next;
} autorelease_pool;

autorelease_pool *autorelease_pool_create(void);
void autorelease_pool_delete(autorelease_pool *pool);
void autorelease_pool_add_object(autorelease_pool *pool, id object);
void autorelease_pool_release_objects(autorelease_pool *pool);

#endif /* autorelease_pool_h */
