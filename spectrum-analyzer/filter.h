#ifndef __FILTER_H__
#define __FILTER_H__

class Filter
{
public:
	Filter(float x, float y, char* name, float r, float g, float b);
	virtual ~Filter();

	virtual void Render(void);
	virtual bool PointerPress(int button, float x, float y);
	virtual void PointerMovement(float x, float y, float delta_x, float delta_y);
	virtual void PointerRelease(int button, float x, float y);
	virtual bool Update(float* bar_magnitudes, int num_bars);
	virtual float GetActivation();
	virtual char* GetName();

	virtual float Area();
	virtual bool HitTest(float x, float y);

protected:
	float m_x;
	float m_y;

	char* m_name;

	float m_red;
	float m_green;
	float m_blue;

	float m_width;
	float m_height;
	bool m_hover;
	bool m_grabbed_move;

	bool m_grabbed_up;
	bool m_grabbed_down;
	bool m_grabbed_right;
	bool m_grabbed_left;

	float m_activation;
	float m_previous_activation;
};

#endif
