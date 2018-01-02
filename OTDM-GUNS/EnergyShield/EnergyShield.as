
void onInit(CBlob@ this)
{	
	f32 lifetimer = 0.0f;
	this.SetLight(true);
	this.getSprite().setRenderStyle(RenderStyle::light);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 255, 255));
	AddIconToken("$forcefield on$", "ForceField.png", Vec2f(8, 8), 0);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(750);
	//this.getCurrentScript().tickFrequency = 24;

	this.set_u32("lifetime", 0);
	//this.server_SetTimeToDie(3);

}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.getTeamNum() != blob.getTeamNum())
	{
		return true;
	}

	else
	{
		return false;
	}
}
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onTick(CBlob@ this)
{	
	u32 lifetime = this.get_u32("lifetime");
	lifetime = (lifetime + 1);
	print("" + lifetime);
	//this.SetLightRadius(100.0f-(lifetime/2));
	this.SetLightRadius(96.0f);
	if(lifetime > 700)
	{
		this.server_Die(); 
	}
	this.set_u32("lifetime", lifetime);

	this.setAngleDegrees(this.getAngleDegrees()+1.0f);

}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	u32 lifetime = this.get_u32("lifetime");
	if (this !is null && blob !is null)
	{
		f32 xvel = blob.getVelocity().x;
		f32 yvel = blob.getVelocity().y;
		if (blob.getTeamNum() != this.getTeamNum() && blob !is null)
		{
			blob.setVelocity(Vec2f(xvel*-1.5f, yvel*-1.5f));

			if (blob.hasTag("projectile")&& blob !is null)
			{			
				lifetime = lifetime + 10;
				this.set_u32("lifetime", lifetime);
				blob.server_setTeamNum(246);
				blob.server_SetTimeToDie(0.8);
				CPlayer@ player = this.getDamageOwnerPlayer();
				if(player !is null)
				{
					blob.server_setTeamNum(player.getTeamNum());
					blob.SetDamageOwnerPlayer(player);
				}
				//print("" + blob.getDamageOwnerPlayer());
				blob.getSprite().setRenderStyle(RenderStyle::light);

				blob.SetDamageOwnerPlayer(player);
			}
			if (blob.getName() == "keg" && blob !is null)
			{
				blob.SendCommand(blob.getCommandID("activate"));
			}
		}
	}
}