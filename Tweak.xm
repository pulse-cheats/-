#import <UIKit/UIKit.h>
#import <substrate.h>

// --- DARKDEV SDK DECLARATIONS ---
class Entity;
class LocalPlayer {
public:
    void swing();
    void attack(Entity*);
    void setMotionY(float);
    float getFallDistance();
    int getHunger();
    void startUsingItem();
};

// --- SETTINGS STORAGE ---
struct {
    bool killaura = false;
    bool fly = false;
    bool freecam = false;
    bool esp = false;
    bool spawnerTracer = false;
    bool storageTracer = false;
    bool speed = false;
    bool autocrystal = false;
    bool autoanchor = false;
    bool autototem = false;
    bool criticals = false;
    bool autoeat = false;
} darkDev;

// --- GUI: DARKDEV MENU ---
@interface DarkDevGUI : UIView
@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation DarkDevGUI
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.95];
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 15;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,40)];
        title.text = @"DARKDEV CLIENT v1.0"; 
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter; 
        title.backgroundColor = [UIColor redColor];
        [self addSubview:title];

        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, frame.size.width, frame.size.height-40)];
        [self addSubview:self.scroll];

        int y = 10;
        [self addTgl:@"KillAura" var:&darkDev.killaura y:&y];
        [self addTgl:@"Flight" var:&darkDev.fly y:&y];
        [self addTgl:@"Speed" var:&darkDev.speed y:&y];
        [self addTgl:@"Player ESP" var:&darkDev.esp y:&y];
        [self addTgl:@"Spawner Tracer" var:&darkDev.spawnerTracer y:&y];
        [self addTgl:@"Storage Tracer" var:&darkDev.storageTracer y:&y];
        [self addTgl:@"Auto Totem" var:&darkDev.autototem y:&y];
        [self addTgl:@"Auto Crystal" var:&darkDev.autocrystal y:&y];
        [self addTgl:@"Auto Anchor" var:&darkDev.autoanchor y:&y];
        [self addTgl:@"Criticals" var:&darkDev.criticals y:&y];
        [self addTgl:@"Auto Eat" var:&darkDev.autoeat y:&y];
        [self addTgl:@"FreeCam" var:&darkDev.freecam y:&y];

        self.scroll.contentSize = CGSizeMake(frame.size.width, y + 20);
    }
    return self;
}

- (void)addTgl:(NSString *)n var:(bool *)v y:(int *)y {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15,*y,130,30)];
    l.text = n; l.textColor = [UIColor whiteColor]; [self.scroll addSubview:l];
    UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(150,*y,0,0)];
    s.onTintColor = [UIColor redColor];
    [s addTarget:self action:@selector(sw:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(s, "p", [NSValue valueWithPointer:v], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.scroll addSubview:s];
    *y += 45;
}

- (void)sw:(UISwitch *)s {
    bool *v = (bool *)[[objc_getAssociatedObject(s, "p") pointerValue] pointerValue];
    *v = s.on;
}
@end

static DarkDevGUI *menu;

// --- HOOKS SECTION ---
void (*old_tick)(LocalPlayer*);
void new_tick(LocalPlayer* self) {
    if (darkDev.killaura) { self->swing(); }
    if (darkDev.criticals && self->getFallDistance() == 0.0f) self->setMotionY(0.12f);
    if (darkDev.autoeat && self->getHunger() < 16) self->startUsingItem();
    old_tick(self);
}

// --- INITIALIZATION ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 100, 60, 60);
        btn.backgroundColor = [UIColor redColor];
        btn.layer.cornerRadius = 30;
        [btn setTitle:@"Dark" forState:UIControlStateNormal];
        [btn addTarget:nil action:@selector(tglM) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];

        menu = [[DarkDevGUI alloc] initWithFrame:CGRectMake(win.frame.size.width/2-110, win.frame.size.height/2-150, 220, 300)];
        menu.hidden = YES;
        [win addSubview:menu];
    });

    MSHookFunction(NULL, (void *)&new_tick, (void **)&old_tick);
}

void tglM() { if(menu) menu.hidden = !menu.hidden; }
