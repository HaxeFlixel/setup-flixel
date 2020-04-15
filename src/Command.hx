enum abstract ExitCode(Int) from Int to Int {
	final Success = 0;
	final Failure = 1;
}

typedef NamedExecution = {
	final name:String;
	final run:() -> ExitCode;
	final ?active:Bool;
}

@:publicFields class Command {
	static final dryRun:Bool = false;

	static function runInDir(dir:String, cmd:String, args:Array<String>):ExitCode {
		return runCallbackInDir(dir, run.bind(cmd, args));
	}

	static function runCallbackInDir(dir:String, func:() -> ExitCode):ExitCode {
		final oldCwd = Sys.getCwd();
		cd(dir);
		final result = func();
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

	static function runAllNamed(methods:Array<NamedExecution>):ExitCode {
		var result = Success;
		for (method in methods) {
			if (!method.active) {
				continue;
			}
			Core.startGroup(method.name);
			if (method.run() != Success) {
				result = Failure;
			}
			Core.endGroup();
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

	static function putEnv(s:String, v:String) {
		Sys.println('Sys.putEnv("$s", "$v")');
		if (!dryRun) {
			Sys.putEnv(s, v);
		}
	}
}
