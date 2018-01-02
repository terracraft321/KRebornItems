// Dispenser.as

#include "MechanismsCommon.as";
class Healer : Component
{
		u16 id;
	f32 angle;
	Vec2f offset;

	Healer(Vec2f position, u16 _id, f32 _angle, Vec2f _offset)
	{
		x = position.x;
		y = position.y;

		id = _id;
		angle = _angle;
		offset = _offset;
	}
	void Activate(CBlob@ this)
	{

		this.set_bool("is active", true);
		//this.getSprite().SetAnimation("heal");
	}

	void Deactivate(CBlob@ this)
	{
		this.set_bool("is active", false);
		this.getSprite().SetAnimation("default");
	

	}
}
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	this.Tag("place ignore facing");

	this.Tag("place norotate");

	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by KnightLogic.as
	this.Tag("blocks sword");

	// used by TileBackground.as
	this.set_TileType("background tile", CMap::tile_wood_back);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if(!isStatic || this.exists("component")) return;

	const Vec2f position = this.getPosition() / 8;
	const u16 angle = this.getAngleDegrees();
	const Vec2f offset = Vec2f(0, -1).RotateBy(angle);

	Healer component(position, this.getNetworkID(), angle, offset);
	this.set("component", component);

	if(getNet().isServer())
	{
		MapPowerGrid@ grid;
		if(!getRules().get("power grid", @grid)) return;

		grid.setAll(
		component.x,                        // x
		component.y,                        // y
		TOPO_CARDINAL,                      // input topology
		TOPO_CARDINAL,                          // output topology
		INFO_LOAD,                          // information
		0,                                  // power
		component.id);                      // id
	}

	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(-500);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}


void onTick(CBlob@ this)
{		
	this.getCurrentScript().tickFrequency = 20; //heal interval, the bigger number, the slower
	this.getSprite().setRenderStyle(RenderStyle::normal);

	if (this.get_bool("is active")) //check if theres power
	{
		/*const bool team_only = true; // determines if it only heals teammates
		const int heal_interval = 10; // time between each heal
		const f32 heal_radius = 8.0f; // determines healing reach
		const f32 heal_amount = 1.0f;*/
		CBlob@[] blobsInRadius;

		if (this.getMap().getBlobsInRadius(this.getPosition(), 36.0f, @blobsInRadius)) //middle number is heal radius
		{			


			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ healed =  blobsInRadius[i];
				if (healed.getName() != "healer")
				{
					
					if ( healed.getHealth() <= (healed.getInitialHealth() - 0.25f))
					{
						this.getSprite().SetAnimation("default");
						this.getSprite().SetAnimation("heal");
						healed.server_SetHealth(healed.getHealth() + 0.25f); //healing happens here
						healed.getSprite().PlaySound("/Heart.ogg");
						this.getSprite().setRenderStyle(RenderStyle::light);
					}
				}
			//if(this.getTeamNum()==healed.getTeamNum() /*|| !this.get_bool("team_only") */) //checks if its a teammate

			}
		}
	}

}