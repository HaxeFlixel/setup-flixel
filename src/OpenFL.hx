import Command.ExitCode;

enum abstract Target(String) to String {
	var Flash = "flash";
	var Neko = "neko";
	var Cpp = "cpp";
	var Html5 = "html5";
}

@:publicFields class OpenFL {
	static function build(path:String, target:Target, ?define:String):ExitCode {
		return run("build", path, target, define);
	}

	static function run(operation:String, path:String, target:Target, ?define:String):ExitCode {
		var args = ["openfl", operation, path, target];
		if (define != null) {
			args.push('-D$define');
		}
		return Haxelib.run(args);
	}
}
