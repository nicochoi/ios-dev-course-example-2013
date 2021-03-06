//
//  ViewController.m
//  MapViewDemo
//
//  Created by Freshman on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Pin.h"

@interface ViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController
@synthesize mapView;
@synthesize locationManager = _locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // listen to the current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // we use CLLocationCoordinate2D to store a coordinate.
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(22.191856, 113.543186);
    
    // We not only need a point but also a region with distance in order to so it on map.
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);
    
    mapView.region = region;
    

    NSMutableArray *pinsArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    {
        // add an map annotation (pin)
        Pin *pin = [[Pin alloc] init];
        pin.coordinate = CLLocationCoordinate2DMake(22.188826, 113.550729);
        pin.title = @"宋玉生公園";
        pin.subtitle = @"澳門新口岸填海區";        
        
        [pinsArray addObject:pin];
    }
    
    {
        // add another pin
        Pin *pin = [[Pin alloc] init];
        pin.coordinate = CLLocationCoordinate2DMake(22.188473, 113.543454);
        pin.title = @"亞馬喇前地";
        pin.subtitle = @"澳門舊大橋橋口";
        
        [pinsArray addObject:pin];
    }
    
    
    [mapView addAnnotations:pinsArray];

}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // we know if it is showing normal coordinate or current location's coordinate.
    BOOL isCurrentLocation = [(Pin*)annotation isCurrentLocationMark];
    
    // prepare two different identifier according to the coordinate type
    NSString *identifier = @"current location";
    if (!isCurrentLocation)
    {
        identifier = @"normal pin";
    }
    
    // reuse any not-using Pin View with identifier
    MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    // we are running out of pinView and need to create one, if pinView is nil after we dequeue one.
    if (pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    // we will not use custom image on current location.
    // Otherwise, we use our custom image.
    if (![(Pin*)annotation isCurrentLocationMark])
    {
        pinView.image = [UIImage imageNamed:@"pin-arrow.png"];
    }
    
    
    // we need to assign the annotation information to the view.
    // Otherwise it will not display the information.
    pinView.annotation = annotation;
    
    // and we need to ensure that we allow the information to pop up.
    pinView.canShowCallout = YES;
    
    
    // add a button
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Tapped Pin with title: %@", view.annotation.title);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Detail button is tapped on pin: %@", view.annotation.title);
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    mapView.centerCoordinate = newLocation.coordinate;
    
    Pin *pin = [[Pin alloc] init];
    pin.coordinate = newLocation.coordinate;
    pin.title = @"您的位置";
    pin.subtitle = @"";
    
    pin.isCurrentLocationMark = YES;
    
    [mapView addAnnotation:pin];
    
}


@end
