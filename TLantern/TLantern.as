// Lantern script

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$lantern on$", "TLantern.png", Vec2f(8, 8), 0);
	AddIconToken("$lantern off$", "TLantern.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	//this.SetLightColor(SColor(255, 255, 240, 171));
	if(this !is null)
	{
		switch(this.getTeamNum())
		{
			case 0:
				this.SetLightColor(SColor(255,44, 175, 222));
				break;
			case 1:
				this.SetLightColor(SColor(255, 213, 84, 63));
				break;
			case 2:
				this.SetLightColor(SColor(255, 157, 202, 34));
				break;
			case 3:
				this.SetLightColor(SColor(255, 211, 121, 224));
				break;
			case 4:
				this.SetLightColor(SColor(255, 254, 165, 61));
				break;
			case 5:
				this.SetLightColor(SColor(255, 46, 229, 162));
				break;
			case 6:
				this.SetLightColor(SColor(255, 95, 132, 236));
				break;
			default:
				this.SetLightColor(SColor(255, 255, 240, 171));
		}
	}

	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}
