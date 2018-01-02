
void onInit(CBlob@ this)
{	
	f32 lifetimer = 0.0f;
	this.SetLight(true);
	this.getSprite().setRenderStyle(RenderStyle::light);
	this.SetLightRadius(200.0f);
	this.SetLightColor(SColor(255, 255, 50, 50));
	this.Tag("dont deactivate");
	this.Tag("fire source");
	CShape@ shape = this.getShape();
	shape.SetStatic(true);
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(750);
	//this.getCurrentScript().tickFrequency = 24;

	this.set_u32("lifetime", 20);
	//this.server_SetTimeToDie(3);

}

void onTick(CBlob@ this)
{	
	u32 lifetime = this.get_u32("lifetime");
	lifetime = (lifetime + 1);
	//print("" + lifetime);
	this.SetLightRadius(lifetime*3);
	Vec2f xpos = Vec2f(this.getPosition().x, 0);
	Vec2f xpos2 = Vec2f(this.getPosition().x+16+XORRandom(48), 0);
	Vec2f xpos3 = Vec2f(this.getPosition().x-16-XORRandom(48), 0);
	this.SetLightRadius(96.0f);
	if(lifetime > 70 && lifetime < 75)
	{	
		if (!getNet().isServer())
		{
			return;
		}
		
		CBlob@ blob = server_CreateBlob("rocket", this.getTeamNum(), xpos);
		if (blob !is null)
		{		

			blob.setVelocity(Vec2f(0, 15));
			blob.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
			lifetime = 75;

		}
	}	
	if(lifetime > 90 && lifetime < 95)
	{	
		if (!getNet().isServer())
		{
			return;
		}
		CBlob@ blob2 = server_CreateBlob("rocket", this.getTeamNum(), xpos2);
		if (blob2 !is null)
		{		

			blob2.setVelocity(Vec2f(0, 15));
			blob2.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
			lifetime = 95;
		}
	}	
	if(lifetime > 110)
	{	
		CBlob@ blob3 = server_CreateBlob("rocket", this.getTeamNum(), xpos3);
		if (blob3 !is null)
		{		

			blob3.setVelocity(Vec2f(0, 15));
			blob3.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
			lifetime = 95;
		}

		this.server_Die();
	}
	this.set_u32("lifetime", lifetime);

	this.setAngleDegrees(this.getAngleDegrees()+4.0f);


}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{/*
	if (this !is null && blob !is null)
	{
		CMap@ map = getMap();
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(this.getPosition(), 560.0f, @blobsInRadius ))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (blob.get_u8("teleported") != this.getTeamNum() && b !is null && b.getName() == "portal" && this.getTeamNum() != b.getTeamNum())
				{
					blob.setPosition(b.getPosition());
					//this.server_Die();
					blob.set_u8("teleported", b.getTeamNum());
				}
			}
		}
	}*/
}