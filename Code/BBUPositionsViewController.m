//
//  BBUPositionsViewController.m
//  Me
//
//  Created by Boris Bügling on 11.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <OctoKit/OctoKit.h>

#import "BBUCredentials.h"
#import "BBUMapViewController.h"
#import "BBUPositionsViewController.h"
#import "OCTGist.h"
#import "UIViewControllerContainer.h"

static NSString* const kCellIdentifier = @"CellIdentifier";

@interface BBUPositionsViewController ()

@property OCTClient* client;
@property NSMutableArray* dates;
@property NSMutableArray* positions;

@end

#pragma mark -

@implementation BBUPositionsViewController

-(NSValue*)coordinateFromGist:(OCTGist*)gist {
    NSString* contentJSON = gist.files[@"me.geojson"][@"content"];
    if (!contentJSON) {
        return nil;
    }
    
    NSError* error;
    id JSON = [NSJSONSerialization JSONObjectWithData:[contentJSON dataUsingEncoding:NSUTF8StringEncoding]
                                              options:0
                                                error:&error];
    if (!JSON) {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    }
    
    NSArray* coordinates = JSON[@"geometry"][@"coordinates"];
    return [NSValue valueWithMKCoordinate:CLLocationCoordinate2DMake([coordinates[1] floatValue], [coordinates[0] floatValue])];
}

-(void)fetchGistAtURL:(NSURL*)url {
    NSURLRequest* request = [self.client requestWithMethod:@"GET" path:[url relativePath] parameters:nil];
    
    [[[self.client enqueueRequest:request resultClass:[OCTGist class]] deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTResponse* response) {
         if (!response.parsedResult || ![response.parsedResult isKindOfClass:[OCTGist class]]) {
             return;
         }
         
         NSValue* coordinateValue = [self coordinateFromGist:response.parsedResult];
         
         if (coordinateValue) {
             [self.dates addObject:[response.parsedResult created_at]];
             [self.positions addObject:coordinateValue];
         }
     }];
}

-(void)fetchGists {
    NSURLRequest* request = [self.client requestWithMethod:@"GET"
                                                 path:[NSString stringWithFormat:@"gists/%@", GIST_ID]
                                           parameters:nil
                                      notMatchingEtag:nil];
    
    RAC(self.positions) = [[RACSignal combineLatest:@[ [self.client enqueueRequest:request resultClass:[OCTGist class]] ]
                                             reduce:^(OCTResponse* response) {
                                                 OCTGist* gist = response.parsedResult;
                                                 
                                                 __block unsigned int counter = 0;
                                                 [[[gist.history.rac_sequence map:^id(NSDictionary* historyItem) {
                                                     return [NSURL URLWithString:historyItem[@"url"]];
                                                 }] signal] subscribeNext:^(NSURL* url) {
                                                     counter++;
                                                     
                                                     if (counter >= 100) {
                                                         return;
                                                     }
                                                     
                                                     [self fetchGistAtURL:url];
                                                 }];
                                                 
                                                 self.dates = [@[ gist.created_at ] mutableCopy];
                                                 return [@[ [self coordinateFromGist:gist] ] mutableCopy];
                                             }] deliverOn:[RACScheduler mainThreadScheduler]];
}

-(id)init {
    UICollectionViewFlowLayout* flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        self.collectionView.pagingEnabled = YES;
        
        [self.collectionView registerClass:[UIViewControllerContainer class] forCellWithReuseIdentifier:kCellIdentifier];
        
        [RACAble(self.positions) subscribeNext:^(id value) {
            [self.collectionView reloadData];
        }];
        
        OCTUser* user = [OCTUser userWithLogin:GITHUB_USERNAME server:[OCTServer dotComServer]];
        self.client = [OCTClient authenticatedClientWithUser:user password:GITHUB_PASSWORD];
        
        [self fetchGists];
    }
    return self;
}

#pragma mark - UICollectionView data source methods

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CLLocationCoordinate2D coordinate = [self.positions[indexPath.row] MKCoordinateValue];
    
    UIViewControllerContainer* container = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                                     forIndexPath:indexPath];
    container.viewController = [[BBUMapViewController alloc] initWithLatitude:coordinate.latitude
                                                                    longitude:coordinate.longitude
                                                                        title:self.dates[indexPath.row]];
    return container;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.positions.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

@end
