// Detonator script

void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$detonator on$", "Detonator.png", Vec2f(8, 8), 0);
	AddIconToken("$detonator off$", "Detonator.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("specialshot");
	this.getCurrentScript().runFlags |= Script::tick_inwater;
	this.getCurrentScript().tickFrequency = 24;
}

/*void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
}*/
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
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
	//Vec2f randpos = XORRandom(10)
	if (cmd == this.getCommandID("activate"))
	{	

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
		//this.server_Die();	
		CBlob@[] blobsInRadius;
		if (holder !is null && this.getMap().getBlobsInRadius(this.getPosition(), 1024.0f, @blobsInRadius))
		{
		if (holder.getHealth() > holder.getInitialHealth()) holder.server_SetHealth(holder.getInitialHealth());
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @blob = blobsInRadius[i];
				CSprite@ sprite = blob.getSprite();
				if (blob.getName() == "mine" && blob.get_u32("detachtime") == 0 && blob.getTeamNum() == this.getTeamNum() && blob.getDamageOwnerPlayer() is holder.getPlayer())
				{	
					blob.Tag("exploding");
					blob.Sync("exploding", true);

					blob.server_SetHealth(-1.0f);
					blob.server_Die();
				}
			}
		}
		//Light(this, !this.isLight());/*
		/*CBlob@ blob = server_CreateBlob("knight", this.getTeamNum(), Vec2f(this.getPosition().x -20 +XORRandom(40), this.getPosition().y -XORRandom(20)));
		CBlob@ blob2 = server_CreateBlob("knight", this.getTeamNum(), Vec2f(this.getPosition().x -20 +XORRandom(40), this.getPosition().y -XORRandom(20)));
		CBlob@ blob3 = server_CreateBlob("knight", this.getTeamNum(), Vec2f(this.getPosition().x -20 +XORRandom(40), this.getPosition().y -XORRandom(20)));
		CSprite@ s1 = blob.getSprite();
		s1.setRenderStyle(RenderStyle::normal);
		blob2.getSprite().setRenderStyle(RenderStyle::normal);
		blob3.getSprite().setRenderStyle(RenderStyle::normal);
		s1.setRenderStyle(RenderStyle::light);
		blob2.getSprite().setRenderStyle(RenderStyle::light);
		blob3.getSprite().setRenderStyle(RenderStyle::light);

		blob.server_SetTimeToDie(7+XORRandom(6));
		blob2.server_SetTimeToDie(7+XORRandom(6));
		blob3.server_SetTimeToDie(7+XORRandom(6));*/
	}

}
