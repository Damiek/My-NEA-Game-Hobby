local Module = {}

function Module.Run()
	task.spawn(function()
		game.Players.LocalPlayer.Character.Head.Transparency = 1
		wait(2)
		game.Players.LocalPlayer.Character.Head.Transparency = 0
	end)
end

return Module