//
//  iCXINGMemberTableViewCell.h
//  testXINGClient
//
//  Created by Ivan Chernov on 28/07/14.
//  Copyright (c) 2014 iC. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const kProductCellIdentifier;

@interface ICRProductTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *productNameLabel;
@property (strong, nonatomic) UILabel *productPriceLabel;
@property (strong, nonatomic) UILabel *brandNameLabel;
@property (strong, nonatomic) UIImageView *productImageView;
@end
