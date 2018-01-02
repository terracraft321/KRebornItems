// TrampolineLogic.as
#include "Knocked.as";
#include "Hitters.as";
namespace Trampoline
{
	const string TIMER = "trampoline_timer";
	const u16 COOLDOWN = 0;
	const u8 SCALAR = 12;
}

void onInit(CBlob@ this)
{

	this.set_u32(Trampoline::TIMER, 0);
	this.set_u32("cooldown", 0);
	this.set_u32("charge", 0);
	this.set_u32("timer_thing", 0);
	this.set_u32("something", 0);

	this.getShape().getConsts().collideWhenAttached = true;

	this.Tag("no falldamage");
	this.Tag("medium weight");
	// Because BlobPlacement.as is *AMAZING*
	this.Tag("place norotate");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void onTick(CBlob@ this)
{

	this.Untag("medium weight");
	u32 cooldown = this.get_u32("cooldown");
	u32 charge = this.get_u32("charge");


	if (cooldown > 0)
	{
		cooldown = (cooldown-1);
	}
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");

	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);

	if(holder is null) return;

	if (charge < 100 && holder.isKeyPressed(key_action1))
	{
		charge = (charge +1);
	}		

	if (holder.isKeyPressed(key_action1))
	{
	}	

	if (charge > 80 && holder.isKeyPressed(key_action1))
	{
		SetKnocked(holder, 30);
		charge = 0;
		holder.server_Hit(holder, holder.getPosition(), Vec2f(), 0.0f, Hitters::water_stun);
	}

	if (charge > 0 && !holder.isKeyPressed(key_action1))
	{
		CBlob@[] blobsInRadius;

		if (this.getMap().getBlobsInRadius(this.getPosition(), 16.0f, @blobsInRadius))

		{

			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @blob = blobsInRadius[i];
				if (blob is null) return;
				if (blob.getName() == "ball" || blob.getName() == "bigball" || blob.getName() == "powerup" || blob.getName() == "keg" || blob.getName() == "boulder" || blob.getName() == "catapult" || blob.getName() == "raft")
				{
					//blob.setVelocity(Vec2f(charge *10, charge*10));


					Vec2f velocity_old = blob.getOldVelocity();
					//if (velocity_old.Length() < 1.0f) return;

					float angle = this.getAngleDegrees();

					Vec2f direction = Vec2f(0.0f, -1.0f);
					direction.RotateBy(angle);

					float velocity_angle = direction.AngleWith(velocity_old);

					Vec2f velocity = Vec2f(0, 0);
					if (charge > 50)
					{
						velocity = Vec2f(0, -(60/3));

					}					
					if (charge <= 50)
					{
						velocity = Vec2f(0, -((charge+15)/3));

					}			
					velocity.RotateBy(angle);
					blob.SetDamageOwnerPlayer(holder.getPlayer());
					blob.setVelocity(velocity);

					CSprite@ sprite = this.getSprite();
					if (sprite !is null)
					{
						sprite.SetAnimation("default");
						sprite.SetAnimation("bounce");
						sprite.PlaySound("Respawn.ogg");
					}
					
						
					
				}
			}
		}

		charge = 0;		
	}


	Vec2f ray = holder.getAimPos() - this.getPosition();
	ray.Normalize();

	f32 angle = ray.Angle();
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	//angle = angle > 135 || angle < 45? (holder.isFacingLeft()? 135 : 45) : 90;
	angle -= 90;

	this.setAngleDegrees(-angle);
	this.set_u32("cooldown", cooldown);
	this.set_u32("charge", charge);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{


	u32 cooldown = this.get_u32("cooldown"); 
	if (blob is null || blob.isAttached() || blob.getShape().isStatic()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	//bool pressed_a1 = point.isKeyJustPressed(key_action1);

	//cant bounce while held by something attached to something else
	//if (holder !is null && holder.isAttached()) return;
	if (point.isKeyPressed(key_action1) && cooldown < 1)
	{
		cooldown = 30;
		this.set_u32("cooldown", cooldown);
	}/*
	if(holder !is null && blob !is null && cooldown > 15)
	{
		if (this.get_u32(Trampoline::TIMER) < getGameTime())
		{
			Vec2f velocity_old = blob.getOldVelocity();
			//if (velocity_old.Length() < 1.0f) return;

			float angle = this.getAngleDegrees();

			Vec2f direction = Vec2f(0.0f, -1.0f);
			direction.RotateBy(angle);

			float velocity_angle = direction.AngleWith(velocity_old);

			if (Maths::Abs(velocity_angle) > 90)
			{
				this.set_u32(Trampoline::TIMER, getGameTime() + Trampoline::COOLDOWN);

				Vec2f velocity = Vec2f(0, -Trampoline::SCALAR);
				if (this.getTeamNum()==100)
				{
					velocity = Vec2f(0, -35);
				}
				if (this.getTeamNum()==101)
				{
					velocity = Vec2f(0, -45);
				}

				if (this.getTeamNum()==101)
				{
					velocity = Vec2f(0, -60);
				}

				if (this.getTeamNum()==103)
				{
					velocity = Vec2f(0, 40);
				}
				if (this.getTeamNum()==99)
				{
					velocity = Vec2f(0, -25);
				}

				velocity.RotateBy(angle);

				blob.setVelocity(velocity);

				CSprite@ sprite = this.getSprite();
				if (sprite !is null)
				{
					sprite.SetAnimation("default");
					sprite.SetAnimation("bounce");
					sprite.PlaySound("TrampolineJump.ogg");
				}
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