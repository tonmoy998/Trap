local sounds = {}

function sounds.load()
	Signal.register("Click", function()
		TEsound.play("assets/sounds/click.mp3", "static", 1, 0.5)
	end)
	Signal.register("Running", function()
		local randomPitch = love.math.random(75, 125) / 100
		TEsound.play("assets/sounds/footsteps.wav", "static", 1, 0.2, randomPitch)
	end)

	Signal.register("Coin", function()
		TEsound.play("assets/sounds/coin.wav", "static", 1, 0.095)
	end)

	Signal.register("Level 1", function()
		--TEsound.play("assets/sounds/gamebg.wav", "static", 1, 0.2)
	end)

	Signal.register("Completed", function()
		TEsound.play("assets/sounds/completed.mp3", "static", 1, 1)
		print("Completed")
	end)

	Signal.register("Ball", function()
		local randomPitch = love.math.random(75, 125) / 100
		TEsound.play("assets/sounds/ball.wav", "static", 1, 0.4, randomPitch)
	end)

	Signal.register("Jump", function()
		TEsound.play("assets/sounds/jump.mp3", "static", 1, 0.6, 0.75)
	end)
end

return sounds
