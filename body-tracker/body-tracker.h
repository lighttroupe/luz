#include "utils.h"

#include <XnOpenNI.h>
#include <XnCodecIDs.h>
#include <XnCppWrapper.h>

#include "message-bus.h"

#define ADDRESS_BUFFER_SIZE (1000)

#define MAX_DEPTH (10000)

#define MAX_USERS_TRACKED (20)

//
// NOTE: initializing to 0 is proper for all fields
//
typedef struct {
	bool tracked;
	uint human_number;

	// Heaaaaaaaaaad, shoulders, knees and toes, knees and toes!
	TLimits3
		//limits_head, limits_torso,
		limits_left_shoulder, limits_left_elbow, limits_left_hand,
		limits_right_shoulder, limits_right_elbow, limits_right_hand,
		limits_left_hip, limits_left_knee, limits_left_foot,
		limits_right_hip, limits_right_knee, limits_right_foot;

	TLimits
	  limits_left_shoulder_angle, limits_right_shoulder_angle,
		limits_left_elbow_angle, limits_right_elbow_angle,
		limits_left_knee_angle, limits_right_knee_angle,
		limits_left_hip_angle, limits_right_hip_angle;
} THuman;

class BodyTracker
{
public:
	BodyTracker();
	virtual ~BodyTracker();

	void update();
	void draw();
	void send();

	//
	// Callbacks
	//
	void on_new_user(XnUserID user_id);
	void on_pose_detected(XnUserID user_id);
	void on_calibration_start(XnUserID user_id);
	void on_calibration_end(XnUserID user_id, bool success);
	void on_lost_user(XnUserID user_id);

	//
	// Drawing of OpenNI data
	//
	void openni_draw_texture(float top_left_x, float top_left_y, float bottom_right_x, float bottom_right_y);
	void openni_draw_depth_map(const xn::DepthMetaData& dmd, const xn::SceneMetaData& smd);
	bool openni_draw_limb(XnUserID player, XnSkeletonJoint eJoint1, XnSkeletonJoint eJoint2);
	void openni_draw_joint(XnUserID player, XnSkeletonJoint eJoint, float fSize);
	void openni_draw_rectangle(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY);
	void openni_draw_skeletons();

	uint get_max_humans() { return m_max_humans; }
	void set_max_humans(uint max_humans) { m_max_humans = (max_humans <= MAX_USERS_TRACKED) ? max_humans : MAX_USERS_TRACKED; }

	uint get_human_number_offset() { return m_human_number_offset; }
	void set_human_number_offset(uint human_number_offset) { m_human_number_offset = human_number_offset; }

	uint get_draw_depth_map() { return m_draw_depth_map; }
	void set_draw_depth_map(uint draw_depth_map) { m_draw_depth_map = draw_depth_map; }

	bool is_openni_initialized() { return m_openni_initialized; }

private:
	//
	// Human Number tracking
	//
	uint next_human_number();
	void set_human_number_for_user_id(XnUserID id, uint human_number);
	uint user_id_to_human_number(XnUserID user_id);
	XnUserID human_number_to_user_id(uint human_number);
	THuman* user_id_to_human(XnUserID user_id);
	void reassign_human_number(uint human_number);

	TLimits3 m_limits_stage;

	//
	// OpenNI
	//
	bool init_openni();

	xn::Context m_openni_context;
	xn::DepthGenerator m_openni_depth_generator;
	xn::UserGenerator m_openni_user_generator;

	//
	// OpenNI settings
	//
	XnChar m_pose_name[20];
	XnBool m_require_pose;
	XnBool m_draw_background;

	//
	// Depth Histogram
	//
	float m_depth_histogram[MAX_DEPTH];
	GLfloat m_depth_texcoords[8];

	uint m_max_humans;
	THuman m_humans[MAX_USERS_TRACKED];

	uint m_human_number_offset;

	bool m_openni_initialized;
	bool m_draw_depth_map;
};
