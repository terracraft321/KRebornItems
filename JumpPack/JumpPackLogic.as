// TrampolineLogic.as

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}
void makeSmoke(Vec2f pos)
{

	ParticleAnimated("Splash2.png", Vec2f(pos.x-6.0f, pos.y), Vec2f(0.0f, 5.0f), 0.0f, 1.0f, 2, 0.1f, false);

	ParticleAnimated("Splash2.png", Vec2f(pos.x+6.0f, pos.y), Vec2f(0.0f, 5.0f), 0.0f, 1.0f, 2, 0.1f, false);

}
void onInit(CBlob@ this)
{
	this.getSprite().SetEmitSound("Jet.ogg");
	this.set_u32(Trampoline::TIMER, 0);
	//this.Tag("super heavy weight");
	this.getShape().getConsts().collideWhenAttached = true;

	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");
	this.getShape().SetRotationsAllowed(false);
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
	this.getCurrentScript().runFlags |= Script::tick_attached;
	u32 firedtime = 0;
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	//detached.getShape().SetGravityScale(1.0f);
}
void onTick(CBlob@ this)
{	
			
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if(holder is null)
	{
		this.getSprite().SetEmitSoundPaused(true);
		return;
	}
	//holder.getShape().SetGravityScale(0.3f);
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	if(!point.isKeyPressed(key_action2))
	{	
		holder.AddForce(Vec2f(0.0f, -15.0f));
	}	
	if(point.isKeyPressed(key_action2))
	{	
		holder.AddForce(Vec2f(0.0f, 15.0f));
	}
	if(point.isKeyPressed(key_action3))
	{	
		Vec2f pos = this.getPosition();
		Vec2f posy = Vec2f(this.getPosition().x, this.getPosition().y + 150.0f);
		CMap@ map = this.getMap();
		bool air = map.rayCastSolid(pos, posy, posy);

		this.getSprite().SetEmitSoundPaused(true);
		if (air)
		{
			holder.AddForce(Vec2f(0.0f, -22.0f));
			makeSmoke(pos);	
			if(holder !is null)
			{
				this.getSprite().SetEmitSoundPaused(false);
				return;
			}
		}
		else
		{

			this.getSprite().SetEmitSoundPaused(true);
		}

	}
	else
	{

		this.getSprite().SetEmitSoundPaused(true);
	}


}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}