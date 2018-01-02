namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}

void onInit(CBlob@ this)
{
	this.Tag("no falldamage");
	this.set_u32(Trampoline::TIMER, 0);
	this.set_u32("ammunition", 100);
	//this.Tag("super heavy weight");
	this.getShape().getConsts().collideWhenAttached = true;

	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
	this.getCurrentScript().runFlags |= Script::tick_attached;
	u32 firedtime = 0;
	this.addCommandID("shoot");
}
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shoot"))
	{
		this.getSprite().PlaySound("AKFire.ogg");
		if (getNet().isClient()&&!getNet().isServer())
		{
			print("Client4");
		}
		if (!getNet().isClient()&&getNet().isServer())
		{
			print("Server4");
		}
		if (getNet().isClient()&&getNet().isServer())
		{
			print("Both4");
		}

	}
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
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	angle -= 0;
	if (this.isFacingLeft())
	{
		this.setAngleDegrees((-angle)-180);
	}
	if (!this.isFacingLeft())
	{
		this.setAngleDegrees(-angle);
	}
	u32 firedtime = this.get_u32("firedtime");
	u32 ammunition = this.get_u32("ammunition");
	if(firedtime > 0)
	{
		firedtime = (firedtime - 1);
	}
	bool pressed_a1 = point.isKeyPressed(key_action1);
	if (ammunition < 1)
	{
		this.server_Die();
	}
	if (pressed_a1 && firedtime <= 0 && ammunition > 0 && this.getTickSinceCreated() > 10 )

	{		
		if (this !is null)
		{
			Vec2f pos = this.getPosition();
			//Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));

			//this.SendCommand(this.getCommandID("shoot"));
			if(getNet().isServer())
			{
				CBlob@ bullet = server_CreateBlob("bullet", this.getTeamNum(), this.getPosition());


				ammunition = (ammunition-1);
				if (bullet !is null && point !is null && holder !is null)
				{
					bullet.server_SetTimeToDie(0.6);
					CSprite@ sprite = this.getSprite();
					firedtime = 6;
					bullet.SetDamageOwnerPlayer(holder.getPlayer());
					if (point.isKeyPressed(key_down) && holder.isOnGround() && holder.getVelocity() == Vec2f(0, 0))
					{
						//this.getSprite().PlaySound("AKFire.ogg");
						Vec2f aim = holder.getAimPos();
						Vec2f norm = aim - pos;
						norm.Normalize();
						bullet.setVelocity(norm * ((29.0f+(XORRandom(1.0f)))));
						holder.AddForce(norm *(-0.0f));
						
					}
					else
					{			
						Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));
						Vec2f norm = aim - pos;
						norm.Normalize();
						bullet.setVelocity(norm * (25.0f+(XORRandom(5.0f))));
						holder.AddForce(norm *(-32.0f));
					}
				}

			}
		}
	}
	this.set_u32("firedtime", firedtime);
	this.set_u32("ammunition", ammunition);
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//cant bounce while held by something attached to something else
	//if (holder !is null && holder.isAttached()) return;
/*
	if (this.get_u32(Trampoline::TIMER) < getGameTime())
	{
		Vec2f velocity_old = blob.getOldVelocity();
		//if (velocity_old.Length() < 1.0f) return;

		float angle = this.getAngleDegrees();

		Vec2f direction = Vec2f(0.0f, -1.0f);
		direction.RotateBy(angle);
		/*
		float velocity_angle = direction.AngleWith(velocity_old);
		
		if (Maths::Abs(velocity_angle) > 90)
		{
			this.set_u32(Trampoline::TIMER, getGameTime() + Trampoline::COOLDOWN);

			Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);


			velocity.RotateBy(angle);

			//blob.setVelocity(velocity);

			}
		}
	}*/
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("no pickup");
}