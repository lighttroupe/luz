#include "application.h"
#include "body-tracker.h"

#include <GL/gl.h>

#define STARTING_JOINT_BOUNDING_BOX_WIDTH (400.0)
#define DEFAULT_MAX_HUMANS (1)

#define BACKGROUND_COLOR 0.0, 0.0, 0.0, 0.0
#define UNINITIALIZED_BACKGROUND_COLOR 0.6, 0.1, 0.1, 0.0

#define NUM_HUMAN_COLORS (9)
static XnFloat HUMAN_COLORS[NUM_HUMAN_COLORS][4] = {
	{0.800, 0.800, 0.800, 1.0},	// no human number assigned

	{1.000, 0.000, 0.000, 0.5},
	{0.000, 1.000, 0.000, 0.5},
	{0.000, 0.000, 1.000, 0.5},
	{1.000, 1.000, 0.000, 0.5},

	{0.500, 0.000, 0.000, 1.0},
	{0.000, 0.500, 0.000, 1.0},
	{0.000, 0.000, 0.500, 1.0},
	{0.500, 0.500, 0.000, 1.0},

/*
	{0.960, 0.474, 0.000, 1.0},
	{0.563, 0.149, 0.630, 1.0},
	{0.866, 0.039, 0.039, 1.0},
	{0.450, 0.823, 0.086, 1.0},
	{0.929, 0.831, 0.000, 1.0},
	{0.447, 0.623, 0.811, 1.0},
	{0.203, 0.396, 0.643, 1.0},
	{0.936, 0.353, 0.353, 1.0}
*/
};

//
// OpenNI Callbacks forwarding to class
//
void XN_CALLBACK_TYPE callback_on_new_user(xn::UserGenerator& generator, XnUserID user_id, void* cookie)
{
	((BodyTracker*)cookie)->on_new_user(user_id);
}

void XN_CALLBACK_TYPE callback_on_pose_detected(xn::PoseDetectionCapability& capability, const XnChar* strPose, XnUserID user_id, void* cookie)
{
	((BodyTracker*)cookie)->on_pose_detected(user_id);
}

void XN_CALLBACK_TYPE callback_on_calibration_start(xn::SkeletonCapability& capability, XnUserID user_id, void* cookie)
{
	((BodyTracker*)cookie)->on_calibration_start(user_id);
}

void XN_CALLBACK_TYPE callback_on_calibration_end(xn::SkeletonCapability& capability, XnUserID user_id, XnBool success, void* cookie)
{
	((BodyTracker*)cookie)->on_calibration_end(user_id, success);
}

void XN_CALLBACK_TYPE callback_on_lost_user(xn::UserGenerator& generator, XnUserID user_id, void* cookie)
{
	((BodyTracker*)cookie)->on_lost_user(user_id);
}

//
// BodyTracker
//
BodyTracker::BodyTracker()
	: m_require_pose(false),
		m_draw_background(true),
		m_max_humans(DEFAULT_MAX_HUMANS),
		m_human_number_offset(0),
		m_openni_initialized(false),
		m_draw_depth_map(true)
{
	memset(m_pose_name, 0, sizeof(m_pose_name));
	memset(m_humans, 0, sizeof(m_humans));

m_draw_background = false;

	m_openni_initialized = init_openni();
}

bool BodyTracker::init_openni()
{
	XnCallbackHandle hUserCallbacks, hCalibrationCallbacks, hPoseCallbacks;
	XnStatus nRetVal = XN_STATUS_OK;

	nRetVal = m_openni_context.InitFromXmlFile(XML_PATH);
	if(nRetVal != XN_STATUS_OK) {
		printf("body-tracker: init from config file (%s) failed (error %d).\n", XML_PATH, nRetVal);
	}

	// Depth Generator
	nRetVal = m_openni_context.FindExistingNode(XN_NODE_TYPE_DEPTH, m_openni_depth_generator);

	// User Generator
	nRetVal = m_openni_context.FindExistingNode(XN_NODE_TYPE_USER, m_openni_user_generator);
	if(nRetVal != XN_STATUS_OK) {
		nRetVal = m_openni_user_generator.Create(m_openni_context);
	}

	// Check capabilities
	if(!m_openni_user_generator.IsCapabilitySupported(XN_CAPABILITY_SKELETON)) {
		printf("body-tracker: no Kinect found or incomplete OpenNI+NITE configuration, please see README file.\n");
		return false;
	}

	m_openni_user_generator.RegisterUserCallbacks(callback_on_new_user, callback_on_lost_user, this, hUserCallbacks);
	m_openni_user_generator.GetSkeletonCap().RegisterCalibrationCallbacks(callback_on_calibration_start, callback_on_calibration_end, this, hCalibrationCallbacks);

	if(m_openni_user_generator.GetSkeletonCap().NeedPoseForCalibration()) {
		m_require_pose = TRUE;
		if(!m_openni_user_generator.IsCapabilitySupported(XN_CAPABILITY_POSE_DETECTION)) {
			printf("body-tracker: user skeleton pose required, but not supported!\n");
			return false;
		}
		m_openni_user_generator.GetPoseDetectionCap().RegisterToPoseCallbacks(callback_on_pose_detected, NULL, this, hPoseCallbacks);
		m_openni_user_generator.GetSkeletonCap().GetCalibrationPose(m_pose_name);
	}

	m_openni_user_generator.GetSkeletonCap().SetSkeletonProfile(XN_SKEL_PROFILE_ALL);

	nRetVal = m_openni_context.StartGeneratingAll();

	return true;
}

//
// UserID => Human mapping
//
THuman* BodyTracker::user_id_to_human(XnUserID user_id)
{
	return &m_humans[user_id-1];
}

uint BodyTracker::user_id_to_human_number(XnUserID user_id)
{
	THuman* human = user_id_to_human(user_id);
	return(human ? human->human_number : 0);
}

XnUserID BodyTracker::human_number_to_user_id(uint human_number)
{
	for(int id=1 ; id <= MAX_USERS_TRACKED ; id++) {
		if(user_id_to_human_number(id) == human_number)
			return id;
	}
	return 0;
}

void BodyTracker::set_human_number_for_user_id(XnUserID id, uint human_number)
{
	THuman* human = user_id_to_human(id);
	if(human->human_number != 0) {		// TODO: and number of active humans is < max number
		reassign_human_number(human->human_number);
	}
	memset(human, 0, sizeof(THuman));
	human->human_number = human_number;
}

uint BodyTracker::next_human_number()
{
	// Look for free numbers, favoring low numbers
	for(int number=1 ; number <= get_max_humans() ; number++) {
		if(human_number_to_user_id(number) == 0) {
			return number;
		}
	}
	return 0;
}

void BodyTracker::reassign_human_number(uint human_number)
{
	XnUserID user_id_array[MAX_USERS_TRACKED];
	XnUInt16 num_users = MAX_USERS_TRACKED;
	m_openni_user_generator.GetUsers(user_id_array, num_users);		// NOTE: sets num_users to number of active users

	for(int i=0 ; i<num_users ; i++) {
		XnUserID user_id = user_id_array[i];
		if(m_openni_user_generator.GetSkeletonCap().IsTracking(user_id) && user_id_to_human_number(user_id) == 0) {
			printf("body-tracker: reassigning human %d to user %d\n", human_number, user_id);
			set_human_number_for_user_id(user_id, human_number);

			printf("Human %02d / Tracked = %d\n", human_number, 1);
			char address_buffer[ADDRESS_BUFFER_SIZE+1];
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Tracked", human_number);
			g_message_bus->send_int(address_buffer, 1);

			return;
		}
	}
}

//
// BodyTracker Callbacks
//
void BodyTracker::on_new_user(XnUserID user_id)
{
	printf("body-tracker: new user %d\n", user_id);

	if(m_require_pose) {
		m_openni_user_generator.GetPoseDetectionCap().StartPoseDetection(m_pose_name, user_id);
	}
	else {
		m_openni_user_generator.GetSkeletonCap().RequestCalibration(user_id, TRUE);
	}
}

void BodyTracker::on_pose_detected(XnUserID user_id)
{
	printf("body-tracker: pose detected for user %d\n", user_id);
	m_openni_user_generator.GetPoseDetectionCap().StopPoseDetection(user_id);
	m_openni_user_generator.GetSkeletonCap().RequestCalibration(user_id, TRUE);
}

void BodyTracker::on_calibration_start(XnUserID user_id)
{
	printf("body-tracker: calibration started for user %d\n", user_id);
}

void BodyTracker::on_calibration_end(XnUserID user_id, bool success)
{
	if(success) {
		uint human_number = next_human_number();

		if(human_number == 0) {
			printf("body-tracker: tracking user %d, awaiting free human number\n", user_id);
		}
		else {
			set_human_number_for_user_id(user_id, human_number);

			printf("body-tracker: calibration complete, start tracking user %d, human %d\n", user_id, human_number);

			// Send Tracked = 1
			printf("Human %02d / Tracked = %d\n", human_number, 1);
			char address_buffer[ADDRESS_BUFFER_SIZE+1];
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Tracked", human_number);
			g_message_bus->send_int(address_buffer, 1);
		}

		// Either way, keep track of them (might assign a human number later)
		m_openni_user_generator.GetSkeletonCap().StartTracking(user_id);
	}
	else {
		printf("body-tracker: calibration failed for user %d, retrying...\n", user_id);

		if(m_require_pose) {
			m_openni_user_generator.GetPoseDetectionCap().StartPoseDetection(m_pose_name, user_id);
		}
		else {
			m_openni_user_generator.GetSkeletonCap().RequestCalibration(user_id, TRUE);
		}
	}
}

void BodyTracker::on_lost_user(XnUserID user_id)
{
	uint human_number = user_id_to_human_number(user_id);
	printf("body-tracker: lost user %d, human %d\n", user_id, human_number);

	if(human_number > 0) {
		// Send Tracked = 0
		printf("Human %02d / Tracked = %d\n", human_number, 0);
		char address_buffer[ADDRESS_BUFFER_SIZE+1];
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Tracked", human_number);
		g_message_bus->send_int(address_buffer, 0);
	}

	set_human_number_for_user_id(user_id, 0);
}

//
// Update
//
void BodyTracker::update()
{
	if(!is_openni_initialized())
		return;

	// Read next available data
	m_openni_context.WaitAndUpdateAll();
}

//
// Draw
//
void BodyTracker::draw()
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	if(!is_openni_initialized()) {
		glClearColor(UNINITIALIZED_BACKGROUND_COLOR);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		return;
	}

	glClearColor(BACKGROUND_COLOR);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	xn::SceneMetaData sceneMD;
	xn::DepthMetaData depthMD;

	m_openni_depth_generator.GetMetaData(depthMD);
	glOrtho(0, depthMD.XRes(), depthMD.YRes(), 0, -1.0, 1.0);

	glDisable(GL_TEXTURE_2D);

	//
	// Depth Map
	//
	if(m_draw_depth_map) {
		m_openni_depth_generator.GetMetaData(depthMD);
		m_openni_user_generator.GetUserPixels(0, sceneMD);
		openni_draw_depth_map(depthMD, sceneMD);
	}
	//
	// Skeletons
	//
	openni_draw_skeletons();
}

//
// Drawing
//
void BodyTracker::openni_draw_rectangle(float top_left_x, float top_left_y, float bottom_right_x, float bottom_right_y)
{
	GLfloat verts[8] = {
		top_left_x, top_left_y,
		top_left_x, bottom_right_y,
		bottom_right_x, bottom_right_y,
		bottom_right_x, top_left_y
	};
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);

	glFlush();		// TODO: this is from boilerplate code, do we need it?
}

void BodyTracker::openni_draw_texture(float top_left_x, float top_left_y, float bottom_right_x, float bottom_right_y)
{
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, m_depth_texcoords);
	openni_draw_rectangle(top_left_x, top_left_y, bottom_right_x, bottom_right_y);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

void BodyTracker::openni_draw_joint(XnUserID user_id, XnSkeletonJoint eJoint, float fSize)
{
	XnSkeletonJointPosition joint;
	m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, eJoint, joint);

	if(joint.fConfidence < 0.5) {
		return;
	}

	XnPoint3D pt[1];
	pt[0] = joint.position;
	m_openni_depth_generator.ConvertRealWorldToProjective(2, pt, pt);
	draw_circle(pt[0].X, pt[0].Y, fSize);
}

bool BodyTracker::openni_draw_limb(XnUserID user_id, XnSkeletonJoint eJoint1, XnSkeletonJoint eJoint2)
{
	XnSkeletonJointPosition joint1, joint2;
	m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, eJoint1, joint1);
	m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, eJoint2, joint2);

	if(joint1.fConfidence < 0.5 || joint2.fConfidence < 0.5) {
		return false;
	}

	XnPoint3D pt[2];
	pt[0] = joint1.position;
	pt[1] = joint2.position;

	m_openni_depth_generator.ConvertRealWorldToProjective(2, pt, pt);
	glVertex3i(pt[0].X, pt[0].Y, 0);
	glVertex3i(pt[1].X, pt[1].Y, 0);
	return true;
}

void BodyTracker::openni_draw_depth_map(const xn::DepthMetaData& dmd, const xn::SceneMetaData& smd)
{
	static bool bInitialized = false;
	static GLuint depthTexID;
	static unsigned char* pDepthTexBuf;
	static int texWidth, texHeight;

	float topLeftX;
	float topLeftY;
	float bottomRightY;
	float bottomRightX;
	float texXpos;
	float texYpos;

	if(!bInitialized) {
		texWidth = get_closest_power_of_two(dmd.XRes());
		texHeight = get_closest_power_of_two(dmd.YRes());
		depthTexID = init_texture((void**)&pDepthTexBuf,texWidth, texHeight) ;

		bInitialized = true;

		topLeftX = dmd.XRes();
		topLeftY = 0;
		bottomRightY = dmd.YRes();
		bottomRightX = 0;
		texXpos =(float)dmd.XRes()/texWidth;
		texYpos  =(float)dmd.YRes()/texHeight;

		memset(m_depth_texcoords, 0, 8*sizeof(float));
		m_depth_texcoords[0] = texXpos, m_depth_texcoords[1] = texYpos, m_depth_texcoords[2] = texXpos, m_depth_texcoords[7] = texYpos;
	}

	unsigned int nDepthValue = 0;
	unsigned int nHistValue = 0;
	unsigned int nIndex = 0;
	unsigned int nX = 0;
	unsigned int nY = 0;
	unsigned int nNumberOfPoints = 0;
	XnUInt16 nXRes = dmd.XRes();
	XnUInt16 nYRes = dmd.YRes();

	unsigned char* pDestImage = pDepthTexBuf;

	const XnDepthPixel* pDepth = dmd.Data();
	const XnLabel* pLabels = smd.Data();

	// Calculate the accumulative histogram
	memset(m_depth_histogram, 0, MAX_DEPTH*sizeof(float));

	for(nY=0 ; nY<nYRes ; nY++) {
		for(nX=0 ; nX<nXRes ; nX++) {
			nDepthValue = *pDepth;

			if(nDepthValue != 0) {
				m_depth_histogram[nDepthValue]++;
				nNumberOfPoints++;
			}
			pDepth++;
		}
	}

	for(nIndex=1 ; nIndex<MAX_DEPTH ; nIndex++) {
		m_depth_histogram[nIndex] += m_depth_histogram[nIndex-1];
	}

	if(nNumberOfPoints > 0) {
		for(nIndex=1 ; nIndex<MAX_DEPTH ; nIndex++) {
			m_depth_histogram[nIndex] = (unsigned int)(256 * (1.0f - (m_depth_histogram[nIndex] / (float)nNumberOfPoints)));
		}
	}

	pDepth = dmd.Data();

	//
	// Create a texture map of humans in their colors
	//
	for(nY=0 ; nY<nYRes ; nY++) {
		for(nX=0 ; nX<nXRes ; nX++, nIndex++) {
			pDestImage[0] = 0;
			pDestImage[1] = 0;
			pDestImage[2] = 0;

			XnLabel user_id = *pLabels;

			if(user_id != 0) {
				nDepthValue = *pDepth;

				uint color_index = user_id_to_human_number(user_id);	// % NUM_HUMAN_COLORS;

				nHistValue = m_depth_histogram[nDepthValue];
				pDestImage[0] = nHistValue * HUMAN_COLORS[color_index][0];
				pDestImage[1] = nHistValue * HUMAN_COLORS[color_index][1];
				pDestImage[2] = nHistValue * HUMAN_COLORS[color_index][2];
			}
			else if(m_draw_background) {
				if(nDepthValue != 0) {
					nHistValue = m_depth_histogram[nDepthValue];
					pDestImage[0] = nHistValue;		// * HUMAN_COLORS[color_index][0];
					pDestImage[1] = nHistValue;		// * HUMAN_COLORS[color_index][1];
					pDestImage[2] = nHistValue;		// * HUMAN_COLORS[color_index][2];
				}
			}
			pDepth++;
			pLabels++;
			pDestImage += 3;
		}
		pDestImage += (texWidth - nXRes) * 3;
	}

	glBindTexture(GL_TEXTURE_2D, depthTexID);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, texWidth, texHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, pDepthTexBuf);

	// Display the OpenGL texture map
	//glColor4f(0.75, 0.75, 0.75, 1.0);
	//glColor4f(0.8, 1.0, 0.8, 1.0);

	glEnable(GL_TEXTURE_2D);
	openni_draw_texture(dmd.XRes(), dmd.YRes(), 0, 0);
	glDisable(GL_TEXTURE_2D);
}

void BodyTracker::openni_draw_skeletons()
{
	XnUserID user_id_array[MAX_USERS_TRACKED];
	XnUInt16 num_users = MAX_USERS_TRACKED;
	m_openni_user_generator.GetUsers(user_id_array, num_users);		// NOTE: sets num_users to number of active users

	for(int i=0 ; i<num_users ; i++) {
		XnUserID user_id = user_id_array[i];
		bool is_tracking = m_openni_user_generator.GetSkeletonCap().IsTracking(user_id);

		//
		// Print ID / status for this user
		//
		if(!is_tracking) {
			XnPoint3D center_of_mass;
			m_openni_user_generator.GetCoM(user_id, center_of_mass);
			m_openni_depth_generator.ConvertRealWorldToProjective(1, &center_of_mass, &center_of_mass);

			char label[50] = "";
			xnOSMemSet(label, 0, sizeof(label));
			if(m_openni_user_generator.GetSkeletonCap().IsCalibrating(user_id)) {
				sprintf(label, "%d - Calibrating...", user_id);
			}
			else {
				sprintf(label, "%d - Looking for pose...", user_id);
			}
			glColor4f(1.0,1.0,1.0,1.0);
			glRasterPos2i(center_of_mass.X, center_of_mass.Y - 50);
			draw_string(GLUT_BITMAP_TIMES_ROMAN_24, label);

			continue;		// Nothing more to draw for this user.
		}

		//
		// Choose color by human number
		//
		uint human_number = user_id_to_human_number(user_id);
		human_number += m_human_number_offset;
		glColor4f(HUMAN_COLORS[human_number][0], HUMAN_COLORS[human_number][1], HUMAN_COLORS[human_number][2], HUMAN_COLORS[human_number][3]);

		//
		// Draw Skeleton
		//
		glLineWidth(16);

		glBegin(GL_LINES);
			// Head & Shoulders (...)
			openni_draw_limb(user_id, XN_SKEL_HEAD, XN_SKEL_NECK);
			openni_draw_limb(user_id, XN_SKEL_NECK, XN_SKEL_LEFT_SHOULDER);
			openni_draw_limb(user_id, XN_SKEL_NECK, XN_SKEL_RIGHT_SHOULDER);

			// Left Arm
			openni_draw_limb(user_id, XN_SKEL_LEFT_SHOULDER, XN_SKEL_LEFT_ELBOW);
			openni_draw_limb(user_id, XN_SKEL_LEFT_ELBOW, XN_SKEL_LEFT_HAND);

			// Right Arm
			openni_draw_limb(user_id, XN_SKEL_RIGHT_SHOULDER, XN_SKEL_RIGHT_ELBOW);
			openni_draw_limb(user_id, XN_SKEL_RIGHT_ELBOW, XN_SKEL_RIGHT_HAND);

			// Cross Torso
			openni_draw_limb(user_id, XN_SKEL_LEFT_SHOULDER, XN_SKEL_TORSO);
			openni_draw_limb(user_id, XN_SKEL_RIGHT_SHOULDER, XN_SKEL_TORSO);
			openni_draw_limb(user_id, XN_SKEL_TORSO, XN_SKEL_LEFT_HIP);
			openni_draw_limb(user_id, XN_SKEL_TORSO, XN_SKEL_RIGHT_HIP);

			// Belt
			openni_draw_limb(user_id, XN_SKEL_LEFT_HIP, XN_SKEL_RIGHT_HIP);

			// Left Leg
			openni_draw_limb(user_id, XN_SKEL_LEFT_HIP, XN_SKEL_LEFT_KNEE);
			openni_draw_limb(user_id, XN_SKEL_LEFT_KNEE, XN_SKEL_LEFT_FOOT);

			// Right Leg
			openni_draw_limb(user_id, XN_SKEL_RIGHT_HIP, XN_SKEL_RIGHT_KNEE);
			openni_draw_limb(user_id, XN_SKEL_RIGHT_KNEE, XN_SKEL_RIGHT_FOOT);
		glEnd();

		//
		// Joint Dots
		//
		glColor4f(HUMAN_COLORS[human_number][0], HUMAN_COLORS[human_number][1], HUMAN_COLORS[human_number][2], 1.0);

		openni_draw_joint(user_id, XN_SKEL_LEFT_SHOULDER, 4.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_SHOULDER, 4.0);
		openni_draw_joint(user_id, XN_SKEL_LEFT_HIP, 4.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_HIP, 4.0);

		glColor4f(0.5 + HUMAN_COLORS[human_number][0], 0.5 + HUMAN_COLORS[human_number][1], 0.5 + HUMAN_COLORS[human_number][2], HUMAN_COLORS[human_number][3]);

		openni_draw_joint(user_id, XN_SKEL_HEAD, 7.0);
		openni_draw_joint(user_id, XN_SKEL_LEFT_ELBOW, 7.0);
		openni_draw_joint(user_id, XN_SKEL_LEFT_HAND, 7.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_ELBOW, 7.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_HAND, 7.0);
		openni_draw_joint(user_id, XN_SKEL_TORSO, 7.0);
		openni_draw_joint(user_id, XN_SKEL_LEFT_KNEE, 7.0);
		openni_draw_joint(user_id, XN_SKEL_LEFT_FOOT, 7.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_KNEE, 7.0);
		openni_draw_joint(user_id, XN_SKEL_RIGHT_FOOT, 7.0);
	}
}

//
// Send OSC
//
void BodyTracker::send()
{
	if(!is_openni_initialized())
		return;

	XnUserID user_id_array[MAX_USERS_TRACKED];
	XnUInt16 num_users = MAX_USERS_TRACKED;
	m_openni_user_generator.GetUsers(user_id_array, num_users);

	char address_buffer[ADDRESS_BUFFER_SIZE+1];

	for(int i=0 ; i<num_users ; i++) {
		XnUserID user_id = user_id_array[i];
		THuman* human = user_id_to_human(user_id);

		if(!m_openni_user_generator.GetSkeletonCap().IsTracking(user_id)) {
			continue;
		}

		uint human_number = user_id_to_human_number(user_id);
		human_number += m_human_number_offset;

		if(human_number == 0)
			continue;

		// HACK: Send Tracked = 1
		snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Tracked", human_number);
		g_message_bus->send_int(address_buffer, 1);

		XnSkeletonJointPosition joint, joint2, joint3;

		//
		// Get main pivot points
		//
		XnSkeletonJointPosition left_shoulder, right_shoulder;
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_SHOULDER, left_shoulder);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_SHOULDER, right_shoulder);

		XnSkeletonJointPosition left_hip, right_hip;
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_HIP, left_hip);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_HIP, right_hip);

		
		// Head (absolute value-- for head tracking)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_HEAD, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Head / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X, &m_limits_stage.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Head / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y, &m_limits_stage.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Head / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z, &m_limits_stage.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Torso (absolute value-- the user's general position)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_TORSO, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X, &m_limits_stage.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y, &m_limits_stage.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z, &m_limits_stage.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Left Elbow (relative to left shoulder)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_ELBOW, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Elbow / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - left_shoulder.position.X, &human->limits_left_elbow.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Elbow / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - left_shoulder.position.Y, &human->limits_left_elbow.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Elbow / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - left_shoulder.position.Z, &human->limits_left_elbow.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Left Hand (relative to left shoulder)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_HAND, joint);
		//printf("left hand: %f, %f, %f\n", joint.position.X, joint.position.Y, joint.position.Z);

		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Hand / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - left_shoulder.position.X, &human->limits_left_hand.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Hand / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - left_shoulder.position.Y, &human->limits_left_hand.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Hand / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - left_shoulder.position.Z, &human->limits_left_hand.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Right Elbow (relative to right shoulder)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_ELBOW, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Elbow / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - right_shoulder.position.X, &human->limits_right_elbow.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Elbow / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - right_shoulder.position.Y, &human->limits_right_elbow.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Elbow / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - right_shoulder.position.Z, &human->limits_right_elbow.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Right Hand (relative to right shoulder)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_HAND, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Hand / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - right_shoulder.position.X, &human->limits_right_hand.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Hand / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - right_shoulder.position.Y, &human->limits_right_hand.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Hand / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - right_shoulder.position.Z, &human->limits_right_hand.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Left Knee (relative to left hip)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_KNEE, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Knee / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - left_hip.position.X, &human->limits_left_knee.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Knee / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - left_hip.position.Y, &human->limits_left_knee.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Knee / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - left_hip.position.Z, &human->limits_left_knee.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Left Foot (relative to left hip)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_FOOT, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Foot / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - left_hip.position.X, &human->limits_left_foot.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Foot / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - left_hip.position.Y, &human->limits_left_foot.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Foot / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - left_hip.position.Z, &human->limits_left_foot.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Right Knee (relative to right hip)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_KNEE, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Knee / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - right_hip.position.X, &human->limits_right_knee.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Knee / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - right_hip.position.Y, &human->limits_right_knee.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Knee / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - right_hip.position.Z, &human->limits_right_knee.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		// Right Foot (relative to right hip)
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_FOOT, joint);
		if(joint.fConfidence > 0.5) {
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Foot / X", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.X - right_hip.position.X, &human->limits_right_foot.x, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Foot / Y", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Y - right_hip.position.Y, &human->limits_right_foot.y, STARTING_JOINT_BOUNDING_BOX_WIDTH));
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Foot / Z", human_number);
			g_message_bus->send_float(address_buffer, scale_and_expand_limits(joint.position.Z - right_hip.position.Z, &human->limits_right_foot.z, STARTING_JOINT_BOUNDING_BOX_WIDTH));
		}

		//
		// Shoulder Angles
		//
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_NECK, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_SHOULDER, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_ELBOW, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_left_shoulder_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Shoulder / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_NECK, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_SHOULDER, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_ELBOW, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_right_shoulder_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Shoulder / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}
		
		//
		// Hip Angles
		//
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_TORSO, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_HIP, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_KNEE, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_left_hip_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Hip / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_TORSO, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_HIP, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_KNEE, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_right_hip_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Hip / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		//
		// Elbow Angles
		//
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_SHOULDER, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_ELBOW, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_HAND, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_left_elbow_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Elbow / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_SHOULDER, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_ELBOW, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_HAND, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_right_elbow_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Elbow / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		//
		// Knee Angles
		//
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_HIP, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_KNEE, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_LEFT_FOOT, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_left_knee_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Left Knee / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}

		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_HIP, joint);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_KNEE, joint2);
		m_openni_user_generator.GetSkeletonCap().GetSkeletonJointPosition(user_id, XN_SKEL_RIGHT_FOOT, joint3);

		if(joint.fConfidence > 0.5 && joint2.fConfidence > 0.5 && joint3.fConfidence > 0.5) {
			float angle_zero_to_one = scale_and_expand_limits(calculate_angle(joint.position, joint2.position, joint3.position), &human->limits_right_knee_angle);
			snprintf(address_buffer, ADDRESS_BUFFER_SIZE, "Human %02d / Right Knee / Bend", human_number);
			g_message_bus->send_float(address_buffer, angle_zero_to_one);
		}
	}
}

BodyTracker::~BodyTracker()
{
}
