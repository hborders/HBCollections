/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "HBReduceEnumerator.h"

@interface HBReduceEnumerator() {
    @private
    NSEnumerator *_reduceeEnumerator;
    HBReduceBlock _reduceBlock;
    id _value;
}

@end

@implementation HBReduceEnumerator

- (id) initWithReduceeEnumerator:(NSEnumerator *) reduceeEnumerator
                  andReduceBlock:(HBReduceBlock) reduceBlock 
                 andInitialValue:(id) initialValue {
    self = [super init];
    if (self) {
        _reduceeEnumerator = [reduceeEnumerator retain];
        _reduceBlock = [reduceBlock copy];
        _value = [initialValue retain];
    }
    
    return self;
}

- (void) dealloc {
    [_reduceeEnumerator release];
    [_reduceBlock release];
    [_value release];
    
    [super dealloc];
}

@end
