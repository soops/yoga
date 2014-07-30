//
//  SHAccountSelectionView.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHAccountSelectionViewDelegate <NSObject>

@optional
- (void)userDidChangeSelection:(BOOL)facebook twitter:(BOOL)twitter instagram:(BOOL)instagram;

@end

@interface SHAccountSelectionView : UIView<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *accountInfo;
}
@property (strong, nonatomic) IBOutlet UITableView *accountTbView;
@property (nonatomic, assign) id<SHAccountSelectionViewDelegate> delegate;
@end
