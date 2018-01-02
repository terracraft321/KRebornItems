#include "WhiteSparks.as";
const f32 iidee = XORRandom(50);
void onInit(CBlob@ this)
{	
	f32 lifetimer = 0.0f;
	this.SetLight(true);
	this.getSprite().setRenderStyle(RenderStyle::light);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 100, 100, 255));
	this.Tag("dont deactivate");
	this.Tag("fire source");
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;
	this.server_SetHealth(XORRandom(120));
	//sprite.SetFacingLeft(false);
	sprite.SetZ(750);
	//this.getCurrentScript().tickFrequency = 24;

	this.set_u32("lifetime", 0);
	//this.server_SetTimeToDie(3);


}

void onTick(CBlob@ this)
{	
	if (this.getTeamNum() == 0)
	{
		this.SetLightColor(SColor(255, 0, 0, 255));
	}

	if (this.getTeamNum() == 1)
	{
		this.SetLightColor(SColor(255, 255, 0, 0));
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
	
	u32 lifetime = this.get_u32("lifetime");
	lifetime = (lifetime + 1);
	//print("" + lifetime);
	//this.SetLightRadius(100.0f-(lifetime/2));
	this.SetLightRadius(96.0f);
	if(lifetime > 1000)
	{
		this.server_Die(); 
	}
	this.set_u32("lifetime", lifetime);

	this.setAngleDegrees(this.getAngleDegrees()+1.0f);

}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this !is null && blob !is null)
	{
		CMap@ map = getMap();
		CBlob@[] portalBlobs;
		if (getBlobsByName("portal", @portalBlobs))
		{
			for (uint i = 0; i < portalBlobs.length; i++)
			{
				CBlob @b = portalBlobs[i];
				f32 aidii = this.getHealth();
				f32 iidee2 = b.getHealth();
				print("iidee: "+ aidii);
				if (blob.get_f32("teleported") != aidii && b !is null && b !is this && b.getName() == "portal" && b.getTeamNum() == this.getTeamNum())
				{
					blob.setPosition(b.getPosition());
					//this.server_Die();
					blob.set_f32("teleported", iidee2);
				}
			}
		}
	}
}