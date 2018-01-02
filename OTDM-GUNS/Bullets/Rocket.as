

#include "Hitters.as";
#include "ShieldCommon.as";
#include "FireParticle.as"
#include "ArcherCommon.as";
#include "BombCommon.as";
#include "SplashWater.as";
#include "TeamStructureNear.as";
#include "Knocked.as"

const s32 bomb_fuse = 120;
const f32 arrowMediumSpeed = 8.0f;
const f32 arrowFastSpeed = 13.0f;
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 ARROW_PUSH_FORCE = 0.0f;
const f32 SPECIAL_HIT_SCALE = 5.0f; //special hit on food items to shoot to team-mates

const s32 FIRE_IGNITE_TIME = 5;


//Arrow logic
//blob functions
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0.0f);
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");
	//this.getSprite().SetEmitSound("RocketFly.ogg");

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("RocketFly.ogg");
	sprite.SetEmitSoundPaused(false);
	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	if (!this.exists("arrow type"))
	{
		this.set_u8("arrow type", ArrowType::normal);
	}

	// 20 seconds of floating around - gets cut down for fire arrow
	// in ArrowHitMap
	this.server_SetTimeToDie(20);

	const u8 arrowType = this.get_u8("arrow type");

	if (arrowType == ArrowType::bomb)			 // bomb arrow
	{
		SetupBomb(this, bomb_fuse, 48.0f, 1.5f, 24.0f, 0.5f, true);
		this.set_u8("custom_hitter", Hitters::bomb_arrow);
	}

    if(arrowType == ArrowType::water)
    {
        this.Tag("splash ray cast");

    }

	//sprite.setRenderStyle(RenderStyle::light);
	//set a random frame
	{
		Animation@ anim = sprite.addAnimation("arrow", 0, false);
		anim.AddFrame(0);
		sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("water arrow", 0, false);
		anim.AddFrame(90);
		if (arrowType == ArrowType::water)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("fire arrow", 0, false);
		anim.AddFrame(0);
		if (arrowType == ArrowType::fire)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("bomb arrow", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(0); //TODO flash this frame before exploding
		if (arrowType == ArrowType::bomb)
			sprite.SetAnimation(anim);
	}
}

void turnOffFire(CBlob@ this)
{
	this.SetLight(false);
	this.set_u8("arrow type", ArrowType::normal);
	this.Untag("fire source");
	this.getSprite().SetAnimation("arrow");
	this.getSprite().PlaySound("/ExtinguishFire.ogg");
}

void onTick(CBlob@ this)
{
	this.setVelocity(Vec2f(this.getVelocity()*1.12));
	CShape@ shape = this.getShape();
	Vec2f pos = Vec2f(this.getPosition());
	makeSmoke(pos);
	f32 angle;
	bool processSticking = true;
	if (!this.hasTag("collided")) //we haven't hit anything yet!
	{
		//temp arrows arrows die in the air
		if (this.hasTag("shotgunned"))
		{
			if (this.getTickSinceCreated() > 20)
			{
				this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::crush);
			}
		}

		//prevent leaving the map
		{
			Vec2f pos = this.getPosition();
			if (pos.x < 0.1f ||
			        pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f)
			{
				this.server_Die();
				return;
			}
		}

		angle = (this.getVelocity()).Angle();
		Pierce(this);   //map
		this.setAngleDegrees(-angle);

		if (shape.vellen > 0.0001f)
		{
			if (shape.vellen > 13.5f)
				shape.SetGravityScale(0.0f);
			else
				shape.SetGravityScale(0.0f);

			processSticking = false;
		}
	}

	// sticking
	if (processSticking)
	{
		//no collision
		shape.getConsts().collidable = false;

		if (!this.hasTag("_collisions"))
		{
			this.Tag("_collisions");
			// make everyone recheck their collisions with me
			const uint count = this.getTouchingCount();
			for (uint step = 0; step < count; ++step)
			{
				CBlob@ _blob = this.getTouchingByIndex(step);
				_blob.getShape().checkCollisionsAgain = true;
			}
		}

		angle = Maths::get360DegreesFrom256(this.get_u8("angle"));
		this.setVelocity(Vec2f(0, 0));
		this.setPosition(this.get_Vec2f("lock"));
		shape.SetStatic(true);
	}

	const u8 arrowType = this.get_u8("arrow type");

	// fire arrow
	if (arrowType == ArrowType::fire)
	{
		const s32 gametime = getGameTime();

		if (gametime % 6 == 0)
		{
			this.getSprite().SetAnimation("fire");
			this.Tag("fire source");

			Vec2f offset = Vec2f(this.getWidth(), 0.0f);
			offset.RotateBy(-angle);
			makeFireParticle(this.getPosition() + offset, 4);

			if (!this.isInWater())
			{
				this.SetLight(true);
				this.SetLightColor(SColor(255, 250, 215, 178));
				this.SetLightRadius(20.5f);
			}
			else
			{
				turnOffFire(this);
			}
		}
	}
}

void makeSmoke(Vec2f pos)
{

	ParticleAnimated("Splash2.png", Vec2f(pos.x-6.0f, pos.y), Vec2f(0.0f, 0.0f), 0.0f, 1.0f, 2, 0.1f, false);

}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(this.getTeamNum() != blob.getTeamNum() && !blob.hasTag("dead") && blob.hasTag("flesh"))
	{
		return true;
	}

	if(blob.hasTag("structure") || blob.getName()=="wooden_door" || blob.getName()=="stone_door" || blob.getName()=="wooden_platform")
	{
		return true;
	}
	if(blob.hasTag("vehicle"))
	{
		return true;
	}

	if(blob.hasTag("projectile"))
	{
		return true;	
	}

	return false;
}

bool specialArrowHit(CBlob@ blob)
{
	string bname = blob.getName();
	return (bname == "fishy" || bname == "food" || blob.hasTag("food"));
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		ArrowHitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
}

void AddArrowLayer(CBlob@ this, CBlob@ hitBlob, CSprite@ sprite, Vec2f worldPoint, Vec2f velocity)
{
	CSpriteLayer@ arrow = sprite.addSpriteLayer("arrow", "Entities/Items/Projectiles/Bullet.png", 16, 8, this.getTeamNum(), this.getSkinNum());

	if (arrow !is null)
	{
		Animation@ anim = arrow.addAnimation("default", 13, true);

		if (this.getSprite().animation !is null)
		{
			anim.AddFrame(4 + XORRandom(4));  //always use broken frame
		}
		else
		{
			warn("exception: arrow has no anim");
			anim.AddFrame(0);
		}

		arrow.SetAnimation(anim);
		Vec2f normal = worldPoint - hitBlob.getPosition();
		f32 len = normal.Length();
		if (len > 0.0f)
			normal /= len;
		Vec2f soffset = normal * (len + 0);

		// wow, this is shit
		// movement existing makes setfacing matter?
		if (hitBlob.getMovement() is null)
		{
			// soffset.x *= -1;
			arrow.RotateBy(180.0f, Vec2f(0, 0));
			arrow.SetFacingLeft(true);
		}
		else
		{
			soffset.x *= -1;
			arrow.SetFacingLeft(false);
		}

		arrow.SetIgnoreParentFacing(true); //dont flip when parent flips


		arrow.SetOffset(soffset);
		arrow.SetRelativeZ(-0.01f);

		f32 angle = velocity.Angle();
		arrow.RotateBy(-angle - hitBlob.getAngleDegrees(), Vec2f(0, 0));
	}
}


f32 ArrowHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData, const u8 arrowType)
{
	if (hitBlob !is null)
	{

	

	}

	return damage;
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{	
	if (this !is null && !this.hasTag("creating"))
	{
		this.setVelocity(this.getVelocity() * -1.0f);
		this.Tag("creating");
		this.server_Die();
	}
}

void FireUp(CBlob@ this)
{
	Vec2f burnpos;
	Vec2f head = Vec2f(this.getRadius() * 1.2f, 0.0f);
	f32 angle = this.getAngleDegrees();
	head.RotateBy(-angle);
	burnpos = this.getPosition() + head;


	// this.getMap() NULL ON ONDIE!
	CMap@ map = getMap();
	if (map !is null)
	{
		// burninate
		if (!isTeamStructureNear(this))
		{
			map.server_setFireWorldspace(burnpos, true);
			map.server_setFireWorldspace(this.get_Vec2f("fire pos") + head * 0.4f, true);
			map.server_setFireWorldspace(this.getPosition() , true); //burn where i am as well
		}
	}
}

//random object used for gib spawning
Random _gib_r(0xa7c3a);
void onDie(CBlob@ this)
{
	if (!getNet().isServer())
	{
		return;
	}
	CBlob@ explosion = server_CreateBlob("mine", this.getTeamNum(), this.getPosition());
	if(explosion !is null)
	{
		explosion.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
		explosion.Tag("exploding");
		explosion.Sync("exploding", true);

		explosion.server_SetHealth(-1.0f);
		explosion.server_Die();
	}	
	CBlob@ explosion2 = server_CreateBlob("mine", this.getTeamNum(), Vec2f(this.getPosition()+Vec2f(XORRandom(12),XORRandom(12))));
	if(explosion !is null)
	{
		explosion2.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
		explosion2.Tag("exploding");
		explosion2.Sync("exploding", true);

		explosion2.server_SetTimeToDie(0.07);
		
	}
	CBlob@ explosion3 = server_CreateBlob("mine", this.getTeamNum(), Vec2f(this.getPosition()+Vec2f(XORRandom(12),XORRandom(12))));
	if(explosion !is null)
	{
		explosion3.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
		explosion3.Tag("exploding");
		explosion3.Sync("exploding", true);

		explosion3.server_SetTimeToDie(0.11);
		
	}
	this.server_Die();

}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (!getNet().isServer())
	{
		return;
	}

	const u8 arrowType = this.get_u8("arrow type");
	if (arrowType == ArrowType::bomb)
	{
		return;
	}

	// merge arrow into mat_arrows

	for (int i = 0; i < inventoryBlob.getInventory().getItemsCount(); i++)
	{
		CBlob @blob = inventoryBlob.getInventory().getItem(i);

		if (blob !is this && blob.getName() == "mat_arrows")
		{
			blob.server_SetQuantity(blob.getQuantity() + 1);
			this.server_Die();
			return;
		}
	}

	// mat_arrows not found
	// make arrow into mat_arrows
	CBlob @mat = server_CreateBlob("mat_arrows");

	if (mat !is null)
	{
		inventoryBlob.server_PutInInventory(mat);
		mat.server_SetQuantity(1);
		this.server_Die();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const u8 arrowType = this.get_u8("arrow type");

	if (customData == Hitters::water || customData == Hitters::water_stun) //splash
	{
		if (arrowType == ArrowType::fire)
		{
			turnOffFire(this);
		}
	}

	if (customData == Hitters::sword)
	{
		return 0.0f; //no cut arrows
	}

	return damage;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	const u8 arrowType = this.get_u8("arrow type");
	// unbomb, stick to blob
	/*if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity

		const f32 scale = specialArrowHit(hitBlob) ? SPECIAL_HIT_SCALE : 1.0f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel * 0.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			hitBlob.AddForce(velocity * force);

			// stun if shot real close

			if (this.getTickSinceCreated() <= 4 &&
			        speed > ArcherParams::shoot_max_vel * 0.845f &&
			        hitBlob.hasTag("player"))
			{
				SetKnocked(hitBlob, 2);
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
			}
		}
	}*/
}


f32 getArrowDamage(CBlob@ this, f32 vellen = -1.0f)
{
	if (vellen < 0) //grab it - otherwise use cached
	{
		CShape@ shape = this.getShape();
		if (shape is null)
			vellen = this.getOldVelocity().Length();
		else
			vellen = this.getShape().getVars().oldvel.Length();
	}

	if (vellen >= arrowFastSpeed)
	{
		return 1.0f;
	}
	else if (vellen >= arrowMediumSpeed)
	{
		return 1.0f;
	}

	return 0.5f;
}

void SplashArrow(CBlob@ this)
{
	if (!this.hasTag("splashed"))
	{
		this.Tag("splashed");
		Splash(this, 3, 3, 0.0f, true);
		this.getSprite().PlaySound("GlassBreak");
	}
}
