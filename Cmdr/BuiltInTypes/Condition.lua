return function(registry)
	registry:RegisterType("condition", registry.Cmdr.Util.MakeEnumType("Condition", {">=", ">", "<", "<=", "!=", "==", "startsWith"}))
end