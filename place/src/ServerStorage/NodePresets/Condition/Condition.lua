local Condition = {}

--[[

INSTRUCTIONS

Every node has a priority value. It is the number that is displayed on the top right corner of the node. This is what is used to select which node the condition unlocks.

To select a node with a condition, you must return a number equal to the target node's priority. For example:

Let's say I had two prompt nodes both with different priorities. One has a priority of 1, and the other a priority of 2. Now let's say I wanted the condition to unlock one or the other randomly.
In that case, I would simply return math.random(1,2) inside the Module.Run() function.

Note: Condition nodes connect from the primary output to inputs.

]]

function Condition.Run()
	return 1 --Selects a node with a priority of 1
end

return Condition
