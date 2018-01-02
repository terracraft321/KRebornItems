// Lantern script

void onInit(CBlob@ this)
{
	//this.getShape().SetGravityScale(-1.0);
	this.SetLight(false);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 200, 120));
	AddIconToken("$lantern on$", "Flashlight.png", Vec2f(16, 16), 0);
	AddIconToken("$lantern off$", "Flashlight.png", Vec2f(16, 16), 1);
	//this.server_setTeamNum(XORRandom(7));
	this.Tag("dont deactivate");
	this.Tag("fire source");
	bool on = false;
}

void onTick(CBlob@ this)
{
	bool on = this.get_bool("on");
	if (on)
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("nofire");
	}
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("fire");
	}

	if (this.isInInventory())
	{	
		this.server_Die();
		this.SetLight(false);
	}
	if (this.getTeamNum() == 0)
	{
		this.SetLightColor(SColor(255, 0, 100, 255));
	}

	if (this.getTeamNum() == 1)
	{
		this.SetLightColor(SColor(255, 255, 50, 0));
	}

	if (this.getTeamNum() == 2)
	{
		this.SetLightColor(SColor(255, 0, 255, 0));
	}

	if (this.getTeamNum() == 3)
	{
		this.SetLightColor(SColor(255, 255, 0, 255));
	}

	if (this.getTeamNum() == 4)
	{
		this.SetLightColor(SColor(255, 255, 255, 0));
	}

	if (this.getTeamNum() == 5)
	{
		this.SetLightColor(SColor(255, 0, 255, 225));
	}

	if (this.getTeamNum() == 6)
	{
		this.SetLightColor(SColor(150, 120, 0, 255));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		bool on = this.get_bool("on");
		if (on)
		{
			on = false;
		}

		else
		{
			on = true;
		}
		this.set_bool("on", on);
	}

}
