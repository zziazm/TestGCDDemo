# TestGCDDemo
GCD是异步执行任务的技术支之一，开发者只需要将想要执行的block任务添加到适当的`Dispatch Queue`（调度队列）里，GCD就能生成必要的线程并计划地执行任务。由于GCD线程管理是作为系统的一部分实现的，因此可统一管理,这样就比以前的线程更有效率。下面的例子代码[在这里](https://github.com/zziazm/TestGCDDemo)。

##Dispatch Queue
`Dispatch Queue` 是执行任务的等待队列，添加到`Dispatch Queue`的任务按照FIFO（先进先出）执行处理。GCD里存在两中`Dispatch Queue`：
- `Serial Dispatch Queue`: 串行队列。使用一个线程串行执行添加到其中的任务。
- ` Concurrent Dispatch Queue`: 并行队列。使用多个线程并行执行添加到其中的任务。

获取这两种队列的方法有两种：
1. 通过`dispatch_queue_create(const char *label, <#dispatch_queue_attr_t attr#>)
`函数可生成Dispatch Queue。第一个参数是给queue指定一个标识，该标识在instrument和崩溃时会显示，推荐使用的格式是 (com.example.myqueue) ，可以设置为NULL。第二个参数设置为`DISPATCH_QUEUE_SERIAL `是生成Serial Dispatch Queue，设置为`DISPATCH_QUEUE_CONCURRENT`是生成Concurrent Dispatch Queue。在iOS6之前， Dispatch Queue需要程序员自己去释放，使用`dispatch_release()`。
```
 dispatch_queue_t queue = dispatch_queue_create("come.example.gcd.mySerialDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"fsdfs");
    });
    dispatch_release(queue);
```
block被提交到queue后，会持有queue的引用计数，直到block完成为止，一旦queue的所有引用都释放后，queue将会被系统dealloc。上面代码中的queue 虽然在添加了block之后立即release了，但是block已经持有了queue,所以等到block执行后queue才会释放。
2. 获取系统提供的Dispatch Queue。
系统提供了`dispatch_get_main_queue() `,这个是主线程，是Serial Dispatch Queue。
Global Dispatch Queue 是所有应用程序都能够使用的Concurrent Dispatch Queue；需要使用并行队列时，可以不用通过`dispatch_queue_create`创建Concurrent Dispatch Queue，直接获取Global Dispatch Queue即可。
```
 dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue1, ^{
        NSLog(@"queue1 block1 %@", [NSThread currentThread]);
    });
    dispatch_async(queue1, ^{
        NSLog(@"queue1 block2 %@", [NSThread currentThread]);
    });
```
控制台打印的结果
```
queue1 block1 <NSThread: 0x60000007fc80>{number = 3, name = (null)}
queue1 block2 <NSThread: 0x60800026ab80>{number = 5, name = (null)}
```
queue1这个队列里系统自动生成了两个线程去执行block任务。
Global Dispatch Queue有四种优先级
```
#define DISPATCH_QUEUE_PRIORITY_HIGH 2
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
```

##Dispatch async 和 sycn
dispatch_asycn函数的"asycn"意味着异步，就是将block追加到指定的queue中后，dispatch_asycn函数立即返回，不会等待执行的结果。
dispatch_sycn函数意味着同步，也就是将block函数追加到queue中后，在block任务执行完之前，dispatch_sycn函数会一直等待。
dispatch_sycn函数使用简单，所以也容易引起死锁问题，例如在主线程中执行以下代码就会造成死锁：
```
 dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"hello world");
    });
```
主线程要等待dispatch_syn函数返回后才能执行block中的代码，而不执行block中的代码，dispatch_sycn函数又无法返回，因此造成了死锁。下面的例子也是一样的：
```
dispatch_queue_t mainQueue = dispatch_get_main_queue();
dispatch_async(mainQueue, ^{
     dispatch_sync(mainQueue, ^{
            NSLog(@"hello world");
        });
 });

```
在串行队列中也会有同样的问题：
```
dispatch_queue_t serialQueue = dispatch_queue_create("com.example.gcd.serialQueue", NULL);    dispatch_async(serialQueue, ^{
        dispatch_sync(serialQueue, ^{
            NSLog(@"hello world");
        });
    });
```
nslog不会被执行。

##Dispatch Group
经常会碰到这种情况，想要在加入到Dispatch Queue中的多个block任务都执行完后取执行其他任务，如果使用的是串行队列，只要将所有的block任务加入到串行队列并在最后追加其他任务即可；如果使用的是并行队列或者有多个DIspatch Queue时，可以使用Dispatch Group。
```
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
```
在上面的示例中` dispatch_group_async(<#dispatch_group_t group#>, dispatch_queue_t queue, <#^(void)block#>)
`是将block提交到queue中，同时将block和group联系起来。
`    dispatch_group_notify(dispatch_group_t group, <#dispatch_queue_t queue#>, <#^(void)block#>)
`是等到之前与group联系过的block执行完后会把这个block提交到queue中。
无论向什么样的Dispatch Queue中追加任务，使用Dispatch Group都可以监视这些任务的结束。
另外，在Dispatch Group中也可以使用dispatch_group_wait函数仅等待全部任务执行结束。
```
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
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
```
`dispatch_group_wait `函数会同步地等待与group有联系的block执行完成。
这个函数的第二个参数是等待时间，上面的示例中是永久等待，如果想要指定等待时间：
```
 dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC);
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        //与group联系的任务已全部执行完
        
    }else{
        //虽然过了指定时间，但还没执行完
    }
```

##Dispatch_barrier_async
在访问数据库或文件时，如果多个读取处理并行操作是不会有问题的，但是写入处理不可以与其他的写入处理以及包含读取处理的其他处理并行执行。也就是说，为了高效访问，读取处理追加到Concurrent Dispatch Queue中，写入处理在任意一个读取处理没有执行的状态下，追加到Serial Dispatch Queue中即可（在写入处理没有执行之前，读取处理不可执行）。

```
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
    dispatch_async(queue, ^{
        //写入处理block4
    });
    dispatch_async(queue, ^{
        //读取处理block5
    });
```
如果像上面这样简单地在`dispatch_asycn`函数中加入写入处理，那么根据Concurrent Dispatch的性质，就有可能先执行了block5的写入处理，然后在写入处理前面的读取处理中就会读取到与期待不符的数据，还可能因非法访问导致应用程序异常结束，如果追加多个写入处理，则可能发生更多问题，比如数据竞争。
因此我们要使用`dispatch_barrier_async(<#dispatch_queue_t queue#>, <#^(void)block#>)  `函数。`dispatch_barrier_asycn`会等到追加到queue中的block任务执行完后，再将指定的block任务追加到queue中，然后等到指定的block执行完后，queue才恢复一般的动作，之后追加的block任务才开始执行。
```
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
```



##dispath_after
想要在指定时间后将block添加到队列里，可以使用dispatch_after函数来实现。
```
    dispatch_time_t time = dispatch_time( DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"wait 3 seconds");
    });
```
需要注意的是，dispatch_after函数并不是在指定的时间后执行block，而是在指定的时间将block添加到queue中。在上面的代码中，因为主线程在RunLoop中执行，所以在每隔1/60秒执行的RunLoop中，block最快在3s后执行，最慢在3s+1/60s后执行，并且在主线程又大量处理追加或主线程的处理本身有延时，这个时间会更长。
dispatch_after的第一个参数是指定时间用的`dispatch_time_t`类型的值，该值可以用dispatch_time或dispatch_walltime函数获得。
`    dispatch_time(<#dispatch_time_t when#>, <#int64_t delta#>)
`
dispatch_time函数能够获取从第一个参数指定的时间开始，到第二个参数指定的单位时间之后的时间。第一个参数设置为` DISPATCH_TIME_NOW`表示是从现在的时间开始的。第二个参数是数值和NSEC_TIME_NOW的乘积得到单位为毫微秒的数值。"ull"是C语言的数值字面量，是显示表示类型时使用的字符串（标识“unsinged long long”)。
dispatch_walltime函数由POSIX中使用的struct time spec类型的时间得到dispatch_time_t类型的值。dispatch_time通常用于计算相对时间，dispatch_walltime通常用于计算绝对时间。例如在dispatch_after函数中想指定2016年11月11日11时11分11秒这一绝对时间的情况。
`    dispatch_walltime(const struct timespec *when, <#int64_t delta#>)
`
第一个参数是一个结构体指针，我们可以通过NSDate对象操作完成：
```
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
```



##dispatch_apply
`    dispatch_apply(<#size_t iterations#>, dispatch_queue_t  _Nonnull queue, <#^(size_t)block#>)
`函数是`dispatch_sycn`和`Dispatch Group`的关联API。该函数按指定的次数将指定的block追加到指定的Dispatch Group中，并等待所有的block执行完后函数返回。第一个参数是迭代的次数，第二个参数是指定的queue，第三个参数是指定的block，block里有一个size_t类型的参数，用来区分各个block使用。
```
 dispatch_queue_t serialQueue = dispatch_queue_create("com.example.serialQueue", DISPATCH_QUEUE_SERIAL);
 dispatch_apply(10, serialQueue, ^(size_t index) {
    NSLog(@"serialQueue %zu, %@", index, [NSThread currentThread]);
  });
  NSLog(@"test1");
```
```
[2510:77935] serialQueue 0, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 1, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 2, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 3, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 4, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 5, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 6, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 7, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 8, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] serialQueue 9, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:77935] test1

```
串行队列里只有一个线程，他会按顺序迭代执行block，并等到所有的block执行完后再执行后面的代码。
```
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
dispatch_apply(10, queue, ^(size_t index) {
    NSLog(@"queue %zu, %@", index, [NSThread currentThread]);
 });    
 NSLog(@"test");
```

```
[2510:78206] queue 4, <NSThread: 0x60000007d2c0>{number = 8, name = (null)}
[2510:78208] queue 6, <NSThread: 0x61800007d380>{number = 10, name = (null)}
[2510:78205] queue 2, <NSThread: 0x608000076380>{number = 7, name = (null)}
[2510:78207] queue 5, <NSThread: 0x610000262c00>{number = 9, name = (null)}
[2510:78016] queue 0, <NSThread: 0x618000071b80>{number = 5, name = (null)}
[2510:77935] queue 3, <NSThread: 0x608000070dc0>{number = 1, name = main}
[2510:78013] queue 1, <NSThread: 0x600000265e40>{number = 6, name = (null)}
[2510:78209] queue 7, <NSThread: 0x608000079cc0>{number = 11, name = (null)}
[2510:78206] queue 8, <NSThread: 0x60000007d2c0>{number = 8, name = (null)}
[2510:78208] queue 9, <NSThread: 0x61800007d380>{number = 10, name = (null)}
[2510:77935] test
```
在并发队列里，会根据需要生成必要的线程一步地执行block，`dispatch_apply`依然要等到所有block执行完后再执行后面的代码。
我们来看一下下面的代码
```
NSArray * array = @[@"0", @"1", @"2", @"3",@"4", @"5"];
dispatch_apply([array count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t index) {
    NSLog(@"index = %zu: %@", index , array[index]);
 });
```
这样可以简单地在并发队列里对所有元素执行block，不必一个个编写for循环。

由于`dispatch_apply`和`dispatch_sycn`函数相同，会等待处理执行结束，因此推荐在`dispatch_asycn`函数中非同步地执行`dispatch_apply`函数。
```
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
```

##Dispatch Semaphore
```
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray * array =  @[].mutableCopy;
    for (int i = 0; i < 100000; i++) {
        dispatch_async(queue, ^{
            [array addObject:[NSNumber numberWithInt:i]];
        });
    }
```
由于该代码使用Global Dispatch Queue 更新NSMutableArray对象，所以执行后由于内存错误导致应用程序异常结束的概率非常高。此时应使用Dispatch Semaphore，它可以被当做锁来使用，YYCache中的就使用了`dispatch_semaphore `处理磁盘缓存的线程安全[参考](http://blog.ibireme.com/2015/10/26/yycache/)。
Dispatch semaphore是持有计数的信号，该计数是多线程编程中的计数类型信号。所谓信号，类似于过马路时常用的手旗，可以通过时举起手旗，不可通过时放下手旗。而在Dispatch semaphore，使用计数来实现该功能。计数为0时等待，计数为1或大于1时，减去1而不等待。
通过` dispatch_semaphore_create(<#long value#>)`函数生成Dispatch Semaphore。参数表示计数的初始值，
```
dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

```
dispatch_semaphore_wait函数等待Dispatch Semaphore的计数值达到大于或等于1。当计数值大于等于1，或者在等待中计数值大于等于1时，对该计数进行减法并从dispatch_semaphore_wait函数返回，第二个参数是由dispatch_time_t类型值指定等待时间。上面代码表示永久等待。
dispatch_semaphore_wait函数返回为0时，可安全地执行需要进行排他控制的处理，该处理结束时通过dispatch_semaphore_signal函数将Dispatch Semaphore的计数值加1.

```
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

```

###使用信号量实现URLSession同步
NSUrlSession的方法全是异步的，要想实现同步的，也可以使用信号量来实现。
```
NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
dispatch_semaphore_t sem = dispatch_semaphore_create(0);
 NSURLSessionDataTask * data = [session dataTaskWithURL:[NSURL URLWithString:@"http://www.baidu.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"222222");
        dispatch_semaphore_signal(sem);

 }];
 [data resume];
 dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
 NSLog(@"333333");
```
由信号量于初始值是0，调用dispatch_semaphore_wait后信号量值会小于0，这时候dispatch_semaphore_wait会等待dispatch_semaphore_signal后才会返回。因此会先打印222222，之后才会打印333333

###dispatch_suspend / dispatch_resume
当追加大量处理到Dispatch Queue 时，在追加处理的过程中，有时希望不执行已追加的处理。例如盐酸结果被block截获时，一些处理会对这个演算结果造成影响。
在这种情况下，只要挂起Dispatch Queue即可，当可执行的时候再恢复。
dispatch_suspend函数挂起指定的Dispatch Queue。
` dispatch_suspend(queue);`
dispatch_resume函数恢复指定的Dispatch Queue。
 `dispatch_resume (queue);`
这些函数对已经执行的处理没有影响，挂起后，追加到Dispatch Queue中但还没有执行的处理在暂停执行，而恢复则会使这些处理能够继续执行。
###dispatch_once
dispatch_once函数是保证在应用程序中只执行一次指定处理的API。
```
+ (CustomModel *)shareInstance{
     static CustomModel * shateInstance = nil;
    static dispatch_once_t onceToken;
    NSLog(@"first == %ld",onceToken);
    dispatch_once(&onceToken, ^{
        shateInstance = [[CustomModel alloc] init];
    });
    NSLog(@"second == %ld",onceToken);
    NSLog(@"-----------------");
    return shateInstance;
}

```
使用dispatch_once函数，该源代码即使在多线程环境下执行，也可保证百分百安全。
dispatch_once函数的原型是`void _dispatch_once(dispatch_once_t *predicate, DISPATCH_NOESCAPE dispatch_block_t block)`,这个函数的作用是使得block在整个程序的生命周期中只执行一次，每次调用这块代码时通过predicate来检查，在这里**predicate必须严格的初始化为0**。
可以测试线面的输出：
```
 [CustomModel shareInstance];
 [CustomModel shareInstance];
 [CustomModel shareInstance];

```

```
[19923:1187470] first == 0
[19923:1187470] second == -1
[19923:1187470] -----------------
[19923:1187470] first == -1
[19923:1187470] second == -1
[19923:1187470] -----------------
[19923:1187470] first == -1
[19923:1187470] second == -1
[19923:1187470] -----------------
```
若onceToken被初始化为0，那么在调用dispatch_once函数时检测到其值为0，就执行block，执行完后onceToken减一。下次调用dispatch_once函数时检测到onceToken = -1，将不会执行block。
