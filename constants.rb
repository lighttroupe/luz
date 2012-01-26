# Time constants
SECONDS_PER_MINUTE	= 60
SECONDS_PER_HOUR		= 3600

# Radian constants
RADIANS_PER_CIRCLE	= Math::PI * 2.0
RADIANS_UP					= -Math::PI / 2.0
RADIANS_RIGHT				= 0.0
RADIANS_DOWN				= Math::PI / 2.0
RADIANS_LEFT				= Math::PI

# Degree constants
DEGREES_PER_CIRCLE	= 360.0

RADIANS_TO_DEGREES	= (360.0 / RADIANS_PER_CIRCLE)
FUZZY_TO_DEGREES		= -360.0				# multiply to produce 0 = up, 0.25 = right, etc.

#MESSAGE_BUS_IP			= "225.4.5.6"		# Multicast address (http://onestepback.org/index.cgi/Tech/Ruby/MulticastingInRuby.red)

MESSAGE_BUS_IP			= "255.255.255.255"		# Broadcast address
MESSAGE_BUS_PORT		= 10007					# LOOOZ ! :D

SETTINGS_DIRECTORY = '.luz'
SETTINGS_FILENAME = 'settings.yaml'
