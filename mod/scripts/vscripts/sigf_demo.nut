// Demo: a tour of Night City inside the test chamber.
::DEMO_A <- Vector(-140.0, -1250.0, -447.0)

SigfDemo(0.5, function() {
	SigfLook(6, 90)
	SigfCaption("WAKE UP, SAMURAI", 4)
	NC.say("wake")
})
SigfDemo(5.5, function() {
	SigfLook(8, 150)
	SigfCaption("THE CHAMBER IS NIGHT CITY NOW", 3.5)
})
SigfDemo(9.5, function() { SigfLook(6, 90) })
SigfDemo(10.5, function() { NC.hack() })
SigfDemo(16.0, function() { NC.hack() })
SigfDemo(21.5, function() { NC.hack() })
SigfDemo(27.0, function() {
	SigfLook(22, 90)
	NC.cab()
})
SigfDemo(32.0, function() { SigfCaption("PORTALS KEEP YOUR MOMENTUM", 3.5) })
SigfDemo(34.0, function() {
	local h = SigfHost()
	SigfLookAt(DEMO_A + Vector(60, 0, 0))
	h.SetOrigin(DEMO_A + Vector(0, 0, 260))
	NC.moved(h.GetOrigin())
	h.SetVelocity(Vector(0, 0, 0))
})
SigfDemo(41.5, function() {
	local h = SigfHost()
	h.SetOrigin(Vector(-60.0, -1400.0, -440.0))
	NC.moved(h.GetOrigin())
	h.SetVelocity(Vector(0, 0, 0))
	SigfLook(8, 90)
})
SigfDemo(44.0, function() { NC.spawnBoss() })
SigfDemo(51.0, function() { NC.hackBoss() })
SigfDemo(62.0, function() {
	SigfLook(8, 200)
	SigfCaption("NIGHT CITY TAKEOVER", 4)
})
SigfDemo(67.0, function() { SigfLook(8, 20) })
SigfDemo(71.0, function() { SigfLook(6, 90) })
