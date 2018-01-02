// Airstrike script
void onInit(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
}

/*void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
}*/
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}

void onTick(CBlob@ this)
{
	CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP", 0);
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
	if(this !is null &&holder !is null && point !is null && point.isKeyPressed(key_action3))
	{		
		Vec2f aimpos = Vec2f(holder.getAimPos().x, holder.getAimPos().y);
		Vec2f xpos = Vec2f(holder.getAimPos().x, 0);
		CMap@ map = this.getMap();
		bool openair = map.rayCastSolid(xpos, aimpos, aimpos);
		if(!openair && getNet().isServer())
		{
			CBlob@ blob = server_CreateBlob("strike", this.getTeamNum(), aimpos);
			if (blob !is null)
			{
				blob.setVelocity(Vec2f(0, 0));
				blob.SetDamageOwnerPlayer(holder.getPlayer());
				this.server_Die();
				if (holder.getHealth() > holder.getInitialHealth()) holder.server_SetHealth(holder.getInitialHealth());
			}
		}
	}


}