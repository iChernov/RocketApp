//
//  iCXINGMemberTableViewCell.m
//  testXINGClient
//
//  Created by Ivan Chernov on 28/07/14.
//  Copyright (c) 2014 iC. All rights reserved.
//

#import "ICRProductTableViewCell.h"

NSString *const kProductCellIdentifier = @"RProductTableCellIdentifier";

@interface ICRProductTableViewCell ()

@end

@implementation ICRProductTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _productNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 250, 25)];
        _productNameLabel.font = [UIFont systemFontOfSize:19.0];
        [self.contentView addSubview:_productNameLabel];
        
        _productPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 40, 75, 25)];
        _productPriceLabel.font = [UIFont systemFontOfSize:15.0];
        _productPriceLabel.textColor = [UIColor greenColor];
        [self.contentView addSubview:_productPriceLabel];
        
        _brandNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 250, 20)];
        _brandNameLabel.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:_brandNameLabel];
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 60)];
        [self.contentView addSubview:_productImageView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
