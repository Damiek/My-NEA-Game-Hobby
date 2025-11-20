local RS= game:GetService("ReplicatedStorage")

task.wait(10)
RS:FindFirstChild("DialogueRemote",true):FireAllClients(RS.Dialogues.Dialogue_Configs.TestDialogue)