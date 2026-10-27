#import "driver+private.h"
#import "DriverList+Private.h"
#import <emu.h>
#import "../../frontend/mame/infoxml.h"

OE_STATIC_ASSERT(GameDriverMachineNoCocktail == MACHINE_NO_COCKTAIL);
OE_STATIC_ASSERT(GameDriverMachineIsBiosRoot == MACHINE_IS_BIOS_ROOT);
OE_STATIC_ASSERT(GameDriverMachineRequiresArtwork == MACHINE_REQUIRES_ARTWORK);
OE_STATIC_ASSERT(GameDriverMachineUnofficial == MACHINE_UNOFFICIAL);
OE_STATIC_ASSERT(GameDriverMachineNoSoundHw == MACHINE_NO_SOUND_HW);
OE_STATIC_ASSERT(GameDriverMachineMechanical == MACHINE_MECHANICAL);
OE_STATIC_ASSERT(GameDriverMachineIsIncomplete == MACHINE_IS_INCOMPLETE);
OE_STATIC_ASSERT(GameDriverMachineNotWorking == MACHINE_NOT_WORKING);
OE_STATIC_ASSERT(GameDriverMachineSupportsSave == MACHINE_SUPPORTS_SAVE);
OE_STATIC_ASSERT(GameDriverMachineUnemulatedProtection == MACHINE_UNEMULATED_PROTECTION);
OE_STATIC_ASSERT(GameDriverMachineWrongColors == MACHINE_WRONG_COLORS);
OE_STATIC_ASSERT(GameDriverMachineImperfectColors == MACHINE_IMPERFECT_COLORS);
OE_STATIC_ASSERT(GameDriverMachineImperfectGraphics == MACHINE_IMPERFECT_GRAPHICS);
OE_STATIC_ASSERT(GameDriverMachineNoSound == MACHINE_NO_SOUND);
OE_STATIC_ASSERT(GameDriverMachineImperfectSound == MACHINE_IMPERFECT_SOUND);
OE_STATIC_ASSERT(GameDriverMachineImperfectControls == MACHINE_IMPERFECT_CONTROLS);
OE_STATIC_ASSERT(GameDriverMachineNoDeviceMicrophone == MACHINE_NODEVICE_MICROPHONE);
OE_STATIC_ASSERT(GameDriverMachineNoDevicePrinter == MACHINE_NODEVICE_PRINTER);
OE_STATIC_ASSERT(GameDriverMachineNoDeviceLan == MACHINE_NODEVICE_LAN);
OE_STATIC_ASSERT(GameDriverMachineImperfectTiming == MACHINE_IMPERFECT_TIMING);

@implementation GameDriver {
	game_driver const *_driver;
	NSString *_name;
	NSString *_shortName;
	NSString *_fullName;
	NSString *_parent;
}

- (instancetype)initWithGameDriver:(game_driver const *)driver
{
	if ((self = [super init]))
	{
		_driver = driver;
	}
	return self;
}

- (NSString *)name
{
	return _name ?: (_name = NSSTRING_NO_COPY(_driver->name));
}

- (NSString *)shortName
{
	return _shortName ?: (_shortName = NSSTRING_NO_COPY(_driver->type.shortname()));
}

- (NSString *)fullName
{
	return _fullName ?: (_fullName = NSSTRING_NO_COPY(_driver->type.fullname()));
}

- (NSString * __nullable)parent
{
	if (_driver->parent == nullptr) return nil;

	return _parent ?: (_parent = NSSTRING_NO_COPY(_driver->parent));
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@)", self.fullName, self.name];
}

- (GameDriverOptions)flags
{
	return static_cast<GameDriverOptions>(_driver->flags);
}

- (void)dealloc
{
	NSLog(@"%@: dealloc", NSStringFromClass(self.class));
}

@end

#import "drivenum.h"

static GameDriver * __strong * s_drivers_sorted;

@implementation DriverList {
	CFArrayRef _items;
}

+ (DriverList *)shared
{
	static DriverList *obj;

	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_drivers_sorted = static_cast<GameDriver * __strong *>(calloc(driver_list::total(), sizeof(GameDriver *)));
		for (size_t i = 0; i < driver_list::total(); i++)
		{
			s_drivers_sorted[i] = [[GameDriver alloc] initWithGameDriver:&driver_list::driver(i)];
		}

		obj = [DriverList new];
		obj->_items = CFArrayCreate(kCFAllocatorDefault, (const void * *)(void *)s_drivers_sorted, static_cast<CFIndex>(driver_list::total()), &kCFTypeArrayCallBacks);
	});

	return obj;
}

- (NSArray<GameDriver *> *)allDrivers
{
	return (__bridge NSArray *)_items;
}

- (GameDriver *)findWithName:(NSString *)name
{
	auto index = driver_list::find(name.UTF8String);
	if (index == -1) {
		return nil;
	}

	return s_drivers_sorted[index];
}

@end
