// Emitter2.as

#include "MechanismsCommon.as";

class Emitter2 : Component
{
	u16 m_id;

	Emitter2(Vec2f position, u16 id)
	{
		x = position.x;
		y = position.y;

		m_id = id;
	}

	u8 Special(MapPowerGrid@ grid, u8 power_old, u8 power_new)
	{
		if(power_old == 0 && power_new > 0)
		{
			packet_AddChangeFrame(grid.packet, m_id, 1);
		}
		else if(power_old > 0 && power_new == 0)
		{
			packet_AddChangeFrame(grid.packet, m_id, 0);
		}

		return power_new;
	}

	void Activate(CBlob@ this)
	{

		this.set_bool("is active", true);
		//this.getSprite().SetAnimation("roll");
		//print("active");
	}

	void Deactivate(CBlob@ this)
	{
		this.set_bool("is active", false);
		//this.getSprite().SetAnimation("default");
	

	}
};

const string EMITTER2 = "emitter2";

void onInit(CBlob@ this)
{
	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by KnightLogic.as
	this.Tag("ignore sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f POSITION = this.getPosition() / 8;
	const u16 ANGLE = this.getAngleDegrees();

	Emitter2 component(POSITION, this.getNetworkID());
	this.set("component", component);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		rotateTopology(ANGLE, TOPO_DOWN),   // input topology
		TOPO_NONE,                          // output topology
		INFO_SPECIAL,                       // information
		0,                                  // power
		component.m_id);                    // id

		Vec2f offset = Vec2f(0, -1).RotateBy(ANGLE);

		for(u8 i = 1; i < signal_strength; i++)
		{
			const Vec2f TARGET = offset * i + POSITION;

			CBlob@ blob = getBlobByNetworkID(grid.getID(TARGET.x, TARGET.y));
			if(blob is null || blob.getName() != "receiver" || !blob.getShape().isStatic()) continue;

			u16 difference = Maths::Abs(ANGLE - blob.getAngleDegrees());
			if(difference != 180) continue;

			blob.push(EMITTER2, component.m_id);
		}
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	const bool facing = ANGLE < 180? false : true;

	sprite.SetZ(-60);
	sprite.SetFacingLeft(facing);

	CSpriteLayer@ layer = sprite.addSpriteLayer("background", "Receiver.png", 16, 16);
	layer.addAnimation("default", 0, false);
	layer.animation.AddFrame(2);
	layer.SetRelativeZ(-1);
	layer.SetFacingLeft(facing);

	if(ANGLE == 90 || ANGLE == 180)
	{
		sprite.SetOffset(Vec2f(0, 1));
		layer.SetOffset(Vec2f(0, 1));
	}
}

void onTick(CBlob@ this)
{		
	CBlob@[] blobsInRadius;

	if (this.getMap().getBlobsInRadius(this.getPosition(), 150.0f, @blobsInRadius))


		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @rec = blobsInRadius[i];
			if (rec.getName() == "receiver2")
			{	
				if (this.get_bool("is active")) 
				{
					if (rec.get_u8("state")==1)
					{
						rec.SendCommand(rec.getCommandID("toggle"));
						return;
					}
					if (rec.get_u8("state")==0)
					{
						rec.SendCommand(rec.getCommandID("toggle"));
						return;
					}
				}
			}
		}
}
/*

		CBlob@ this = getBlobByNetworkID(m_id);
		{
			CMap@ map = getMap();
			CBlob@[] blobsInRadius;
			if (map.getBlobsInRadius(this.getPosition(), 150, @blobsInRadius))
			{

				CBlob @b = blobsInRadius[i];
				if (b.getName() == receiver2)
				{

					b.server_Die();
				}
			}
		}
/*

/*
void onDie(CBlob@ this)
{
	if(!getNet().isClient() || !this.exists("component")) return;

	const string image = this.getSprite().getFilename();
	const Vec2f position = this.getPosition();
	const u8 team = this.getTeamNum();

	for(u8 i = 0; i < 3; i++)
	{
		makeGibParticle(
		image,                              // file name
		position,                           // position
		getRandomVelocity(90, 2, 360),      // velocity
		i,                                  // column
		2,                                  // row
		Vec2f(8, 8),                        // frame size
		1.0f,                               // scale?
		0,                                  // ?
		"",                                 // sound
		team);                              // team number
	}
}
*/

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}