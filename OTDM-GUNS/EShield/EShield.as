// Airstrike script
void onInit(CBlob@ this)
{

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	point.SetKeysToTake(key_action3);
}


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
		Vec2f pos = this.getPosition();
		if (!getNet().isServer())
		{
			return;
		}
		CBlob@ es = server_CreateBlob("es", this.getTeamNum(), Vec2f(pos));
		if (es !is null)
		{
			es.SetDamageOwnerPlayer(holder.getPlayer());
		}
	this.server_Die();

		
	}


}