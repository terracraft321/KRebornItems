#include "Hitters.as"
#include "MakeMat.as"
void onInit(CBlob@ this)
{
    this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;
    //this.set_TileType("background tile", CMap::tile_castle_back);
    this.server_setTeamNum(-1); //allow anyone to break them
	this.Tag("place norotate");
	this.Tag("stone");
	this.Tag("large");
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if (damage>this.getHealth()) this.getSprite().PlaySound("/destroy_gold"); else this.getSprite().PlaySound("/dig_stone");
	f32 dmg = damage;
	switch(customData)
	{
	case Hitters::builder:
		dmg *= 4.0f;
		if (getNet().isServer()) MakeMat( this, hitterBlob.getPosition(), "mat_gold", 4 * damage );
		break;
	case Hitters::saw:
		dmg *= 0.25;
		break;		
	case Hitters::bomb:
	case Hitters::keg:
	case Hitters::arrow:
	case Hitters::cata_stones:
	default:
		dmg=0;
		break;
	}		
	return dmg;
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	return true;
}