
void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.set_u32("ammunition", 50);
	this.set_u32("reloadgun", 35);
	this.set_u32("round", 1);
	this.getShape().getConsts().collideWhenAttached = true;
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
		reloadgun = 35;
	}

	bool pressed_a1 = point.isKeyJustPressed(key_action1);
	if (ammunition < 1)
	{
		this.server_Die();
	}
	if (pressed_a1 && round > 0 && ammunition > 0 && this.getTickSinceCreated() > 10)

	{	
    	this.getSprite().SetAnimation("default");
    	this.getSprite().SetAnimation("fire");

		//print(""+round);
		if (this !is null)
		{
			round = (round -1);
			Vec2f pos = this.getPosition();

			if (!getNet().isServer())
			{
				return;
			}

			CBlob@ bullet = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());
			CBlob@ bullet2 = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());
			CBlob@ bullet3 = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());
			CBlob@ bullet4 = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());
			CBlob@ bullet5 = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());

			Vec2f aim = (holder.getAimPos());
			Vec2f norm = aim - pos;
			norm.Normalize();

			ammunition = (ammunition-1);
			if (point !is null && holder !is null)
			{
				if (bullet !is null)
				{
					//this.getSprite().PlaySound("Shotgun.ogg");
					bullet.server_SetTimeToDie(0.5);
					//bullet.Tag("shotgun");
					CSprite@ sprite = this.getSprite();
					/*if (sprite !is null)
					{
						sprite.PlaySound("Shotgun.ogg");
					}*/
					bullet.SetDamageOwnerPlayer(holder.getPlayer());

					bullet.setVelocity(norm * (25.0f+XORRandom(4)));
					holder.AddForce(norm *(-180.0f));
					bullet.Tag("shotgun");
					
				}			
				if (bullet2 !is null )
				{
					bullet2.server_SetTimeToDie(0.5);
					bullet2.SetDamageOwnerPlayer(holder.getPlayer());

					norm = norm.RotateBy(XORRandom(4), Vec2f());
					bullet2.setVelocity(norm * (25.0f+XORRandom(4)));
					
				}			
				if (bullet3 !is null)
				{
					bullet3.server_SetTimeToDie(0.5);
					bullet3.SetDamageOwnerPlayer(holder.getPlayer());

					norm = norm.RotateBy(XORRandom(6), Vec2f());
					bullet3.setVelocity(norm * (25.0f+XORRandom(4)));
					
				}			
				if (bullet4 !is null)
				{
					bullet4.server_SetTimeToDie(0.5);
					bullet4.SetDamageOwnerPlayer(holder.getPlayer());

					norm = norm.RotateBy(XORRandom(-4), Vec2f());
					bullet4.setVelocity(norm * (25.0f+XORRandom(4)));
					
				}
				if (bullet5 !is null)
				{
					bullet5.server_SetTimeToDie(0.5);
					bullet5.SetDamageOwnerPlayer(holder.getPlayer());

					norm = norm.RotateBy(XORRandom(-6), Vec2f());
					bullet5.setVelocity(norm * (25.0f+XORRandom(4)));
					
				}
			}
		}
	}
	this.set_u32("round", round);
	this.set_u32("reloadgun", reloadgun);
	this.set_u32("ammunition", ammunition);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}
