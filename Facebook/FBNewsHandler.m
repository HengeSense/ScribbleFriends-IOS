//
//  FBNewsHandler.m
//  scribble
//
//  Created by Tianhu Yang on 1/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FBNewsHandler.h"
#import <FacebookSDK/FacebookSDK.h>
NSString *readPerms[]={@"read_stream", @"user_photos", @"friends_photos"};NSString *first = @"{'post':'SELECT actor_id,post_id, created_time,description,message,attachment.media,attachment.media.photo.pid FROM stream WHERE filter_key IN ( SELECT filter_key FROM stream_filter WHERE uid = me() AND name = \"Photos\") order by created_time ";
NSString *mid = @" LIMIT 50'";
NSString *second = @",'photo':'SELECT  src,images,pid FROM photo where pid IN (SELECT attachment.media.photo.pid from #post)','picture':'SELECT pic_square,name,uid from user where uid IN(SELECT actor_id from #post )'}";

@interface FBNewsHandler()
{
    BOOL newsFeed;
    int requestCount;
}

@end
@implementation FBNewsHandler
- (void) requestNewsSession
{
    newsFeed=NO;
    requestCount=1;
    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:readPerms count:3] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
}

- (void) requestNewsFeed:(FBSession *)session
{
    NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%@%@%@", first,mid,second], @"q", nil];
    FBRequest *request=[[FBRequest alloc] initWithSession:session graphPath:@"fql" parameters:queryParam HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //
        [self requestNewsFeedCompleted:connection result:result error:error];
    }];
}


- (void) requestNewsFeedCompleted:(FBRequestConnection *)connection result:(id) result error:(NSError *)error
{
    if (error) {
        if ([error code] == 606) {// permission
            // denied
            if (requestCount > 0) {
                //newPerms();
                --requestCount;
            } else
            {
               // display denied 
            }
        } else
           [globalKit showError:error.localizedDescription];
        
        
    } 
    else {
        [self processData:result];
    }
}


- (NSArray*) processData:(NSDictionary *)result
{
    
    NSMutableArray *data = [result objectForKey:@"data"];
    NSMutableArray *postsJSON = [[data objectAtIndex:0] objectForKey:@"fql_result_set"];
    for (int index = 0; index < postsJSON.count; ++index) {
        NSMutableDictionary *postJSON = [postsJSON objectAtIndex:index];
        NSMutableArray *mediaJSON = [[postJSON objectForKey:@"attachment"] objectForKey:@"media"];
        [postJSON setObject:[[[mediaJSON objectAtIndex:0] objectForKey:@"photo"] objectForKey:@"pid"] forKey:@"pid"];
    }
    NSMutableArray *photosJSON = [[data objectAtIndex:1] objectForKey:@"fql_result_set"];
    NSMutableDictionary *photos = [NSMutableDictionary dictionary];
    for (int index = 0; index < photosJSON.count; ++index) {
        NSMutableDictionary *photoJSON = [photosJSON objectAtIndex:index];
        NSString *pid = [photoJSON objectForKey:@"pid"];
        [photos setObject:photoJSON forKey:pid];
    }
    NSMutableArray *picturesJSON = [[data objectAtIndex:2] objectForKey:@"fql_result_set"];
    NSMutableDictionary *pictures = [NSMutableDictionary dictionary];
    for (int index = 0; index < picturesJSON.count; ++index) {
        NSMutableDictionary *pictureJSON = [picturesJSON objectAtIndex:index];
        [pictures setObject:pictureJSON forKey:[[pictureJSON objectForKey:@"uid"] stringValue]];
        
    }
    NSMutableArray *news = [NSMutableArray arrayWithCapacity:postsJSON.count];
    for (int index = 0; index < postsJSON.count; ++index) {
        [news addObject:[NSMutableDictionary dictionary]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    for (int index = 0; index < news.count; ++index) {
        NSMutableDictionary *dict = [news objectAtIndex:index];
        NSMutableDictionary *post = [postsJSON objectAtIndex:index];
        NSString *time = [[post objectForKey:@"created_time"] stringValue];
        [dict setObject:time forKey:@"created_time"];
        [dict setObject:[post objectForKey:@"post_id"] forKey:@"postid"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time longLongValue]];
        [dict setObject:[dateFormatter stringFromDate:date] forKey:@"time"];
        NSString *desc = [post objectForKey:@"description"];
        if ([desc isKindOfClass:[NSNull class]])
            desc = @"";
        [dict setObject:desc forKey:@"description"];
        [dict setObject:[post objectForKey:@"message"] forKey:@"message"];
        
        NSMutableDictionary *item = [photos objectForKey:[post objectForKey:@"pid"]];
        if (item) {
            [dict setObject:[item objectForKey:@"src"] forKey:@"src"];
            NSMutableArray *images = [item objectForKey:@"images"];
            for (int j = 0; j < images.count; ++j) {
                NSMutableDictionary *image = [images objectAtIndex:j];
                NSNumber *width = [image objectForKey:@"width"];
                NSNumber *height = [image objectForKey:@"height"];
                if ([width intValue] <= globalKit.canvasSize.width
                    && [height intValue] <= globalKit.canvasSize.height) {
                    [dict setObject:[image objectForKey:@"source"] forKey:@"image"];
                    break;
                }
                
            }
            if ([dict objectForKey:@"image"] == nil) {
                [dict setObject:[item objectForKey:@"src"] forKey:@"image"];
            }
        }
        item = [pictures objectForKey:[[post objectForKey:@"actor_id"] stringValue]];
        if (item != nil) {
            [dict setObject:[item objectForKey:@"pic_square"] forKey:@"picture"];
            [dict setObject:[item objectForKey:@"name"] forKey:@"name"];
        }
        
    }
    return news;
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    
    if (error) {
        [globalKit showError:error.localizedDescription];
        return;
    }
    
    switch (state) {
        case FBSessionStateOpen: 
            if (newsFeed==NO) {
                newsFeed=YES;
                [self requestNewsFeed:session];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to 
            // be looking at the root view.
            break;
        default:
            break;
    }
   
}
@end
