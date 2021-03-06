//
//  XYObjectCache.m
//  JoinShow
//
//  Created by Heaven on 14-1-21.
//  Copyright (c) 2014年 Heaven. All rights reserved.
//

#import "XYObjectCache.h"
#import "XYCache.h"
#import "XYSandbox.h"
#import "XYExtension.h"

@interface XYObjectCache()
{

}

@end

@implementation XYObjectCache

DEF_SINGLETON(XYObjectCache)

-(id) init
{
	self = [super init];
	if ( self )
	{
		_memoryCache = [[XYMemoryCache alloc] init];
		_memoryCache.clearWhenMemoryLow = YES;
        
		_fileCache = [[XYFileCache alloc] init];
		_fileCache.cachePath = [NSString stringWithFormat:@"%@/ObjectCache/", [XYSandbox libCachePath]];
		_fileCache.cacheUser = @"";
	}
	return self;
}

- (void)dealloc
{
}

- (void)registerObjectClass:(Class)aClass{
    _objectClass = aClass;
    _fileCache.cachePath = [NSString stringWithFormat:@"%@/%@/", [XYSandbox libCachePath], NSStringFromClass(_objectClass)];
}

- (BOOL)hasCachedForKey:(NSString *)string
{
	NSString * cacheKey = [string MD5];
	
	BOOL flag = [self.memoryCache hasObjectForKey:cacheKey];
	if ( NO == flag )
	{
		flag = [self.fileCache hasObjectForKey:cacheKey];
	}
	
	return flag;
}

- (BOOL)hasFileCachedForKey:(NSString *)key
{
	NSString * cacheKey = [key MD5];
	
	return [self.fileCache hasObjectForKey:cacheKey];
}

- (BOOL)hasMemoryCachedForKey:(NSString *)key
{
	NSString * cacheKey = [key MD5];
	
	return [self.memoryCache hasObjectForKey:cacheKey];
}

- (id)fileObjectForKey:(NSString *)key
{
  //  PERF_ENTER
	
	NSString *	cacheKey = [key MD5];
	id anObject = nil;
    
	NSString * fullPath = [self.fileCache fileNameForKey:cacheKey];

	if ( fullPath )
	{
        if ([self.objectClass isSubclassOfClass:[UIImage class]])
        {
            anObject = [[UIImage alloc] initWithContentsOfFile:fullPath];
        }
        else if ([self.objectClass isSubclassOfClass:[NSData class]])
        {
            anObject = [[NSData alloc] initWithContentsOfFile:fullPath];
        }
        else if ([self.objectClass isSubclassOfClass:[NSString class]])
        {
            anObject = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        }
        else if (1)
        {
            anObject = [[NSData alloc] initWithContentsOfFile:fullPath];
        }
        
		id cachedObject = (id)[self.memoryCache objectForKey:cacheKey];
		if ( nil == cachedObject && anObject != cachedObject )
		{
			[self.memoryCache setObject:anObject forKey:cacheKey];
		}
	}

    
  //  PERF_LEAVE
	
	return anObject;
}

- (id)memoryObjectForKey:(NSString *)key
{
  //  PERF_ENTER
	
	NSString *	cacheKey = [key MD5];
	id anObject = nil;
	
	NSObject * object = [self.memoryCache objectForKey:cacheKey];
	if ( object && [object isKindOfClass:self.objectClass] )
	{
		anObject = (id)object;
	}
    else if (object && 1)
    {
        anObject = (id)object;
    }
	
  //  PERF_LEAVE
    
	return anObject;
}

- (id)objectForKey:(NSString *)string
{
	id anObject = [self memoryObjectForKey:string];
	if ( nil == anObject )
	{
		anObject = [self fileObjectForKey:string];
	}
	return anObject;
}

- (void)saveObject:(id)anObject forKey:(NSString *)key{
    [self saveObject:anObject forKey:key async:YES];
}

- (void)saveObject:(id)anObject forKey:(NSString *)key async:(BOOL)async{
    if (async) {
        // 异步
        FOREGROUND_BEGIN
        [self saveToMemory:anObject forKey:key];
        BACKGROUND_BEGIN
        [self saveToData:[anObject dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] forKey:key];
        BACKGROUND_COMMIT
        FOREGROUND_COMMIT
    } else {
        // 同步
        [self saveToData:[anObject dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] forKey:key];
        [self saveToMemory:anObject forKey:key];
    }
}

- (void)saveToMemory:(id)anObject forKey:(NSString *)string
{
  //  PERF_ENTER
	
	NSString * cacheKey = [string MD5];
	id cachedObject = (id)[self.memoryCache objectForKey:cacheKey];
	if ( nil == cachedObject && anObject != cachedObject )
	{
		[self.memoryCache setObject:anObject forKey:cacheKey];
	}
	
  //  PERF_LEAVE
}

- (void)saveToData:(NSData *)data forKey:(NSString *)string
{
  //  PERF_ENTER
	
	NSString * cacheKey = [string MD5];
	[self.fileCache setObject:data forKey:cacheKey];
	
  //  PERF_LEAVE
}

- (void)deleteObjectForKey:(NSString *)string
{
  //  PERF_ENTER
	
	NSString * cacheKey = [string MD5];
	
	[self.memoryCache removeObjectForKey:cacheKey];
	[self.fileCache removeObjectForKey:cacheKey];
	
 //   PERF_LEAVE
}

- (void)deleteAllObjects
{
	[self.memoryCache removeAllObjects];
	[self.fileCache removeAllObjects];
}


@end
