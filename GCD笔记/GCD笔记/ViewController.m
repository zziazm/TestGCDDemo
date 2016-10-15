//
//  ViewController.m
//  GCD笔记
//
//  Created by 赵铭 on 16/9/1.
//  Copyright © 2016年 zziazm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray * array;
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray * aray = @[@1].mutableCopy;
    self.array = aray;
    [aray addObject:@1];
    NSLog(@"%p,%p",aray, _array);
    NSLog(@"%@, %@",aray,_array);

//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
//    dispatch_queue_t serialQueue = dispatch_queue_create("com.example.gcd.serialQueue", NULL);
//    
//    dispatch_async(serialQueue, ^{
//        dispatch_sync(serialQueue, ^{
//            NSLog(@"hello world");
//        });
//    });
    
    
    dispatch_queue_t queue = dispatch_queue_create("come.example.gcd.mySerialDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"fsdfs");
    });
    dispatch_queue_t background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(queue, background);
    
    dispatch_time_t time = dispatch_time( DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"wait 3 seconds");
    });
    
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec timespec;
    dispatch_time_t milestone;
    interval = [[NSDate date] timeIntervalSince1970];
    subsecond = modf(interval, &second);//分解interval，返回只是interval小数部分，second获得整数部分
    timespec.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&timespec, 0);
//    dispatch_walltime(const struct timespec *when, <#int64_t delta#>)
    // Do any additional setup after loading the view, typically from a nib.
}


dispatch_time_t getDispatchTimeByDate(NSDate * date){
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec timespec;
    dispatch_time_t milestone;
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);//分解interval，返回只是interval小数部分，second获得整数部分
    timespec.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&timespec, 0);
    return milestone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dispatchGroup:(id)sender {
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
    dispatch_group_notify(group, queue, ^{
        NSLog(@"done");
    });
}
- (IBAction)dispathGroupWait:(id)sender {
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
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        //与group联系的任务已全部执行完
        
    }else{
        //虽然过了指定时间，但还没执行完
    }
}
- (IBAction)noConsiderOrder:(id)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     Dispatch Semaphore的计数初始值设为1，保证访问array的线程同时只有一个。
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray * array =  @[].mutableCopy;
    for (int i = 0; i < 100; i++) {
//        dispatch_group_async(group, queue, ^{
//            /*
//             当semaphore的计数值大于或等于1时，会将semaphore的计数值减去1，dispatch_semaphore_wait函数会执行返回，即函数返回后semaphore的计数值为0，当其他线程执行block中的代码时，会因为semaphore的计数值为0而处于等待状态，即访问array的线程只有一个，因此可以安全的进行更新             */
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            [array addObject:[NSNumber numberWithInt:i]];
//            /*
//             将semaphore的计数值加1，如果有通过dispatch_sycn_wait函数等待semaphore计数值增加的线程，就由最先等待的线程执行*/
//            dispatch_semaphore_signal(semaphore);
//
//        });
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
    dispatch_barrier_async(queue, ^{
        NSLog(@"%@", array);

    });    NSLog(@"%@",[NSThread currentThread]);
//    dispatch_barrier_async(queue, ^{
//        NSLog(@"%@",array);
//    });
//    dispatch_group_t group = dispatch_group_create();
//    for (int i = 0; i < 10000; i++) {
//        
//      dispatch_group_async(group, queue, ^{
//          [array addObject:[NSNumber numberWithInt:i]];
//      });
//    }
//    dispatch_group_notify(group, queue, ^{
//        NSLog(@"%@", group);
//    });
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
}

- (IBAction)testBarrier:(id)sender {
    NSMutableArray * array = @[@0, @1, @2, @3, @4, @5, @6].mutableCopy;
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        //读取处理block1
    });
    dispatch_async(queue, ^{
        //读取处理block2
    });
    dispatch_async(queue, ^{
        //读取处理block3
    });
    dispatch_barrier_async(queue, ^{
        //写入处理block4
    });
    dispatch_async(queue, ^{
        //读取处理block5
    });
    
}


@end
