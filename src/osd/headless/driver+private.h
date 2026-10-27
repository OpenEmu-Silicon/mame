#import "public/driver.h"

#include <cstdint>

class game_driver;

/// MAME 0.253+ keeps only the low 32 bits of a system's flags in game_driver::flags and
/// turns the rest into device emulation flags and features. Rebuild the full set of
/// MACHINE_* bits (as GameDriverOptions expects) from both.
std::uint64_t headless_game_driver_flags(game_driver const &driver);

@interface GameDriver (Private)

- (instancetype)initWithGameDriver:(game_driver const *)driver;

@end