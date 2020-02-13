//
//  autorelease_pool.c
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/13/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#import "autorelease_pool.h"

autorelease_pool *autorelease_pool_create() {
    autorelease_pool *pool = (autorelease_pool *)malloc(sizeof(autorelease_pool));
    pool->count = 0;
    memset(pool->objects, (int)nil, AUTORELEASE_POOL_SIZE);
    pool->next = NULL;
    return pool;
}

void autorelease_pool_delete(autorelease_pool *pool) {
    if (pool == NULL) {
        return;
    }
    autorelease_pool *next = pool->next;
    free(pool);
    autorelease_pool_delete(next);
}

void autorelease_pool_add_object(autorelease_pool *pool, id object) {
    if (pool->count < AUTORELEASE_POOL_SIZE) {
        pool->objects[pool->count] = object;
        pool->count += 1;
        return;
    }
    if (pool->next == NULL) {
        pool->next = autorelease_pool_create();
    }
    autorelease_pool_add_object(pool->next, object);
}

void autorelease_pool_release_objects(autorelease_pool *pool) {
    if (pool == NULL) {
        return;
    }
    if (pool->count == 0) {
        return;
    }
    for (int i = 0; i < pool->count; ++i) {
        [(NSObject *)pool->objects[i] release];
    }
}
