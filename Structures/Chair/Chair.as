#include "Hitters.as";
#include "FireCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().getConsts().accurateLighting = true;
	this.getSprite().SetRelativeZ(-10.0f);
	this.getShape().getConsts().waterPasses = true;

	this.Tag("place norotate");

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 70, false);
	shape.SetRotationsAllowed(false);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);


	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("SEAT");
	if (seat !is null)
	{
		seat.SetKeysToTake(key_left | key_right | key_up | key_down | key_action1 | key_action2 | key_action3 | key_pickup | key_inventory);
		seat.SetMouseTaken(true);
	}

	AddIconToken("$grab$", "InteractionIcons.png", Vec2f(32, 32), 29);
	this.addCommandID("grab");
	AddIconToken("$rest$", "InteractionIcons.png", Vec2f(32, 32), 29);
	this.addCommandID("rest");
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onTick(CBlob@ this)
{
	if (this.isAttached()) return;
	bool isServer = getNet().isServer();
	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("SEAT");
	if (seat !is null)
	{
		CBlob@ patient = seat.getOccupied();
		if (patient !is null)
		{
			if (( seat.isKeyJustPressed(key_up) || patient.isKeyJustPressed(key_up) ) && isServer)
			{
				patient.server_DetachFrom(this);
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isAttached() || caller.isAttached())
		return;
	if (this.hasAttached() && this.getAttachments().getAttachmentPointByName("SEAT").getOccupied().getNetworkID() != caller.getNetworkID() )
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$grab$", Vec2f(0, 0), this, this.getCommandID("grab"), "Grab", params);
	}
	else if (!this.hasAttached())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rest$", Vec2f(0, 0), this, this.getCommandID("rest"), "Rest", params);		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (this.isAttached()) return;
	bool isServer = (getNet().isServer());

	if (cmd == this.getCommandID("grab"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("SEAT");
			if (seat !is null )
			{
				CBlob@ sitting = seat.getOccupied();
				if (isServer)
				{
					if (sitting !is null && sitting.getNetworkID() != caller_id)
					{
						sitting.server_DetachFrom(this);
					}
					caller.server_AttachTo(sitting, "PICKUP");
				}
			}
		}
	}

	else if (cmd == this.getCommandID("rest"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			if (seatAvailable(this))
			{
				CBlob@ carried = caller.getCarriedBlob();
				if (isServer)
				{
					if (carried !is null)
					{
						if (!caller.server_PutInInventory(carried))
						{
							carried.server_DetachFrom(caller);
						}
					}
					this.server_AttachTo(caller, "SEAT");
				}
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint !is null)
	{
		if (this.getShape().isStatic() && attachedPoint.name == "SEAT")
			attached.getShape().getConsts().collidable = false;
	}

	CSprite@ attached_sprite = attached.getSprite();
	if (attached_sprite !is null && getNet().isClient())
	{
		attached_sprite.PlaySound("GetInVehicle.ogg");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached !is null)
	{
		detached.getShape().getConsts().collidable = true;
		detached.AddForce(Vec2f(0, -20));
	}

	//hacky fix to chairs disappearing
	//The tag "wasPlaced" is set in server_BuildBlob@BuilderCommon.as
	//wasPlaced = has been placed by player
	//isStatic = isn't one of the red pseudochairs you see before placing them
	if (this.hasTag("wasPlaced") && this.getShape().isStatic())
	{
		CBlob@ newChair = server_CreateBlob("chair", this.getTeamNum(), this.getPosition());
		if (newChair !is null)
		{
			newChair.SetFacingLeft(this.isFacingLeft());
			this.server_Die();
		}
		
	}
}

bool seatAvailable(CBlob@ this)
{
	AttachmentPoint@ seat = this.getAttachments().getAttachmentPointByName("SEAT");
	if (seat !is null)
	{
		CBlob@ patient = seat.getOccupied();
		if (patient is null)
		{
			return true;
		}
	}
	return false;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_wood.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}