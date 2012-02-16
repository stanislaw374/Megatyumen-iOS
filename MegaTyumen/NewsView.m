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
#import "Constants.h"

@interface NewsView()
@property (nonatomic, strong) News *news;                           // Новости
@property (nonatomic, strong) NewDetailView *newsDetailView;        // Экран просмотра новости
@property (nonatomic, strong) MainMenu *mainMenu;

- (void)didPassAuthorization:(NSNotification *)notification;         // Уведомление об успешной авторизации
- (void)didGetNewsCount:(NSNotification *)notification;              // Уведомление о загрузке количества новостей
- (void)didGetNews:(NSNotification *)notification;                   // Уведомление о загрузке новостей, которые должны быть отображены в данный момент
@end

@implementation NewsView
@synthesize loadingCell = _loadingCell;
@synthesize news = _news;
@synthesize newsDetailView = _newsDetailView;
@synthesize mainMenu = _mainMenu;

-(void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)didGetNewsCount:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)didGetNews:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Лента новостей";
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewsCount:) name:kNOTIFICATION_DID_GET_NEWS_COUNT object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNews:) name:kNOTIFICATION_DID_GET_NEWS object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
        
    self.tableView.rowHeight = 104;
    
    self.news = [[News alloc] init];
    [self.news getCount];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_NEWS_COUNT object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_NEWS object:nil];
    [self setLoadingCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.news.count ? 5 : 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 23)];
    view.backgroundColor = [UIColor yellowColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:view.frame];
    bg.image = [UIImage imageNamed:@"sectionHeader.png"];
    [view addSubview:bg];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    [view addSubview:label];
    
    if (self.news.count) {
        NSString *headerText;
        switch (section) {
            case 0: headerText = [NSString stringWithFormat:@"Сегодня (%d)", self.news.todayCount]; break;
            case 1: headerText = [NSString stringWithFormat:@"Вчера (%d)", self.news.yesterdayCount]; break;
            case 2: headerText = [NSString stringWithFormat:@"3 дня назад (%d)", self.news.threeDaysAgoCount]; break;
            case 3: headerText = [NSString stringWithFormat:@"На прошлой неделе (%d)", self.news.weekAgoCount]; break;
            case 4: headerText = [NSString stringWithFormat:@"Давно (%d)", self.news.othersCount]; break;
        }
        label.text = headerText;
    }
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.news.count) return 1;
    switch (section) {
        case 0: return self.news.todayLoaded == self.news.todayCount ? self.news.todayCount : self.news.todayLoaded + 1;
        case 1: return self.news.yesterdayLoaded == self.news.yesterdayCount ? self.news.yesterdayCount : self.news.yesterdayLoaded + 1;
        case 2: return self.news.threeDaysAgoLoaded == self.news.threeDaysAgoCount ? self.news.threeDaysAgoCount : self.news.threeDaysAgoLoaded + 1;
        case 3: return self.news.weekAgoLoaded == self.news.weekAgoCount ? self.news.weekAgoCount : self.news.weekAgoLoaded + 1;
        case 4: return self.news.othersLoaded == self.news.othersCount ? self.news.othersCount : self.news.othersLoaded + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    static NSString *kCell = @"NewsCell";
    static NSString *kLoadingCell = @"LoadingCell";
    
    UITableViewCell *cell;
    
    // Если не известно количество новостей
    if (!self.news.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:kLoadingCell];
        if (!cell) {
            [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
            cell = self.loadingCell;
            self.loadingCell = nil;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
            hud.xOffset = 60;
        }   
    }
    else {
        int loaded = 0;
        int count = 0;
        switch (indexPath.section) {
            case 0: loaded = self.news.todayLoaded; count = self.news.todayCount; break;
            case 1: loaded = self.news.yesterdayLoaded; count = self.news.yesterdayCount; break;
            case 2: loaded = self.news.threeDaysAgoLoaded; count = self.news.threeDaysAgoCount; break;
            case 3: loaded = self.news.weekAgoLoaded; count = self.news.weekAgoCount; break;
            case 4: loaded = self.news.othersLoaded; count = self.news.othersCount; break;
        }
        // Если нужно отобразить временную ячейку с надписью "Загрузка..."
        if (indexPath.row == loaded) {
            cell = [tableView dequeueReusableCellWithIdentifier:kLoadingCell];
            if (!cell) {
                [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
                cell = self.loadingCell;
                self.loadingCell = nil;
                UILabel *view1 = (UILabel *)[cell viewWithTag:1];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
                //hud.frame = CGRectInset(hud.frame, view1.frame.origin.x + view1.frame.size.width + 8, 0);
            } 
            [self.news getNextNews];
        }
        // Если новость загружена
        else {
            New *new = (New *)[self.news.items objectForKey:indexPath];
            cell = [tableView dequeueReusableCellWithIdentifier:kCell];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell.png"]];
                cell.backgroundView = view;
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.textLabel.numberOfLines = 0;
            }    
            cell.textLabel.text = new.title;
            cell.imageView.image = new.thumbnail;            
            if (!new) {
                cell.textLabel.text = @"";
                cell.imageView.image = nil;
            }
        }
    }

    return cell;
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

#pragma mark - Table view delegate

//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.newsDetailView) {
        self.newsDetailView = [[NewDetailView alloc] init];
    }
    self.newsDetailView.currentNew = [self.news.items objectForKey:indexPath];
    [self.navigationController pushViewController:self.newsDetailView animated:YES];
    
    [News setReadCount:[News readCount] + 1];
}

@end
