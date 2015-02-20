//
//  ChatViewController.m
//  ChatClient
//
//  Created by Calvin Tuong on 2/19/15.
//  Copyright (c) 2015 Calvin Tuong. All rights reserved.
//

#import "ChatViewController.h"
#import <Parse/Parse.h>
#import "MessageCell.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) NSArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Chat";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    
    id topGuide = self.topLayoutGuide;
    UITextField *messageField = self.messageField;
    UIButton *sendButton = self.sendButton;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(messageField, sendButton, topGuide);
    
    // place the message field and button under the nav bar
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[messageField]" options:0 metrics:nil views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[sendButton]" options:0 metrics:nil views:viewsDictionary]];
    
    [self getMessages];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMessages) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSendButton:(id)sender {
    NSString *messageText = self.messageField.text;
    [self clearMessageField];
    
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"text"] = messageText;
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self getMessages];
        } else {
            NSLog(@"failed to save %@", message);
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    cell.messageLabel.text = self.messages[indexPath.row][@"text"];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

#pragma mark - Private methods

- (void)getMessages {
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query addDescendingOrder:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // success, reload table data
            self.messages = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error retrieving messages: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)clearMessageField {
    self.messageField.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
