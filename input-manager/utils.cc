float clamp_float(float value, float min, float max)
{
	return ((value >= max) ? max : ((value <= min) ? min : value));
}

