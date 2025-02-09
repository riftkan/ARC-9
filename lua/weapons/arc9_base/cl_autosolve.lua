function SWEP:GenerateAutoSight(sight, slottbl)
    local pos, ang = self:GetAttPos(slottbl, false, true)
    local scale = slottbl.Scale or 1

    pos = pos - (ang:Right() * sight.Pos.x * scale)
    pos = pos - (ang:Forward() * sight.Pos.y * scale)
    pos = pos - (ang:Up() * sight.Pos.z * scale)

    ang:RotateAroundAxis(ang:Right(), sight.Ang.p)
    ang:RotateAroundAxis(ang:Up(), sight.Ang.y)
    ang:RotateAroundAxis(ang:Forward(), sight.Ang.r)

    debugoverlay.Axis(pos, ang, 16, 1, true)

    local s_pos = Vector(0, 0, 0)
    local s_ang = Angle(0, 0, 0)

    local up, forward, right = s_ang:Up(), s_ang:Forward(), s_ang:Right()

    s_pos = s_pos + (right * pos.x)
    s_pos = s_pos + (forward * pos.y)
    s_pos = s_pos + (up * -pos.z)

    -- print(ang)

    return {
        Pos = s_pos,
        Ang = -ang + (slottbl.CorrectiveAng or Angle(0, 0, 0)),
        -- ExtraPos = Vector(0, pos.y + self.IronSights.Pos.y, 0),
        Magnification = sight.Magnification or 1,
        ExtraSightDistance = slottbl.ExtraSightDistance,
        GeneratedSight = true,
        -- ExtraAng = ang
    }
end

SWEP.MultiSightIndex = 1

function SWEP:GetSightPositions()
    local s = self:GetSight()
    return s.Pos, s.Ang
end

function SWEP:GetExtraSightPositions()
    local s = self:GetSight()
    local se = s.ExtraPos or Vector(0, 0, 0)
    se.y = se.y - (s.ExtraSightDistance or 0)
    -- return Vector(0, 0, 0), Angle(0, 0, 0)
    return se, s.ExtraAng or Angle(0, 0, 0)
end

function SWEP:GetMagnification()
    local sight = self:GetSight()

    local target = sight.Magnification or 1

    if GetConVar("arc9_cheapscopes"):GetBool() and !sight.Disassociate then
        local atttbl = self:GetSight().atttbl

        if atttbl and atttbl.RTScope then
            target = (self:GetOwner():GetFOV() / self:GetRTScopeFOV())
        end
    end

    return target
end

function SWEP:AdjustMouseSensitivity()
    if self:GetSightAmount() <= 0 then return end

    local mag = self:GetMagnification()
    local fov = GetConVar("fov_desired"):GetFloat()

    local sight = self:GetSight()

    if sight.atttbl and sight.atttbl.RTScope and !sight.Disassociate then
        mag = mag + (fov / self:GetRTScopeFOV())
    end

    if mag > 0 then
        return 1 / Lerp(self:GetSightAmount(), 1, mag)
    end
end