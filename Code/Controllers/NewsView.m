//
//  NewsView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsView.h"
#import "Authorization.h"
#import "SBJson.h"
#import "News.h"
#import "New.h"
#import "NewDetailView.h"
#import "UIImage+Thumbnail.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"
#import "Config.h"

@interface NewsView() <NewsDelegate> 
{
    int _row;
}
@property (nonatomic, strong) NSMutableArray *news;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) int page;
@end

@implementation NewsView
@synthesize news = _news;
@synthesize mainMenu = _mainMenu;
@synthesize page = _page;

- (NSMutableArray *)news {
    if (!_news) {
        _news = [NSMutableArray array];
    }
    return _news;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Лента новостей";
    self.page = 0;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewsCount:) name:kNOTIFICATION_DID_GET_NEWS_COUNT object:nil];    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNews:) name:kNOTIFICATION_DID_GET_NEWS object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
        
    self.tableView.rowHeight = 104;
    
    //[MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    //[News get:self.page withDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.news getCount];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//            [self.hud hide:YES];
//        });
//    });
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (!self.news.count) {
//        [News get:self.page++ withDelegate:self];
//    }
//    _row = 0;
//    
//    for (int i = 0; i < 5; i++) {
//        _newsCount[i] = 0;
//    }
//    
//    for (New *new in self.news) {
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *ndc = [calendar components:NSDayCalendarUnit fromDate:new.date];
//        NSDateComponents *tdc = [calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
//        if (ndc.day == tdc.day) _newsCount[0]++;
//        else if (ndc.day == tdc.day - 1) _newsCount[1]++;
//        else if (ndc.day >= tdc.day - 3 && ndc.day < tdc.day - 1) _newsCount[2]++;
//        else if (ndc.day >= tdc.day - 7 && ndc.day < tdc.day - 3) _newsCount[3]++;
//        else _newsCount[4]++;
//    }
//
//    return 5;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23)];
//    view.backgroundColor = [UIColor yellowColor];
//    
//    UIImageView *bg = [[UIImageView alloc] initWithFrame:view.frame];
//    bg.image = [UIImage imageNamed:@"sectionHeader.png"];
//    [view addSubview:bg];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont boldSystemFontOfSize:18];
//    [view addSubview:label];
//    
//    NSString *headerText;
//    switch (section) {
//        case 0: headerText = [NSString stringWithFormat:@"Сегодня (%d)", _newsCount[0]]; break;
//        case 1: headerText = [NSString stringWithFormat:@"Вчера (%d)", _newsCount[1]]; break;
//        case 2: headerText = [NSString stringWithFormat:@"3 дня назад (%d)", _newsCount[2]]; break;
//        case 3: headerText = [NSString stringWithFormat:@"На прошлой неделе (%d)", _newsCount[3]]; break;
//        case 4: headerText = [NSString stringWithFormat:@"Давно (%d)", _newsCount[4]]; break;
//    }
//    label.text = headerText;
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {   
//    if (section == 4) return _newsCount[section] + 1;
//    return _newsCount[section] ? _newsCount[section] : 0;
    return self.news.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {   
    static NSString *kNewCell = @"NewCell";
    static NSString *kEventCell = @"EventCell"; 
    static NSString *kLoadingCell = @"LoadingCell";
    
//    NSIndexSet *indexes = [self.news indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        New *new = nil;
//        if ([obj isKindOfClass:[Event class]]){
//            new = (Event *)obj;
//        } else {
//            new = (New *)obj;
//        }
//        
//        
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *ndc = [calendar components:NSDayCalendarUnit fromDate:new.date];
//        NSDateComponents *tdc = [calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
//        switch (indexPath.section) {
//            case 0:
//                if (ndc.day == tdc.day) return YES;
//                break;
//            case 1:
//                if (ndc.day == tdc.day - 1) return YES;
//                break;
//            case 2:
//                if (ndc.day >= tdc.day - 3 && ndc.day < tdc.day - 1) return YES;
//                break;
//            case 3:
//                if (ndc.day >= tdc.day - 7 && ndc.day < tdc.day - 3) return YES;
//                break;
//            case 4:
//                if (ndc.day < tdc.day - 7) return YES;
//                break;
//        }
//        return NO;
//    }];
//    
//    NSArray *news = [self.news objectsAtIndexes:indexes];
    
    UITableViewCell *cell;
    if (indexPath.row == self.news.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:kLoadingCell];
        if (!cell) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:nil options:nil];
            cell = [nibs objectAtIndex:0];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
            hud.xOffset = -60;
        } 
        [News get:self.page++ withDelegate:self];
    }
    else {
        NSObject *n = [self.news objectAtIndex:indexPath.row];
        if ([n isKindOfClass:[Event class]]){
            cell = [tableView dequeueReusableCellWithIdentifier:kEventCell];
            if (!cell) {
                NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kEventCell owner:nil options:nil];
                cell = [nibs objectAtIndex:0];
            }
            Event *event = [self.news objectAtIndex:indexPath.row];
            UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
            UILabel *view2 = (UILabel *)[cell viewWithTag:2];
            UITextView *view3 = (UITextView *)[cell viewWithTag:3];
            UILabel *view4 = (UILabel *)[cell viewWithTag:4];
            UIImage *placeHolder = [UIImage imageNamed:@"no_photo.png"];
            view1.image = placeHolder;
            if (event.thumbnailURL) {
                
                //[view1 setImageWithURL:event.thumbnailURL placeholderImage:image];
                
                [view1 setImageWithURL:event.thumbnailURL placeholderImage:placeHolder success:^(UIImage *image) {
                    CGImageRef cgref = [image CGImage];
                    CIImage *cim = [image CIImage];
                    
                    if (cim == nil && cgref == NULL)  
                        view1.image = placeHolder;
                    else 
                        view1.image = image;
                } failure:^(NSError *error) {
                    
                }];
            }
            
            
            view2.text = event.companyName;
            view3.text = event.title;
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"dd MMMM HH:mm";
            view4.text = [df stringFromDate:event.date]; 
        } else {
            New *new = [self.news objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:kNewCell];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:kNewCell owner:nil options:nil] objectAtIndex:0];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell.png"]];
                cell.backgroundView = view;
                cell.textLabel.backgroundColor = [UIColor clearColor];
            }
            
            
            UILabel *textLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *date = (UILabel *)[cell viewWithTag:4];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            textLabel.text = new.title;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"dd MMMM HH:mm";
            date.text = [df stringFromDate:new.date];
            imageView.image = nil;
            if (!new.thumbnailURL) {
                imageView.image = kPLACEHOLDER_IMAGE;
            }
            else {
                UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                hud.center = CGPointMake(imageView.frame.size.width / 2, imageView.frame.size.height / 2);
                [imageView addSubview:hud];
                [hud startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *data = [NSData dataWithContentsOfURL:new.thumbnailURL];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *image = [UIImage imageWithData:data];
                        imageView.image = image;
                        [hud stopAnimating];
                        [hud removeFromSuperview];
                    });
                });
            }
            
            
        }
        
        
        //[imageView setImageWithURL:new.thumbnailURL placeholderImage:kPLACEHOLDER_IMAGE];
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NewDetailView *view = [[NewDetailView alloc] init];
//    NSIndexSet *indexes = [self.news indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        New *new = (New *)obj;
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *ndc = [calendar components:NSDayCalendarUnit fromDate:new.date];
//        NSDateComponents *tdc = [calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
//        switch (indexPath.section) {
//            case 0:
//                if (ndc.day == tdc.day) return YES;
//                break;
//            case 1:
//                if (ndc.day == tdc.day - 1) return YES;
//                break;
//            case 2:
//                if (ndc.day >= tdc.day - 3 && ndc.day < tdc.day - 1) return YES;
//                break;
//            case 3:
//                if (ndc.day >= tdc.day - 7 && ndc.day < tdc.day - 3) return YES;
//                break;
//            case 4:
//                if (ndc.day < tdc.day - 7) return YES;
//                break;
//        }
//        return NO;
//    }];
//    NSArray *news = [self.news objectsAtIndexes:indexes];
    view.currentNew = [self.news objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - NewsDelegate
- (void)newsDidLoad:(NSArray *)news {
    [self.news addObjectsFromArray:news];
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
}

- (void)newsDidFailWithError:(NSString *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
