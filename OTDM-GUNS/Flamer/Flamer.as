namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}
void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Inferno.ogg");
	sprite.SetEmitSoundPaused(true);

	this.Tag("no falldamage");
	this.Tag("medium weight");
	this.set_u32(Trampoline::TIMER, 0);
	this.set_u32("ammunition", 250);
	this.set_u32("reloadgun", 4);
	this.set_u32("round", 1);
	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
	this.getCurrentScript().runFlags |= Script::tick_attached;

}

void onTick(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	if(holder is null) return;

	if (holder.getHealth() > holder.getInitialHealth()) holder.server_SetHealth(holder.getInitialHealth());
	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();
	angle -= 0;
	if (this.isFacingLeft())
	{
		this.setAngleDegrees((-angle)-180);
	}
	if (!this.isFacingLeft())
	{
		this.setAngleDegrees(-angle);
	}

	u32 round = this.get_u32("round");
	u32 ammunition = this.get_u32("ammunition");
	u32 reloadgun = this.get_u32("reloadgun");

	if(reloadgun > 0 && round <= 0)
	{
		reloadgun = (reloadgun - 1);
	}	

	if(reloadgun <= 0&& round <= 0)
	{
		round = 1;
		reloadgun = 4;
	}

	bool pressed_a1 = point.isKeyPressed(key_action1);
	if (ammunition < 1)
	{
		this.server_Die();
	}
	
	if (!pressed_a1 || holder is null || point is null)
	{
		this.getSprite().SetEmitSoundPaused(true);

		bool pressed_a1 = false;
	}

	if (pressed_a1 && round > 0 && ammunition > 0)

	{	
		this.getSprite().SetEmitSoundPaused(false);
    	this.getSprite().SetAnimation("default");
    	this.getSprite().SetAnimation("fire");

		//print(""+round);
		if (this !is null)
		{
			round = (round -1);
			Vec2f pos = this.getPosition();
			//Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));
			Vec2f aim2 = (holder.getAimPos());
			Vec2f norm2 = aim2 - pos;
			norm2.Normalize();
			if (!getNet().isServer())
			{
				return;
			}
			CBlob@ bullet = server_CreateBlob("flame", this.getTeamNum(), Vec2f(this.getPosition()+(norm2*14)));
			CBlob@ bullet2 = server_CreateBlob("flame", this.getTeamNum(), Vec2f(this.getPosition()+(norm2*14)));
			CBlob@ bullet3 = server_CreateBlob("flame", this.getTeamNum(), Vec2f(this.getPosition()+(norm2*14)));
			CBlob@ bullet4 = server_CreateBlob("flame", this.getTeamNum(), Vec2f(this.getPosition()+(norm2*14)));
			CBlob@ bullet5 = server_CreateBlob("flame", this.getTeamNum(), Vec2f(this.getPosition()+(norm2*14)));

			ammunition = (ammunition-1);
			if (bullet !is null && point !is null && holder !is null)
			{
				bullet.server_SetTimeToDie(1.5);
				CSprite@ sprite = this.getSprite();
				if (sprite !is null)
				{
					//print("yees");
					//sprite.PlaySound("Shotgun.ogg");
				}
				bullet.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				bullet.setVelocity(norm * (4.0f+XORRandom(3)));
				//holder.AddForce(norm *(-180.0f));
				bullet.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet2 !is null && point !is null && holder !is null)
			{
				bullet2.server_SetTimeToDie(1.5);
				bullet2.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(4), Vec2f());
				bullet2.setVelocity(norm * (4.0f+XORRandom(3)));
				bullet2.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet3 !is null && point !is null && holder !is null)
			{
				bullet3.server_SetTimeToDie(1.5);
				bullet3.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(6), Vec2f());
				bullet3.setVelocity(norm * (4.0f+XORRandom(3)));
				bullet3.setAngleDegrees(XORRandom(360));
				
			}			
			if (bullet4 !is null && point !is null && holder !is null)
			{
				bullet4.server_SetTimeToDie(1.5);
				bullet4.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(-4), Vec2f());
				bullet4.setVelocity(norm * (4.0f+XORRandom(3)));
				bullet4.setAngleDegrees(XORRandom(360));
				
			}
			if (bullet5 !is null && point !is null && holder !is null)
			{
				bullet5.server_SetTimeToDie(1.5);
				bullet5.SetDamageOwnerPlayer(holder.getPlayer());
				Vec2f aim = (holder.getAimPos());
				Vec2f norm = aim - pos;
				norm.Normalize();
				norm = norm.RotateBy(XORRandom(-6), Vec2f());
				bullet5.setVelocity(norm * (4.0f+XORRandom(3)));
				bullet5.setAngleDegrees(XORRandom(360));
				
			}
		}
	}
	this.set_u32("round", round);
	this.set_u32("reloadgun", reloadgun);
	this.set_u32("ammunition", ammunition);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}