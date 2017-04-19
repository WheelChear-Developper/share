//
//  XmlToDictionaly.h
//  XmlToDictionaly
//
//  Created by Benoit C on 10/31/13.
//  Copyright (c) 2013 Benoit Caccinolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlToDictionaly : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
//+ (NSString *)getDictionalySerchKey:(NSDictionary*)dic keyName:(NSString*)keyName;

@end
