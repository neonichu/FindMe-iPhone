//
//  BBUMapViewController.m
//  Me
//
//  Created by Boris Bügling on 11.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "BBUMapViewController.h"

@interface BBUMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* title;

@end

#pragma mark -

@implementation BBUMapAnnotation

+(instancetype)annotationWithTitle:(NSString*)title coordinate:(CLLocationCoordinate2D)coordinate {
    id annotation = [BBUMapAnnotation new];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:title];
    return annotation;
}

@end

#pragma mark -

@interface BBUMapViewController ()

@property (nonatomic, assign) CLLocationCoordinate2D destination;
@property (nonatomic, copy) NSString* titleString;

@end

#pragma mark -

@implementation BBUMapViewController

-(void)doneTapped {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

-(id)initWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude title:(NSString *)title {
    self = [super init];
    if (self) {
        self.destination = CLLocationCoordinate2DMake(latitude, longitude);
        self.titleString = title;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self action:@selector(doneTapped)];
    }
    return self;
}

-(void)loadView {
    MKMapView* mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mapView.centerCoordinate = self.destination;
    mapView.region = MKCoordinateRegionMakeWithDistance(self.destination, 500, 500);
    mapView.scrollEnabled = NO;
    mapView.showsUserLocation = NO;
    mapView.zoomEnabled = NO;
    
    [mapView addAnnotation:[BBUMapAnnotation annotationWithTitle:self.titleString
                                                      coordinate:self.destination]];
    [mapView selectAnnotation:[mapView.annotations firstObject] animated:NO];
    
    self.view = mapView;
}

@end
