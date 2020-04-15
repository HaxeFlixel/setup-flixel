@:jsRequire("@actions/core")
extern class Core {
	static function getInput(name:String):Dynamic;
	static function startGroup(name:String):Void;
	static function endGroup():Void;
	static function exportVariable(name:String, val:String):Void;
}
