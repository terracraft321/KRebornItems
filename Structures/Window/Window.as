
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
	this.Tag("place ignore facing");
	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");
    this.getShape().SetOffset(Vec2f(4.0, 4.0));

	// used by BuilderHittable.as
	this.Tag("builder always hit");

	// used by KnightLogic.as
	this.Tag("blocks sword");

	// used by TileBackground.as
	//this.set_TileType("background tile", CMap::tile_wood_back);
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	//sprite.SetFacingLeft(false);
	sprite.SetZ(-500);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}