//
//  SHBlurSettingView.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHBlurSettingView.h"

@implementation SHBlurSettingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self=[[[NSBundle mainBundle] loadNibNamed:@"SHBlurSettingView" owner:self options:nil] firstObject];
    }
    
    self.accountTbView.backgroundColor=[UIColor clearColor];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SHBlurSettingView" owner:self options:nil] objectAtIndex:1];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    UILabel *userName=(UILabel*)[cell viewWithTag:11];
    userName.textColor=[UIColor whiteColor];
    UILabel *accountType=(UILabel*)[cell viewWithTag:12];
    accountType.textColor=[UIColor lightGrayColor];;
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    
    return cell;
}

@end
