#import <UIKit/UIKit.h>
#import <substrate.h>

// --- ΔΗΛΩΣΕΙΣ ΓΙΑ ΤΟΝ COMPILER (Για να μην βγάζει Error) ---
// Λέμε στον compiler ότι αυτά είναι κλάσεις που θα βρει μέσα στο παιχνίδι
@interface LocalPlayer : NSObject
- (void)swing;
- (int)getHunger;
- (void)startUsingItem;
- (void)setMotionY:(float)y;
- (float)getFallDistance;
@end

@interface Mob : NSObject
- (float)getSpeed;
@end

// --- DARKDEV SETTINGS ---
struct {
    bool killaura = false;
    bool fly = false;
    bool esp = false;
    bool speed = false;
} darkDev;

// --- GUI: DARKDEV MENU ---
@interface DarkDevGUI : UIView
@end

@implementation DarkDevGUI
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 10;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,30)];
        title.text = @"DARKDEV CLIENT"; 
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter; 
        title.backgroundColor = [UIColor redColor];
        [self addSubview:title];

        [self addTgl:@"KillAura" var:&darkDev.killaura y:40];
        [self addTgl:@"Fly" var:&darkDev.fly y:80];
        [self addTgl:@"Speed" var:&darkDev.speed y:120];
        [self addTgl:@"ESP" var:&darkDev.esp y:160];
    }
    return self;
}

- (void)addTgl:(NSString *)n var:(bool *)v y:(int)y {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10,y,100,30)];
    l.text = n; l.textColor = [UIColor whiteColor]; [self addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(140,y,0,0)];
    s.onTintColor = [UIColor redColor];
    [s addTarget:self action:@selector(sw:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(s, "p", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:s];
}

- (void)sw:(UISwitch *)s {
    bool *v = (bool *)[[objc_getAssociatedObject(s, "p") pointerValue] pointerValue];
    *v = s.on;
}
@end

static DarkDevGUI *menu;

// --- ΤΑ CHEATS (HOOKS) ---
// Χρησιμοποιούμε %hook με τις κλάσεις που δηλώσαμε παραπάνω
%hook LocalPlayer
- (void)tick {
    %orig;
    if (darkDev.killaura) { 
        [self swing]; 
        // Εδώ θα έμπαινε η επίθεση, αλλά για αρχή αρκεί το swing για test
    }
}
%end

%hook Mob
- (float)getSpeed { 
    float original = %orig;
    return darkDev.speed ? original * 2.5f : original; 
}
%end

// --- STARTUP ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        // Floating Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 150, 50, 50);
        btn.backgroundColor = [UIColor redColor];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"DD" forState:UIControlStateNormal];
        [btn addTarget:nil action:@selector(tglM) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];

        menu = [[DarkDevGUI alloc] initWithFrame:CGRectMake(50, 50, 200, 210)];
        menu.hidden = YES;
        [win addSubview:menu];
    });
}

// Global function για το κουμπί
void tglM() { 
    if(menu) menu.hidden = !menu.hidden; 
}
