
const string[] powerupTags = { "powerup superjump",
                               "powerup slash timestop",
                               "powerup fast arrows"
                             };

void onInit(CBlob@ this)
{

    //this.getShape().SetOffset(Vec2f(0.5, 0.5));
	if (!this.exists("powerup"))
	{
		int p = XORRandom(powerupTags.length);
		this.set_string("powerup", powerupTags[p]);
		Animation@ anim = this.getSprite().addAnimation("default", 0, false);
		anim.AddFrame(p);
	}

	// todo: anim handling if preset powerup
	this.setVelocity(Vec2f(-1.0f + XORRandom(21) / 10.0f, 0.0f) * 5.0f);
	this.addCommandID("toggle");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(!this.isOverlapping(caller) || !this.getShape().isStatic()) return;

	u8 state = this.get_u8("state");
	string description = (state > 0)? "Deactivate" : "Activate";

	CButton@ button = caller.CreateGenericButton(
	"$lever_"+state+"$",                        // icon token
	Vec2f_zero,                                 // button offset
	this,                                       // button attachment
	this.getCommandID("toggle"),                // command id
	description);                               // description

	button.radius = 25.0f;
	button.enableRadius = 20.0f;
}

void onDie(CBlob@ this)
{
	this.getSprite().PlaySound(CFileMatcher("Heart.ogg").getFirst());
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("player"))
	{
		return false;
	}

	else
	{
	return true;
	}

}
bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	if (this.getTeamNum() > 98)
	{
		return false;
	}
	else
	{
		return true;
	}
}
