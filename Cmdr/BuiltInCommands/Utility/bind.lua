--[[
	Custom bind command as we want to let the player bind their own inputs to
	certain actions.
	
]]

local UserInputService = game:GetService("UserInputService")

return {
	Name = "bind",
	Aliases = {},
	Description = "Binds a command string to a key or mouse input.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput ! bindableResource @ player",
			Name = "Input",
			Description = "The key or input type you'd like to bind the command to.",
		},
		{
			Type = "command",
			Name = "Command",
			Description = "The command you want to run when the input first starts.",
		},
		{
			Type = "string",
			Name = "Arguments",
			Description = "The arguments for the command",
			Default = "",
		},
	},

	ClientRun = function(context, bind, command, arguments)
		local binds = context:GetStore("CMDR_Binds")

		command = command .. " " .. arguments

		local bindType = context:GetArgument(1).Type.Name
		local bindKey = bind

		if bindType == "userInput" then
			local keys = {}
			table.insert(keys, bind.stateModifier.Name)
			for _, modifierKey in bind.modifiers do
				table.insert(keys, modifierKey.Name)
			end
			table.insert(keys, bind.main.Name)
			bindKey = table.concat(keys, "+")
		end

		if binds[bindKey] then
			binds[bindKey]:Disconnect()
		end

		if bindType == "userInput" then
			local signal

			if bind.stateModifier == Enum.UserInputState.Begin then
				signal = UserInputService.InputBegan
			else
				signal = UserInputService.InputEnded
			end

			binds[bindKey] = signal:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == bind.main or input.KeyCode == bind.main then
					-- check if all the modifiers are true
					for _, modifierKey in bind.modifiers do
						if input:IsModifierKeyDown(modifierKey) == false then
							return
						end
					end

					context:Reply(
						context.Dispatcher:EvaluateAndRun(
							context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command)
						)
					)
				end
			end)
		elseif bindType == "bindableResource" then
			return "Unimplemented..."
		elseif bindType == "player" then
			binds[bindKey] = bind.Chatted:Connect(function(message)
				local args = { message }
				local chatCommand = context.Cmdr.Util.RunEmbeddedCommands(
					context.Dispatcher,
					context.Cmdr.Util.SubstituteArgs(command, args)
				)
				context:Reply(
					("%s $ %s : %s"):format(bind.Name, chatCommand, context.Dispatcher:EvaluateAndRun(chatCommand)),
					Color3.fromRGB(244, 92, 66)
				)
			end)
		end

		return nil
	end,
}
