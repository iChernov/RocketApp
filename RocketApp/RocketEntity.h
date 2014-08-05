//
//  RocketEntity.h
//  RocketApp
//
//  Created by Ivan Chernov on 05/08/14.
//  Copyright (c) 2014 iChernov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RocketEntity : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSNumber * id;

@end
