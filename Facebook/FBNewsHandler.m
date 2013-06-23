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


- (void) processData:(NSDictionary *)result
{
    
}



- (void)sessionStateChanged:(FBSession *)session 
                      state:(FBSessionState) state
                      error:(NSError *)error
{
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
    
    if (error) {
        [globalKit showError:error.localizedDescription];
        
    }   
}
@end
