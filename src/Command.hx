enum abstract ExitCode(Int) from Int to Int {
	var Success = 0;
	var Failure = 1;
}

@:publicFields class Command {
	static var dryRun:Bool = false;

	static function runInDir(dir:String, cmd:String, args:Array<String>):ExitCode {
		return runCallbackInDir(dir, run.bind(cmd, args));
	}

	static function runCallbackInDir(dir:String, func:() -> ExitCode):ExitCode {
		var oldCwd = Sys.getCwd();
		cd(dir);
		var result = func();
		cd(oldCwd);
		return result;
	}

	static function cd(dir:String) {
		Sys.println("cd " + dir);
		if (!dryRun) {
			Sys.setCwd(dir);
		}
	}

	static function runUntilFailure(methods:Array<() -> ExitCode>):ExitCode {
		for (method in methods) {
			if (method() != Success) {
				return Failure;
			}
		}
		return Success;
	}

	static function runAll(methods:Array<() -> ExitCode>):ExitCode {
		var result = Success;
		for (method in methods) {
			if (method() != Success) {
				result = Failure;
			}
		}
		return result;
	}

	static function run(cmd:String, ?args:Array<String>):ExitCode {
		Sys.println("> " + cmd + " " + (if (args == null) "" else args.join(" ")));
		if (dryRun) {
			return ExitCode.Success;
		}
		return Sys.command(cmd, args);
	}
}
