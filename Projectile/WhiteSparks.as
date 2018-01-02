void sparks(Vec2f at, f32 angle, f32 damage, Vec2f ray)
{
	int amount = damage * 3 + XORRandom(2);
	f32 rayx = ray.x;
	f32 rayy = ray.y;
	//print(""+ rayx, rayy);
	for (int i = 0; i < amount; i++)
	{
		Vec2f vel = ray *(XORRandom(3));
		Vec2f vel2 = ray *(XORRandom(3));
		Vec2f vel3 = ray *(XORRandom(3));
		Vec2f vel4 = ray *(XORRandom(3));
		Vec2f vel5 = ray *(XORRandom(3));
	//	vel.y = ray;
		ParticlePixel(at, vel, SColor(120, 255, 255, 255), true);	
		ParticlePixel(at, vel2, SColor(120, 255, 255, 255), true);
		ParticlePixel(at, vel3, SColor(120, 255, 255, 255), true);
		ParticlePixel(at, vel4, SColor(120, 255, 255, 255), true);
		ParticlePixel(at, vel5, SColor(120, 255, 255, 255), true);
	}
}
