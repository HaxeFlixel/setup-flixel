import Command.ExitCode;

@:publicFields class Haxelib {
	static function run(args:Array<String>):ExitCode {
		return Command.run("haxelib", ["run"].concat(args));
	}

	static function install(lib:String, ?version:String):ExitCode {
		var args = ["install", lib];
		if (version != null) {
			args.push(version);
		}
		args.push("--quiet");
		return Command.run("haxelib", args);
	}

	static function git(user:String, lib:String, ?branch:String, ?path:String):ExitCode {
		var args = ["git", lib, 'https://github.com/$user/$lib'];
		if (branch != null) {
			args.push(branch);
		}
		if (path != null) {
			args.push(path);
		}
		args.push("--quiet");
		return Command.run("haxelib", args);
	}
}
