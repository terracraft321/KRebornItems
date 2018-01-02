void onSetStatic(CBlob@ this, const bool static)
{
	// this is kind of a sausage
	// infinitemagazine just spawns a normal magazine with a certain tag
	// that tag will get read in bolter.as and dispenser.as
	if (static)
	{	
		CBlob@ magazine = server_CreateBlob("magazine", this.getTeamNum(), this.getPosition());
		if (magazine is null) return;
		CShape@ shape = magazine.getShape();
		if (shape is null) return;
		
		shape.SetStatic(true);

		magazine.Tag("infinite");

		this.server_Die();
	}
}