//
//  autorelease_pool_stack.h
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/13/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#ifndef autorelease_pool_stack_h
#define autorelease_pool_stack_h

#import <Foundation/Foundation.h>
#import "autorelease_pool.h"

#define AUTORELEASE_POOL_STACK_SIZE 10

typedef struct autorelease_pool_stack {
    int current;
    autorelease_pool *pools[AUTORELEASE_POOL_STACK_SIZE];
} autorelease_pool_stack;

autorelease_pool_stack *autorelease_pool_stack_create(void);
void autorelease_pool_stack_delete(autorelease_pool_stack *stack);
void autorelease_pool_stack_push_autorelease_pool(autorelease_pool_stack *stack, autorelease_pool* pool);
autorelease_pool* autorelease_pool_stack_pop_autorelease_pool(autorelease_pool_stack *stack);
autorelease_pool* autorelease_pool_stack_get_topmost_autorelease_pool(autorelease_pool_stack *stack);

#endif /* autorelease_pool_stack_h */
