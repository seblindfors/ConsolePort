local _, db = ... 
db.PLUGINS["Classic Quest Log"] = function(ConsolePort)
	ConsolePort:AddFrame(ClassicQuestLog)
end