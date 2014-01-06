//
//  GMHTTPClient.h
//  speakeasy
//
//  Created by Djengo on 8/02/13.
//  Copyright (c) 2013 Djengo. Under MIT Licence.
//  http://opensource.org/licenses/MIT

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface GMHTTPClient : AFHTTPClient

+ (GMHTTPClient*)sharedInstance;

@end
