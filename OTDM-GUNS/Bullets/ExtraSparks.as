void mapSparks(Vec2f at, f32 angle, f32 damage)
{
	int amount = damage * 3 + XORRandom(2);
	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = Vec2f(XORRandom(4), XORRandom(4));
		ParticlePixel(at, vel, SColor(255, 150, 150, 40), true);	
	}
}
