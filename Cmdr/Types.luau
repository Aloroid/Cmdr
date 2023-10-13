export type Cmdr = {
	Registry: Registry,
	Dispatcher: Dispatcher,
	Util: Util,
} & Registry

export type CmdrServer = Cmdr & {
	Registry: RegistryServer,
	Dispatcher: DispatcherServer,
} & RegistryServer

export type CmdrClient = Cmdr & {

	Registry: RegistryClient,
	Dispatcher: DispatcherClient,

	Enabled: boolean,
	PlaceName: string,
	ActivationKeys: { [Enum.KeyCode]: boolean },

	SetActivationKeys: (CmdrClient, keys: { Enum.KeyCode }) -> (),
	SetPlaceName: (CmdrClient, labelText: string) -> (),
	SetEnabled: (CmdrClient, isEnabled: boolean) -> (),
	SetMashToEnable: (CmdrClient, isEnabled: boolean) -> (),
	SetActivationUnlocksMouse: (CmdrClient, isEnabled: boolean) -> (),
	SetHideOnLostFocus: (CmdrClient, isEnabled: boolean) -> (),

	Show: (CmdrClient) -> (),
	Hide: (CmdrClient) -> (),
	Toggle: (CmdrClient) -> (),

	HandleEvent: (CmdrClient, event: string, callback: (...unknown) -> ()) -> (),
} & RegistryClient

export type CommandContext = {
	Cmdr: Cmdr | CmdrClient,
	Dispatcher: Dispatcher,
	Name: string,
	Alias: string,
	RawText: string,
	Group: unknown,
	State: { [unknown]: unknown },
	Aliases: { string },
	Description: string,
	Executor: Player,
	RawArguments: { ArgumentContext },
	Response: string?,

	GetArgument: (CommandContext, index: number) -> ArgumentContext,
	GetData: (CommandContext) -> unknown,
	GetStore: (CommandContext, name: string) -> { [unknown]: unknown },
	SendEvent: (CommandContext, player: Player, event: string, ...unknown) -> (),
	BroadcastEvent: (CommandContext, event: string, ...unknown) -> (),
	Reply: (CommandContext, text: string, color: Color3?) -> (),
	HasImplementation: (CommandContext) -> boolean,
}

export type TypeDefinition<T> = {

	DisplayName: string?,
	Prefixes: string?,

	Transform: ((rawText: string, executor: Player) -> T)?,
	Validate: ((value: T) -> (boolean, string?))?,
	ValidateOnce: ((value: T) -> (boolean, string?))?,
	Autocomplete: ((value: T) -> ({ string }, { IsPartial: boolean? }?))?,
	Parse: (value: T) -> unknown,
	Default: ((player: Player) -> string)?,
	Listable: boolean?,
}

type CommandArgument = {

	Type: string | TypeDefinition<unknown>,
	Name: string,
	Description: string,
	Optional: boolean?,
	Default: unknown?,
}

export type CommandDefinition = {

	Name: string,
	Aliases: { string },
	Description: string,
	Group: unknown?,
	Args: { CommandArgument | (context: CommandContext) -> CommandArgument },

	Data: ((context: CommandContext, ...unknown) -> unknown)?,
	ClientRun: ((context: CommandContext, ...unknown) -> string?)?,
	AutoExec: { string },
}

type ArgumentContext = {

	Command: CommandContext,
	Name: string,
	Type: TypeDefinition<unknown>,
	Required: boolean,
	Executor: Player,
	RawValue: string,
	RawSegments: { string },
	Prefix: string,

	GetValue: (ArgumentContext) -> unknown,
	GetTransformedValue: (segment: number) -> ...unknown,
}

type NamedObject = {
	Name: string,
}

type Dispatcher = {
	Cmdr: Cmdr | CmdrClient,

	EvaluateAndRun: (
		Dispatcher,
		commandText: string,
		executor: Player,
		options: {
			Data: unknown?,
			IsHuman: boolean,
		}?
	) -> string,
}

type DispatcherServer = Dispatcher & {
	Cmdr: Cmdr,
}

type DispatcherClient = Dispatcher & {
	Cmdr: CmdrClient,

	Run: (Dispatcher, ...string) -> string,
	RunDeferred: (Dispatcher, ...string) -> (),
	EvaluateAndRun: (
		Dispatcher,
		commandText: string,
		executor: Player?,
		options: {
			Data: unknown?,
			IsHuman: boolean,
		}?
	) -> string,
	GetHistory: (Dispatcher) -> { string },
}

type Registry = {
	Cmdr: Cmdr | CmdrClient,

	RegisterType: <T>(Registry, name: string, typeDefinition: TypeDefinition<T>) -> (),
	RegisterTypePrefix: (Registry, name: string, union: string) -> (),
	RegisterTypeAlias: (Registry, name: string, union: string) -> (),
	GetType: <T>(Registry, name: string) -> TypeDefinition<T>?,
	GetTypeName: (Registry, name: string) -> string,

	GetCommand: (Registry, name: string) -> CommandDefinition,
	GetCommands: (Registry) -> { CommandDefinition },
	GetCommandNames: (Registry) -> { string },

	RegisterHook: (
		Registry,
		hookName: "BeforeRun" | "AfterRun",
		callback: (context: CommandContext) -> string?,
		priority: number?
	) -> (),
	GetStore: (Registry, name: string) -> {},
}

type RegistryServer = Registry & {
	Cmdr: Cmdr,

	RegisterTypesIn: (RegistryServer, container: Instance) -> (),
	RegisterHooksIn: (RegistryServer, container: Instance) -> (),

	RegisterCommandsIn: (RegistryServer, container: Instance, filter: ((command: CommandDefinition) -> boolean)?) -> (),
	RegisterCommand: (
		RegistryServer,
		commandScript: ModuleScript,
		commandServerScript: ModuleScript,
		filter: ((command: CommandDefinition) -> boolean)?
	) -> (),
	RegisterDefaultCommands: ((RegistryServer, groups: { string }?) -> ())
		& ((RegistryServer, filter: ((command: CommandDefinition) -> boolean)?) -> ()),
}

type RegistryClient = Registry & {
	Cmdr: CmdrClient,
}

type Util = {
	MakeDictionary: <T>(array: { T }) -> { [T]: true },
	Map: <T, U>({ T }, mapper: (value: T, index: number) -> U) -> { U },
	Each: <T..., U...>(mapper: (T...) -> U...) -> U...,
	MakeFuzzyFinder: (
		set: { string } | { Instance } | { EnumItem } | { NamedObject } | Instance
	) -> (text: string, returnFirst: boolean?) -> { unknown },
	GetNames: (instances: { NamedObject }) -> { string },
	SplitStringSimple: (text: string, separator: string) -> { string },
	SplitString: (text: string, max: number?) -> { string },
	TrimString: (text: string) -> string,
	GetTextSize: (text: string, label: TextLabel, size: Vector2?) -> Vector2,
	MakeEnumType: (type: string, values: { string | NamedObject }) -> TypeDefinition<string>,
	MakeListableType: <T, U>(
		typeDefinition: TypeDefinition<T>,
		override: { [string]: unknown }?
	) -> TypeDefinition<{ T }>,
	MakeSequenceType: <T, U>(
		options: {
			Transform: ((rawText: string, player: Player) -> U)?,
			ValidateEach: ((value: U) -> (boolean, string?))?,

			Parse: (({ U }) -> T)?,
			Constructor: ((...U) -> T)?,
		}
	) -> TypeDefinition<T>,
	SplitPrioritizedDelimeter: (text: string, delimiters: { string }) -> { string },
	SubstituteArgs: (text: string, replace: { string } | { [string]: string } | (string) -> string) -> string,
	RunEmbeddedCommands: (dispatcher: Dispatcher, commandString: string) -> string,
	EmulateTabstops: (text: string, tabWidth: number) -> string,
	ParseEscapeSequences: (text: string) -> string,
	MakeType: <T>(definition: TypeDefinition<T>) -> TypeDefinition<T>,
}

return nil
