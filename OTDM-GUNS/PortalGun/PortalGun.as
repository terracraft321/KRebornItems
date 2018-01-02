// TrampolineLogic.as

namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}
void onInit(CBlob@ this)
{
	this.set_u32(Trampoline::TIMER, 0);
	//this.Tag("super heavy weight");
	this.getShape().getConsts().collideWhenAttached = true;

	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");
	this.Tag("no falldamage");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action1);
	this.getCurrentScript().runFlags |= Script::tick_attached;
	u32 p1 = 0;
	u32 ammo = 0;
	//const u32 tiimi = 3;
	this.server_setTeamNum(XORRandom(7));
}

void onTick(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);

	if (holder !is null && this !is null && point !is null)
	{
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
		u32 p1 = this.get_u32("p1");
		u32 ammo = this.get_u32("ammo");

		u32 tiimi = this.getTeamNum();
		if(p1 > 0)
		{
			p1 = (p1 - 1);
		}	
		if(ammo > 1)
		{	
			this.server_Die();
		}
		bool pressed_a1 = point.isKeyJustPressed(key_action1);

		if (pressed_a1 && p1 <= 0 && this.getTickSinceCreated() > 10)
		{	
			//print(""+p1);

			Vec2f pos = this.getPosition();
			//Vec2f aim = (holder.getAimPos()+Vec2f(-10+XORRandom(20), -10+XORRandom(20)));


			if (!getNet().isServer())
			{
				return;
			}
			//norm.Normalize();
			CBlob@ bullet = server_CreateBlob("portalbullet", this.getTeamNum(), this.getPosition());
			if (bullet !is null)
			{
				bullet.server_SetTimeToDie(5);
				CSprite@ sprite = this.getSprite();
				sprite.PlaySound("Respawn.ogg");
				p1 = 10;
				ammo = (ammo+1);

				Vec2f aim = holder.getAimPos();
				Vec2f norm = aim - pos;
				norm.Normalize();
				bullet.setVelocity(norm * (7.0f));
				this.set_u32("p1", p1);
				this.set_u32("ammo", ammo);
			}

		}
		this.set_u32("p1", p1);
		this.set_u32("ammo", ammo);

	}

}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();

	//cant bounce while held by something attached to something else
	//if (holder !is null && holder.isAttached()) return;

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
		}*/
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