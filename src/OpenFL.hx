import Command.ExitCode;

enum abstract Target(String) from String to String {
	final Flash = "flash";
	final Neko = "neko";
	final Cpp = "cpp";
	final Html5 = "html5";
	final Hl = "hl";
}

@:publicFields class OpenFL {
	static function build(path:String, target:Target, ?define:String):ExitCode {
		return run("build", path, target, define);
	}

	static function run(operation:String, path:String, target:Target, ?define:String):ExitCode {
		final args = ["openfl", operation, path, target];
		if (define != null) {
			args.push('-D$define');
		}
		return Haxelib.run(args);
	}
}
