// Cyberpunk 2077 Takeover: the test chamber becomes Night City.
::NC <- {}
NC.neon <- ["255 0 160", "0 240 255", "255 230 0", "170 60 255", "255 60 60"]
NC.turrets <- []
NC.eddies <- 0
NC.bubbles <- 0

// Holographic neon ads: flat glass-like panels (their materials are our neon ads), all turned toward the stage.
NC.models <- [
	"models/props_bts/silhouette_window_01.mdl",      // 0 big square: NIGHT CITY
	"models/props_bts/silhouette_window_02.mdl",      // 1 big square: NIGHT CITY
	"models/props_destruction/glass_192x128_b.mdl",   // 2 NOODLES
	"models/props_destruction/glass_192x192_c.mdl",   // 3 BRAINDANCE
	"models/props_destruction/glass_192x96_d.mdl",    // 4 CHROME CLINIC
	"models/props_destruction/glass_192x224_d.mdl",   // 5 SAMURAI
	"models/props_destruction/glass_b1.mdl"           // 6 CYBERWARE
]
// x, y, z, model
NC.boards <- [
	[-60.0, 500.0, -60.0, 0],
	[-60.0, -2250.0, -60.0, 1],
	[-520.0, -1500.0, -220.0, 2],
	[-540.0, -1000.0, -200.0, 3],
	[-560.0, -500.0, -170.0, 4],
	[-580.0, 0.0, -140.0, 5],
	[420.0, -1450.0, -230.0, 5],
	[440.0, -950.0, -200.0, 6],
	[460.0, -450.0, -170.0, 2],
	[480.0, 50.0, -140.0, 3]
]

NC.billboards <- function() {
	foreach (b in NC.boards) {
		local p = Vector(b[0], b[1], b[2])
		local d = Vector(-60.0, -1250.0, b[2]) - p
		local yaw = atan2(d.y, d.x) * 57.29578
		SigfDynamic(NC.models[b[3]], p, 0.0, function(e):(yaw) { e.SetAngles(0, yaw, 0); SigfScale(e, 1.35) })
	}
}

NC.city <- function() {
	SigfCmd("gameinstructor_enable 0")
	SigfCmd("fog_override 1")
	SigfCmd("fog_enable 1")
	SigfCmd("fog_color 40 5 70")
	SigfCmd("fog_start 300")
	SigfCmd("fog_end 3000")
	SigfCmd("fog_maxdensity 0.5")
	NC.billboards()
}

// HUD text that refreshes in place (same channel, no fade flicker).
NC.hud <- function(text, x, y, color, size, sec) {
	local t = Entities.CreateByClassname("game_text")
	t.__KeyValueFromString("message", text)
	t.__KeyValueFromString("color", color)
	t.__KeyValueFromString("color2", "255 255 255")
	t.__KeyValueFromFloat("x", x)
	t.__KeyValueFromFloat("y", y)
	t.__KeyValueFromInt("effect", 0)
	t.__KeyValueFromFloat("fadein", 0.0)
	t.__KeyValueFromFloat("fadeout", 0.15)
	t.__KeyValueFromFloat("fxtime", 0.0)
	t.__KeyValueFromFloat("holdtime", sec)
	t.__KeyValueFromInt("channel", [2, 1, 4, 0, 5, 3][size])
	t.__KeyValueFromInt("spawnflags", 1)
	EntFireByHandle(t, "Display", "", 0.0, null, null)
	EntFireByHandle(t, "Kill", "", sec + 0.5, null, null)
}

NC.hudTick <- function() {
	local bar = ""
	for (local i = 0; i < 10; i++) bar += (i < NC.hp ? "|" : ".")
	NC.hud("HP [" + bar + "]  LVL 50    EDDIES " + NC.eddies + " E$", 0.03, 0.04, "0 240 255", 0, 1.2)
}

NC.hp <- 10
NC.stage <- 0
NC.kills <- 0
NC.jobs <- [
	"Hack the Maelstrom turrets",
	"Send a Delamain cab through a portal",
	"Take down the CYBERPSYCHO"
]
NC.quest <- function() {
	local extra = ""
	if (NC.stage == 0) extra = "  " + NC.kills + "/3"
	NC.hud("ACTIVE JOB: " + NC.jobs[NC.stage % NC.jobs.len()] + extra, 0.03, 0.09, "255 230 0", 1, 4.2)
}

NC.pop <- function(text, color) { NC.hud(text, -1.0, 0.68, color, 3, 2.5) }
NC.reward <- function(n, why) {
	NC.eddies += n
	NC.pop("+" + n + " E$  " + why, "255 230 0")
	SigfSound("sigf/eddies.wav")
}

// Johnny Silverhand: a glowing personality core that circles the player and talks (voice + subtitle).
NC.johnny <- null
NC.lines <- {
	wake = ["JOHNNY: Wake up, Samurai.\nWe have a chamber to burn.", "sigf/j1.wav"],
	portal = ["JOHNNY: Portals? Now that's chrome, choom.", "sigf/j2.wav"],
	hack = ["JOHNNY: That turret has a death wish.\nHack it.", "sigf/j3.wav"],
	cab = ["JOHNNY: Delamain sent a cab.\nThrow it through a portal.", "sigf/j4.wav"],
	boss = ["JOHNNY: Cyberpsycho on the platform.\nTime to hack some ugly.", "sigf/j5.wav"]
}
NC.say <- function(key) {
	local l = NC.lines[key]
	NC.hud(l[0], -1.0, 0.84, "255 150 20", 2, 3.6)
	SigfSound(l[1])
}

NC.spawnJohnny <- function() {
	SigfDynamic("models/npcs/personality_sphere/personality_sphere.mdl", SigfHost().EyePosition() + Vector(0, 0, 40), 0.0, function(e) {
		NC.johnny = e
		SigfColor(e, "255 150 20")
		SigfScale(e, 0.7)
	})
}

NC.followJohnny <- function() {
	if (NC.johnny == null || !NC.johnny.IsValid()) return
	local h = SigfHost()
	local bob = sin(Time() * 2.0) * 6.0
	local a = 0.0
	if (::SigfDemoMode) a = (::SigfYaw - 25.0) / 57.29578       // demo: hovers ahead on the right of the view
	else a = Time() * 0.6                                       // idle: circles the player while the view turns
	local p = h.EyePosition() + Vector(cos(a), sin(a), 0.0) * 120.0 + Vector(0, 0, 22.0 + bob)
	NC.johnny.SetOrigin(p)
	NC.johnny.SetAngles(0, a * 57.29578 + 180.0, 0)
}

// Maelstrom gangers: neon turrets on the platform.
NC.spots <- [[-170.0, -1060.0], [-30.0, -1060.0], [110.0, -1060.0], [-100.0, -940.0], [40.0, -940.0]]
NC.spawnTurret <- function(i) {
	local sp = NC.spots[i % NC.spots.len()]
	local col = (i % 2 == 0) ? "255 40 120" : "255 80 40"
	SigfTurret(Vector(sp[0], sp[1], -445.0), 270.0, 0.0, function(t):(col) {
		SigfColor(t, col)
		NC.turrets.append(t)
	})
}

NC.liveTurret <- function() {
	local live = []
	foreach (t in NC.turrets) { if (t != null && t.IsValid()) live.append(t) }
	NC.turrets = live
	if (live.len() == 0) return null
	return live[RandomInt(0, live.len() - 1)]
}

// A fireball with smoke at pos (no damage).
NC.boom <- function(pos) {
	SigfSpawn("env_explosion", pos, { iMagnitude = 0, spawnflags = 1 }, 4.0, function(e) { EntFireByHandle(e, "Explode", "", 0.0, null, null) })
	SigfSound("level/explode_1.wav")
}

// Quickhack: the target glitches white/red, then overheats.
NC.hack <- function() {
	local t = NC.liveTurret()
	if (t == null) { NC.spawnTurret(RandomInt(0, 4)); return }
	NC.say("hack")
	SigfCaption("QUICKHACK: OVERHEAT", 2.5)
	SigfSound("sigf/hack.wav")
	SigfColor(t, "255 255 255")
	SigfIn(0.4, function():(t) { if (t.IsValid()) SigfColor(t, "0 255 255") })
	SigfIn(0.8, function():(t) { if (t.IsValid()) SigfColor(t, "255 255 255") })
	SigfIn(1.2, function():(t) { if (t.IsValid()) { SigfColor(t, "255 0 0"); EntFireByHandle(t, "Ignite", "", 0.0, null, null) } })
	SigfIn(2.0, function():(t) {
		if (!t.IsValid()) return
		NC.boom(t.GetOrigin() + Vector(0, 0, 30))
		EntFireByHandle(t, "SelfDestruct", "", 0.0, null, null)
		NC.kills++
		NC.reward(250, "GANGER FLATLINED")
		if (NC.stage == 0 && NC.kills >= 3) { NC.stage = 1; NC.kills = 0 }
		SigfIn(3.0, function() { NC.spawnTurret(RandomInt(0, 4)) })
	})
}

// Delamain cab: a yellow companion cube drops in over the portal. Through a portal = delivered.
NC.cabs <- []
NC.cab <- function() {
	local p = Vector(-140.0, -1250.0, -447.0 + 380.0)
	SigfCube(p, 1, 60.0, function(c) {
		SigfColor(c, "255 220 0")
		NC.cabs.append({ ent = c, pos = c.GetOrigin(), done = false })
	})
	NC.say("cab")
	SigfSound("sigf/honk.wav")
	NC.pop("DELAMAIN: Your ride has arrived.", "255 230 0")
}

// Cyberpsycho: a giant red turret model that hovers over the platform, with its own health bar.
NC.boss <- null
NC.bossHp <- 0
NC.bossBase <- Vector(-30.0, -950.0, -420.0)
NC.spawnBoss <- function() {
	SigfCaption("CYBERPSYCHO DETECTED", 3.0)
	SigfSound("sigf/boss.wav")
	NC.say("boss")
	NC.bossHp = 10
	SigfDynamic("models/props/turret_01.mdl", NC.bossBase, 0.0, function(t) {
		SigfColor(t, "255 0 0")
		SigfScale(t, 3.0)
		NC.boss = t
	})
}
NC.bossTick <- function() {
	local t = NC.boss
	if (t == null || !t.IsValid()) return
	local now = Time()
	t.SetOrigin(NC.bossBase + Vector(sin(now * 0.7) * 60.0, 0.0, sin(now * 1.6) * 14.0))
	t.SetAngles(0, 270.0 + sin(now * 0.9) * 25.0, 0)
	local bar = ""
	for (local i = 0; i < 10; i++) bar += (i < NC.bossHp ? "|" : ".")
	NC.hud("CYBERPSYCHO [" + bar + "]", -1.0, 0.12, "255 40 40", 1, 1.2)
}
NC.hackBoss <- function() {
	local t = NC.boss
	if (t == null || !t.IsValid()) return
	SigfCaption("QUICKHACK: SYSTEM COLLAPSE", 2.5)
	SigfSound("sigf/hack.wav")
	local flick = ["255 255 255", "0 255 255", "255 255 255", "255 0 255", "255 255 255", "0 255 255"]
	for (local i = 0; i < 6; i++) {
		local col = flick[i]
		SigfIn(0.4 * i, function():(t, col) { if (t.IsValid()) SigfColor(t, col) })
		SigfIn(0.4 * i + 0.05, function() { if (NC.bossHp > 0) NC.bossHp-- })
	}
	SigfIn(2.6, function():(t) {
		if (!t.IsValid()) return
		local o = t.GetOrigin()
		NC.boom(o + Vector(0, 0, 40))
		SigfIn(0.25, function():(o) { NC.boom(o + Vector(40, 0, 90)) })
		SigfIn(0.5, function():(o) { NC.boom(o + Vector(-40, 0, 20)) })
		EntFireByHandle(t, "Kill", "", 0.0, null, null)
		NC.boss = null
		NC.bossHp = 0
		NC.reward(1000, "CYBERPSYCHO DOWN")
		NC.stage = 0
		NC.kills = 0
	})
}

// Sandevistan: a big jump in position = the player went through a portal.
NC.lastPos <- null
// Scripted moves of the player (demo) are not portal trips.
NC.moved <- function(pos) { NC.lastPos = pos }
NC.sandeUntil <- 0.0
NC.sandeCool <- 0.0
NC.watch <- function() {
	local now = Time()
	local h = SigfHost()
	local p = h.GetOrigin()
	if (NC.lastPos != null && (p - NC.lastPos).Length() > 160.0) printl("DBG jump " + (p - NC.lastPos).Length() + " at " + p.ToKVString())
	if (NC.lastPos != null && (p - NC.lastPos).Length() > 160.0 && now > NC.sandeCool) {
		NC.sandeCool = now + 12.0
		SigfCaption("SANDEVISTAN ENGAGED", 2.5)
		SigfSound("sigf/sande.wav")
		NC.sandeUntil = now + 1.2
		SigfCmd("host_timescale 0.35")
		SigfIn(0.9, function() { SigfCmd("host_timescale 1") })
		if (NC.stage == 0 || NC.stage == 1) NC.say("portal")
	}
	NC.lastPos = p
	// Delamain cabs: through a portal = delivered
	foreach (c in NC.cabs) {
		if (c.done || c.ent == null || !c.ent.IsValid()) continue
		local cp = c.ent.GetOrigin()
		if ((cp - c.pos).Length() > 160.0) {
			c.done = true
			SigfSound("sigf/honk.wav")
			NC.reward(500, "CAB DELIVERED")
			if (NC.stage == 1) NC.stage = 2
		}
		c.pos = cp
	}
}

NC.auto <- !::SigfDemoMode

SigfAfter(1.0, function() {
	NC.city()
	if (NC.auto) {
		SigfCaption("WAKE UP, SAMURAI", 4)
		NC.say("wake")
	}
	NC.spawnJohnny()
	for (local i = 0; i < 3; i++) NC.spawnTurret(i)
	SigfRealPortals(Vector(-140.0, -1250.0, -447.0), Vector(-90, 0, 0), Vector(40.0, -1250.0, -447.0), Vector(-90, 0, 0))
})
SigfEvery(0.1, function() { NC.followJohnny(); NC.watch(); NC.bossTick() })
SigfEvery(1.0, function() { NC.hudTick() })
// The fog slowly slides between magenta, violet and cyan: the whole chamber breathes neon.
SigfEvery(0.5, function() {
	if (Time() < NC.sandeUntil) { SigfCmd("fog_color 0 150 170"); return }
	local t = Time() * 0.35
	local r = 45 + 35 * sin(t)
	local g = 8 + 30 * (0.5 + 0.5 * sin(t + 2.1))
	local b = 70 + 25 * sin(t + 4.2)
	SigfCmd("fog_color " + r.tointeger() + " " + g.tointeger() + " " + b.tointeger())
})
SigfEvery(4.0, function() { NC.quest() })
// Idle loop (outside the demo): the story plays by itself.
SigfEvery(15.0, function() {
	if (!NC.auto) return
	if (NC.stage == 0) NC.hack()
	else if (NC.stage == 1) NC.cab()
	else if (NC.stage == 2) { if (NC.boss == null || !NC.boss.IsValid()) NC.spawnBoss(); else NC.hackBoss() }
})

::NC_DEBUG <- false
if (NC_DEBUG) {
	SigfAutoCam(false)
	SigfAfter(4.0, function() { SigfCmd("jpeg") })
	SigfAfter(5.0, function() { SigfLook(5, 150) })
	SigfAfter(7.0, function() { SigfCmd("jpeg") })
	SigfAfter(8.0, function() { SigfLook(5, 30) })
	SigfAfter(10.0, function() { SigfCmd("jpeg") })
	SigfAfter(11.0, function() { SigfLook(5, 270) })
	SigfAfter(13.0, function() { SigfCmd("jpeg") })
}
