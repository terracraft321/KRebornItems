
const string[] powerupTags = { "powerup superjump",
                               "powerup slash timestop",
                               "powerup fast arrows"
                             };

void onInit(CBlob@ this)
{
	if (!this.exists("powerup"))
	{
		int p = XORRandom(powerupTags.length);
		this.set_string("powerup", powerupTags[p]);
		Animation@ anim = this.getSprite().addAnimation("default", 0, false);
		anim.AddFrame(p);
	}

	// todo: anim handling if preset powerup
	this.setVelocity(Vec2f(-1.0f + XORRandom(21) / 10.0f, 0.0f) * 5.0f);
}


void onDie(CBlob@ this)
{
	this.getSprite().PlaySound(CFileMatcher("Heart.ogg").getFirst());
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}
