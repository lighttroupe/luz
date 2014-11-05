# Defaults
MESSAGE_BUS_IP			= "255.255.255.255"		# Broadcast address
MESSAGE_BUS_PORT		= 10007								# LOOOZ ! :D

SETTINGS_DIRECTORY	= '.luz'
SETTINGS_FILENAME		= 'settings.yaml'

# Radians
RADIANS_PER_CIRCLE	= Math::PI * 2.0
RADIANS_UP					= -Math::PI / 2.0
RADIANS_RIGHT				= 0.0
RADIANS_DOWN				= Math::PI / 2.0
RADIANS_LEFT				= Math::PI

# Degrees
DEGREES_PER_CIRCLE	= 360.0
RADIANS_TO_DEGREES	= (360.0 / RADIANS_PER_CIRCLE)
FUZZY_TO_DEGREES		= -360.0							# multiply to produce 0 = up, 0.25 = right, etc.
