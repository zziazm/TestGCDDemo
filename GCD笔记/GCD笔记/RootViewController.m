//
//  RootViewController.m
//  GCD笔记
//
//  Created by 赵铭 on 2016/10/14.
//  Copyright © 2016年 zziazm. All rights reserved.
//

#import "RootViewController.h"
#import "SDWebImageManager.h"
@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView * tableview;
@property (nonatomic, strong) NSMutableArray * datasource;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasource = @[@"创建队列", @"dispath_after", @"dipatch_group", @"no dispatch_barrier", @"dispatch_barrier",@"dispatch_apply",@"dispatch_apply again",@"Dispach Semaphore"].mutableCopy;
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    // Do any additional setup after loading the view.
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _datasource[indexPath.row];
    return cell;
}


#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self createQueue];
    }
    if (indexPath.row == 1) {
        [self delayExecute];
    }
    if (indexPath.row == 2) {
        [self testGroup];
    }
    if (indexPath.row == 3) {
        [self testNoBarrier];
    }
    if (indexPath.row == 4) {
        [self testBarrier];
    }
    if (indexPath.row == 5) {
        [self testDispatch_apply];
    }
    if (indexPath.row == 6) {
        [self testDispatch_applyAgain];
    }
    if (indexPath.row == 7) {
        [self testDispatchSemaphore];
    }
}

#pragma mark -- Action
- (void)createQueue{

    dispatch_queue_t queue = dispatch_queue_create("com.example.myQueue",  DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"queue %@", [NSThread currentThread]);
    });
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue1, ^{
        NSLog(@"queue1 block1 %@", [NSThread currentThread]);
    });
    dispatch_async(queue1, ^{
        NSLog(@"queue1 block2 %@", [NSThread currentThread]);
    });
    
}

- (void)delayExecute{
    dispatch_time_t time = dispatch_time( DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"wait 3 seconds");
    });
}

- (void)testGroup{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"block1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block2");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"block3");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"done");
    });
//    SDWebImageManager * manger = [[SDWebImageManager alloc] init];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_group_async(group, queue, ^{[[SDWebImageDownloader sharedDownloader ] downloadImageWithURL:[NSURL URLWithString:@"http://s2.51cto.com/wyfs02/M00/88/A1/wKiom1f9tQnRZeN6AAOOopt2FH4232.png-wh_651x-s_2541885854.png"] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//        NSLog(@" download finish");
//    }];
//    });
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"aaaaaa");
//    });
}
- (void)testNoBarrier{
    NSMutableArray * array = @[@"1"].mutableCopy;
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"block1 = %@", array[0]);
        //读取处理block1
    });
    dispatch_async(queue, ^{
        NSLog(@"block2 = %@", array[0]);

        //读取处理block2
    });
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"block3 = %@", array[0]);
        //读取处理block3
    });
    dispatch_async(queue, ^{
        [array replaceObjectAtIndex:0 withObject:@"2"];
        //读取处理block5
    });
    dispatch_async(queue, ^{
        NSLog(@"block4 = %@", array[0]);
    });
}

- (void)testBarrier{
    NSMutableArray * array = @[@"1"].mutableCopy;
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"block1 = %@", array[0]);
        //读取处理block1
    });
    dispatch_async(queue, ^{
        NSLog(@"block2 = %@", array[0]);
        
        //读取处理block2
    });
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"block3 = %@", array[0]);
        //读取处理block3
    });
    dispatch_barrier_async(queue, ^{
        [array replaceObjectAtIndex:0 withObject:@"2"];
    });
    dispatch_async(queue, ^{
        NSLog(@"block4 = %@", array[0]);
    });

}

- (void)testDispatch_apply{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"queue %zu, %@", index, [NSThread currentThread]);
    });
    
    NSLog(@"test");
    dispatch_queue_t serialQueue = dispatch_queue_create("com.example.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_apply(10, serialQueue, ^(size_t index) {
        NSLog(@"serialQueue %zu, %@", index, [NSThread currentThread]);

    });
    NSLog(@"test1");
    
//    NSArray * array = @[@"0", @"1", @"2", @"3",@"4", @"5"];
//    dispatch_apply([array count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t index) {
//        NSLog(@"index = %zu: %@", index , array[index]);
//    });

}

- (void)testDispatch_applyAgain{
    NSArray * array = @[@"aa", @"bb", @"cc", @"dd",@"ee", @"rr"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
       dispatch_apply([array count], queue, ^(size_t index) {
           NSLog(@"index == %zu: %@", index, [array objectAtIndex:index]);
       });
        //等到dispatch_apply函数中的处理全部结束
       dispatch_async(dispatch_get_main_queue(), ^{
           NSLog(@"done");
       });
        
    });
    
}
- (void)testDispatchSemaphore{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     Dispatch Semaphore的计数初始值设为1，保证访问array的线程同时只有一个。
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray * array =  @[].mutableCopy;
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            /*
             当semaphore的计数值大于或等于1时，会将semaphore的计数值减去1，dispatch_semaphore_wait函数会执行返回，即函数返回后semaphore的计数值为0，当其他线程执行block中的代码时，会因为semaphore的计数值为0而处于等待状态，即访问array的线程只有一个，因此可以安全的进行更新             */
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [array addObject:[NSNumber numberWithInt:i]];
            /*
             将semaphore的计数值加1，如果有通过dispatch_sycn_wait函数等待semaphore计数值增加的线程，就由最先等待的线程执行*/
            dispatch_semaphore_signal(semaphore);
        });
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
