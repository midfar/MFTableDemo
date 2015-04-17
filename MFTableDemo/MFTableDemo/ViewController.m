//
//  ViewController.m
//  MFTableDemo
//
//  Created by Midfar Sun on 4/15/15.
//  Copyright (c) 2015 Midfar Sun. All rights reserved.
//

#import "ViewController.h"
#import "MFTextTableViewCell.h"
#import "JSONKit2.h"

@interface ViewController ()<MFTextTableViewCellDelegate>
{
    /**
     是否支持插入；如果是，那么编辑状态下最后一项可用于添加数据
     */
    BOOL isSupportInsert;
    /**
     是否支持移动；如果是，那么编辑状态下cell右侧有移动icon
     */
    BOOL isSupportMove;
    /**
     是否支持单个删除
     */
    BOOL isSupportSingleDelete;
    /**
     是否支持多选删除；如果是，那么编辑状态下cell左侧有复选框，导航栏左上有删除按钮
     */
    BOOL isSupportMutiDelete;
    
    BOOL keyboardIsShown;
    
    NSMutableArray *dataArr;//列表数据
    NSMutableIndexSet *selectedRow;//被选中的索引列表，用于数据删除
}
@end

@implementation ViewController
@synthesize mTableView, editButton, deleteButton;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isSupportInsert = YES;
    isSupportMove = YES;
    isSupportSingleDelete = YES;
    isSupportMutiDelete = YES;
    dataArr = [NSMutableArray arrayWithArray:@[@"A", @"B", @"C", @"D", @"E", @"F", @"G",
                                               @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                                               @"O", @"P", @"Q", @"R", @"S", @"T",
                                               @"U", @"V", @"W", @"X", @"Y", @"Z"]];
    selectedRow = [NSMutableIndexSet indexSet];
    mTableView.allowsMultipleSelectionDuringEditing = isSupportMutiDelete;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification
-(void)keyboardWillShow:(NSNotification *)notification
{
    keyboardIsShown = YES;
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    keyboardIsShown = NO;
}

#pragma mark - Function
- (NSArray *)convertIndexSetToArray:(NSIndexSet *)indexSet
{
    NSMutableArray *indexPathArr=[NSMutableArray arrayWithCapacity:10];
    for (NSUInteger idx = [indexSet firstIndex]; idx != NSNotFound; idx = [indexSet indexGreaterThanIndex:idx]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPathArr addObject:indexPath];
    }
    return indexPathArr;
}

#pragma mark - IBAction
- (IBAction)editButtonClicked:(id)sender
{
    NSLog(@"editButtonClicked");
    BOOL isSelected = editButton.isSelected;
    if (isSelected) {//如果是selected状态，则tableview处于编辑模式
        if (isSupportInsert) {//移除最后一个空字符串，如果存在的话
            if ([@"" isEqualToString:dataArr.lastObject]) {
                NSInteger rowIndex = dataArr.count-1;
                [dataArr removeLastObject];
                NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
                [mTableView deleteRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        [self.view endEditing:YES];
        
    }else{
        if (isSupportInsert) {//添加最后一个空字符串
            NSInteger rowIndex = dataArr.count;
            [dataArr addObject:@""];
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
            [mTableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    editButton.selected = !isSelected;
    if (isSupportMutiDelete) {
        deleteButton.hidden = isSelected;
    }
    [mTableView setEditing:!isSelected animated:YES];
    [selectedRow removeAllIndexes];
    NSLog(@"editButtonClicked, dataArr=%@", [dataArr JSONString2]);
}

- (IBAction)deleteButtonClicked:(id)sender
{
    NSLog(@"deleteButtonClicked");
    if (selectedRow.count!=0) {//删除选中的项目
        [dataArr removeObjectsAtIndexes:selectedRow];
        NSArray *indexPathArr = [self convertIndexSetToArray:selectedRow];
        [mTableView deleteRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];
        [selectedRow removeAllIndexes];
    }
}

- (IBAction)hideKeyboardButtonClicked:(id)sender
{
    NSLog(@"hideKeyboardButtonClicked");
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = dataArr.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //when the keyboard is showing, indexPath will be lost if the cell move one place to another
    MFTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell==nil) {
        NSLog(@"[ERROR] cell==nil");
    }
    NSString *text = [dataArr objectAtIndex:indexPath.row];
    cell.delegate = self;
    //[cell setRow:indexPath.row count:dataArr.count];
    [cell setMText:text];
    [cell setMEditing:editButton.isSelected];
    [cell setMIsSupportMove:isSupportMove];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:commitEditingStyle:%zd forRowAtIndexPath:%zd", editingStyle, indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[tableView reloadData];
        //[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
        
    }else if(editingStyle == UITableViewCellEditingStyleInsert){
        [self whenInsertTableView:tableView forRowAtIndexPath:indexPath];
    }
    NSLog(@"commitEditingStyle:dataArr=%@", [dataArr JSONString2]);
}

- (void)whenInsertTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"whenInsertTableView dataArr=%@", [dataArr JSONString2]);
    //insert placeholder @"" in dataArr
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(indexPath.row+1) inSection:0];
    [dataArr insertObject:@"" atIndex:newIndexPath.row];
    [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    //NSLog(@"whenInsertTableView center dataArr=%@", [dataArr JSONString2]);
    
    //focus to next textField
    [tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    MFTextTableViewCell *newCell = (MFTextTableViewCell *)[tableView cellForRowAtIndexPath:newIndexPath];
    [newCell setMText:@""];
    //NSLog(@"newCell mText=%@", newCell.mText);
    [newCell showMKeyboard];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当前行在编辑状态时移动会造成UI显示问题
    if (isSupportMove && keyboardIsShown){
        return NO;
    }
    return isSupportMove;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (keyboardIsShown) {//键盘显示时，不能移动
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"tableView:moveRowAtIndexPath:%zd toIndexPath:%zd", sourceIndexPath.row, destinationIndexPath.row);
    id oldValue = [dataArr objectAtIndex:sourceIndexPath.row];
    [dataArr removeObjectAtIndex:sourceIndexPath.row];
    [dataArr insertObject:oldValue atIndex:destinationIndexPath.row];
    NSLog(@"moveRowAtIndexPath dataArr=%@", [dataArr JSONString2]);
    //[tableView reloadData];//这里reload一次，避免找下一个cell的位置不对
    //reload前要获取最新的值
    //[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
    //NOTICE:调用reloadData会导致前面的复选框消失;会导致隐藏键盘，最后一个值会保存错位
}

#pragma mark - MFTextTableViewCellDelegate
- (void)mfTextTableViewCell:(MFTextTableViewCell *)cell textFieldShouldReturn:(NSString *)text
{
    NSIndexPath *indexPath = [mTableView indexPathForCell:cell];
    if (indexPath==nil) {//cell is not visible
        //输入状态下，scrollView滑动导致cell不可见时要隐藏键盘，否则会导致无法更新输入的数据
        [self.view endEditing:YES];
        return;
    }
    NSLog(@"mfTextTableViewCell:%zd textFieldShouldReturn:%@", indexPath.row, text);
    BOOL isLastCell = (indexPath.row >= dataArr.count - 1)? YES : NO;
    BOOL endEdit = (isLastCell && [@"" isEqualToString:text]) ? YES : NO;
    if (isLastCell==NO) {//hasNext, scroll and focus to next textField
        [CATransaction begin];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(indexPath.row+1) inSection:0];
        [mTableView beginUpdates];
        [CATransaction setCompletionBlock:^{
            //focus to next textField after animate finish, to avoid newCell==nil
            MFTextTableViewCell *newCell = (MFTextTableViewCell *)[mTableView cellForRowAtIndexPath:newIndexPath];
            //NSLog(@"newCell mText=%@", newCell.mText);
            if (newCell==nil) {
                NSLog(@"[ERROR]newCell is nil");
            }else{
                [newCell showMKeyboard];
            }
        }];
        [mTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        [mTableView endUpdates];
        [CATransaction commit];
        
    }else{
        if (isSupportInsert && endEdit==NO) {
            [self whenInsertTableView:mTableView forRowAtIndexPath:indexPath];
        }else{
            [self.view endEditing:YES];
        }
    }
    NSLog(@"textFieldShouldReturn: dataArr=%@", [dataArr JSONString2]);
}

- (void)mfTextTableViewCell:(MFTextTableViewCell *)cell textFieldValueChanged:(NSString *)text
{
    NSIndexPath *indexPath = [mTableView indexPathForCell:cell];
    if (indexPath==nil) {//cell is not visible
        //输入状态下，scrollView滑动导致cell不可见时要隐藏键盘，否则会导致无法更新输入的数据
        [self.view endEditing:YES];
        return;
    }
    NSLog(@"mfTextTableViewCell:%zd textFieldValueChanged:%@", indexPath.row, text);
    [dataArr replaceObjectAtIndex:indexPath.row withObject:text];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:didSelectRowAtIndexPath:%zd", indexPath.row);
    if (tableView.editing==NO) {//非编辑模式
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else{//编辑模式，需要记住被选中的索引
        [selectedRow addIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView:didDeselectRowAtIndexPath:%zd", indexPath.row);
    if (tableView.editing==NO) {//非编辑模式
        //do nothing
        
    }else{//编辑模式，需要移除被选中的索引
        [selectedRow removeIndex:indexPath.row];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (isSupportInsert) {//这里显示两种图标的话，会导致cell重用异常
    //    if (indexPath.row==dataArr.count-1) {
    //        return UITableViewCellEditingStyleInsert;
    //    }
    //}
    if (isSupportSingleDelete) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

@end

