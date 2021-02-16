#define printf(x, ...) print(sprintf(x, __VA_ARGS__))
float g_width;
float g_height;
vector campos;
vector camang;
vector playerhead;

vector cursorpos;

entity box;
entity dummy;

float topdown_active;
float camera_yaw;
float camera_turnspeed;

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	box = spawn();
	dummy = spawn();
	setsize(box, '-800 -800 -16', '800 800 0');
	cursorpos = '160 120';
	registercvar("topdown_active", "0");
	registercvar("topdown_height", "520");
	topdown_active = 0;
	registercommand("+toggletopdown");
	registercommand("-toggletopdown");
	registercommand("+turncameraleft");
	registercommand("-turncameraleft");
	registercommand("+turncameraright");
	registercommand("-turncameraright");
	camera_yaw = 45;
	camera_turnspeed = 0;
	
	string a = getkeybind(K_MOUSE2);
	if (a == "")
		localcmd("bind mouse2 +toggletopdown\n");
}

float(string cmd) CSQC_ConsoleCommand =
{
	float argc = tokenize(cmd);
	switch (argv(0))
	{
	case "+toggletopdown":
		cvar_set("topdown_active", "0");
		return TRUE;
	case "-toggletopdown":
		cvar_set("topdown_active", "1");
		return TRUE;
	case "+turncameraleft":
		camera_turnspeed = 1;
		return TRUE;
	case "+turncameraright":
		camera_turnspeed = -1;
		return TRUE;
	case "-turncameraleft": 
	case "-turncameraright":
		camera_turnspeed = 0;
		return TRUE;
	}
	
	return FALSE;
}

void() CSQC_Input_Frame =
{
	if (!topdown_active) return;

	vector point = unproject([cursorpos.x, cursorpos.y, 2000]);
	other = box;
	traceline(campos, point, MOVE_OTHERONLY, dummy);
	vector angles = vectoangles(trace_endpos - playerhead);
	input_angles = [0, anglemod(angles.y), 0];
	if (input_angles.y < -180) input_angles.y += 360;
	if (input_angles.y > 180) input_angles.y -= 360;
	setproperty(VF_CL_VIEWANGLES, input_angles);
	makevectors([0, input_angles.y - camang.y]);
	
	float forward = input_movevalues.x;
	float right = input_movevalues.y;
	input_movevalues = v_forward * forward + v_right * -right;
}

void() handle_topdown =
{
	playerhead = campos;
	dynamiclight_add(playerhead, 128, '0.5 0.5 0.5');
	setorigin(box, campos - '0 0 32');
	
	float camdist = cvar("topdown_height");
	camang = [65, camera_yaw];
	makevectors(camang);
	campos -= v_forward * camdist;
	makevectors([0, camang.y]);
	campos += v_forward * (-cursorpos.y + g_height * 0.5) * 0.5;
	campos += v_right * (cursorpos.x - g_width * 0.5) * 0.5;
	// tracebox(playerhead, '-16 -16 0', '16 16 8', (campos + playerhead) * 0.5, 0, dummy);
	// if (trace_fraction < 1) // && trace_plane_normal.z > -0.3)
	// tracebox(playerhead, '-12 -12 0', '12 12 2', playerhead + [0, 0, camdist], 0, dummy);
	traceline(playerhead, playerhead + [0, 0, camdist * 0.5], 0, dummy);
	if (trace_fraction < 1)
		setproperty(VF_MINDIST, camdist - (camdist * 0.5 * trace_fraction));
	else
		setproperty(VF_MINDIST, camdist * 0.5);
	setproperty(VF_ORIGIN, campos);
	setproperty(VF_ANGLES, camang);
	
	setproperty(VF_MAXDIST, camdist + 600);
	setproperty(VF_AFOV, 50);
	
	camera_yaw = anglemod(camera_yaw + camera_turnspeed * frametime * 100);
}

void() activate_topdown =
{
	cvar_set("r_novis", "1");
	cvar_set("chase_active", "1");
	cvar_set("chase_back", "0");
	cvar_set("chase_up", "0");
	cvar_set("sv_aim", "0");
	cvar_set("gl_clear", "8");
	cvar_set("v_cshift_slime", "0 25 5 0");
}

void() deactivate_topdown =
{
	cvar_set("r_novis", "0");
	cvar_set("chase_active", "0");
	cvar_set("sv_aim", "2");
	cvar_set("v_cshift_slime", "0 25 5 128");
}

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	clearscene();

	g_width = vwidth;
	g_height = vheight;
	
	campos = getproperty(VF_ORIGIN);
	camang = getproperty(VF_ANGLES);
	
	float mask = MASK_ENGINE;
	
	if (topdown_active != cvar("topdown_active"))
	{
		topdown_active = cvar("topdown_active");
		if (topdown_active)
			activate_topdown();
		else
			deactivate_topdown();
	}
	
	if (topdown_active)
	{
		handle_topdown();
		
	}
	else
	{
		mask |= MASK_VIEWMODEL;
		setproperty(VF_DRAWCROSSHAIR, TRUE);
		cvar_set("r_novis", "0");
	}	
	
	/*
	vector realsize = getproperty(VF_SCREENPSIZE);
	float fac = 240 / realsize_y;
	cvar_set("r_renderscale", ftos(-fac));
	cvar_set("vid_conautoscale", ftos(1/fac));
	*/

	setproperty(VF_DRAWENGINESBAR, TRUE);
	addentities(mask);
	renderscene();
	
	if (topdown_active)
		drawstring([rint(cursorpos.x), rint(cursorpos.y)] - '4 4 0', "+", '8 8 0', '1 1 1', 1, 0);
}

float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch (evtype)
	{
	case IE_MOUSEDELTA:
		if (topdown_active)
		{
			cursorpos += [scanx, chary] * cvar("sensitivity") * 0.5;
			cursorpos.x = bound(0, cursorpos.x, g_width);
			cursorpos.y = bound(0, cursorpos.y, g_height);
			return TRUE;
		}
		break;
	default: break;
	}
	return FALSE;
}