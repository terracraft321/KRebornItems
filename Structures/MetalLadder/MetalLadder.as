// Ladder.as

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore blocking actors");

	CShape@ shape = this.getShape();
	if (shape is null) return;

	shape.SetRotationsAllowed(false);
	shape.getVars().waterDragScale = 10.0f;

	ShapeConsts@ consts = shape.getConsts();
	if (consts is null) return;

	consts.collideWhenAttached = false;
	consts.waterPasses = true;
	consts.tileLightSource = true;
	consts.mapCollisions = false;

	this.SetFacingLeft((this.getNetworkID() * 31) % 2 == 1);  //for ladders on map
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_ladder.ogg");
	this.getSprite().SetZ(-40);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder)
	{
		return 0.5f;
	}
	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}