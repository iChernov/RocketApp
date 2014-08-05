//
//  ICRProductsTableViewController.m
//  RocketApp
//
//  Created by Ivan Chernov on 05/08/14.
//  Copyright (c) 2014 iChernov. All rights reserved.
//

#import "ICRProductsTableViewController.h"
#import "AFNetworking.h"
#import "RocketEntity.h"
#import "ICRProductTableViewCell.h"

static NSString * const BaseURLString = @"https://www.zalora.com.my/mobile-api/women/clothing";
static int productsPerPage = 24;
static const int kCellHeightValue = 70.0;

@interface ICRProductsTableViewController ()
@property (strong, nonatomic) UISegmentedControl *sortControl;
@property NSMutableArray *productsArray;
- (IBAction)setSortingOption:(id)sender;
@end

@implementation ICRProductsTableViewController

- (IBAction)setSortingOption:(id)sender {
    [self refreshData];
}

- (void) refreshData {
    [_productsArray removeAllObjects];
    NSString *propertyToSortName;
    BOOL isAscending;
    switch (_sortControl.selectedSegmentIndex) {
        case 1:
            propertyToSortName = @"name";
            isAscending = YES;
            break;
        case 2:
            propertyToSortName = @"price";
            isAscending = YES;
            break;
        case 3:
            propertyToSortName = @"brand";
            isAscending = YES;
            break;
        case 0:
            propertyToSortName = @"popularity";
            isAscending = NO;
            break;
            
        default:
            propertyToSortName = @"popularity";
            isAscending = NO;
            break;
    }
    NSArray *allRecords;
    if ([propertyToSortName isEqualToString: @"popularity"]) {
        allRecords = [RocketEntity MR_findAll];
    } else {
        allRecords = [RocketEntity MR_findAllSortedBy:propertyToSortName ascending:isAscending];
    }
    for (id product in allRecords) {
        if (![_productsArray containsObject:product]) {
            [_productsArray addObject:product];
        }
    }
    [self.tableView reloadData];
}

- (void)loadProductsStartingFromRow:(int)row {
    __weak __typeof(&*self)weakSelf = self;
    int pageToLoad = (row + 1)/productsPerPage;
    
    NSString *string = [NSString stringWithFormat:@"%@?maxitems=%d&page=%d", BaseURLString, productsPerPage, pageToLoad];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *productsToAdd = responseObject[@"metadata"][@"results"];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSMutableArray *tempIDsArray = [NSMutableArray new];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            for(NSDictionary *productDictionary in productsToAdd) {
                RocketEntity *product = [RocketEntity MR_findFirstByAttribute:@"id" withValue:[f numberFromString:productDictionary[@"id"]]];
                NSString *receivedImagePath = productDictionary[@"images"][1][@"path"];
                if ((!product)&&(![tempIDsArray containsObject:productDictionary[@"id"]])) {
                    [tempIDsArray addObject:productDictionary[@"id"]];
                    product = [RocketEntity MR_createInContext:localContext];
                    product.image_url = receivedImagePath;
                } else {
                    if (product.image_url != receivedImagePath) {
                        product.image = nil;
                        product.image_url = receivedImagePath;
                    }
                }
                product.id = [f numberFromString:productDictionary[@"id"]];
                product.name = productDictionary[@"data"][@"name"];
                product.brand = productDictionary[@"data"][@"brand"];
                product.price = [f numberFromString:productDictionary[@"data"][@"price"]];
            }
        } completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshData];
            });
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Products"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sortControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Popularity", @"Name", @"Price", @"Brand", nil]];
    [_sortControl setSelectedSegmentIndex:0];
    self.navigationItem.titleView = _sortControl;
    
    
    [self.tableView registerClass:[ICRProductTableViewCell class] forCellReuseIdentifier:kProductCellIdentifier];
    _productsArray = [[RocketEntity MR_findAll] mutableCopy];
    if (_productsArray.count == 0) {
        [self loadProductsStartingFromRow:0];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _productsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICRProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProductCellIdentifier forIndexPath:indexPath];
    RocketEntity *currentProduct = _productsArray[indexPath.row];
    cell.imageView.image = nil;
    cell.productNameLabel.text = currentProduct.name;
    cell.brandNameLabel.text = currentProduct.brand;
    cell.productPriceLabel.text = [NSString stringWithFormat:@"%.2f", [currentProduct.price doubleValue]];

    

    if (currentProduct.image) {
        cell.productImageView.image = [[UIImage alloc] initWithData:currentProduct.image];
    } else if (currentProduct.image_url){
        __weak __typeof(&*self)weakSelf = self;
        __block ICRProductTableViewCell *bgCell = cell;
        __block NSIndexPath *bgCellIndexPath = indexPath;
        __block RocketEntity *blockProduct = currentProduct;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:blockProduct.image_url]];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                blockProduct.image = imageData;
            } completion:^(BOOL success, NSError *error) {
                NSLog(@"saved successfully");
                dispatch_async(dispatch_get_main_queue(), ^{
                    bgCell.imageView.image = [[UIImage alloc] initWithData:imageData];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[bgCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
            }];

            
            
        });
    } else {
        cell.productImageView.image = [UIImage new];;
    }
    if (indexPath.row >= _productsArray.count - 1)
        [self loadProductsStartingFromRow:(int)indexPath.row];
    return cell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeightValue;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
