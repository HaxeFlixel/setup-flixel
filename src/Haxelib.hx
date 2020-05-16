import Command.ExitCode;

function run(args:Array<String>):ExitCode {
	return Command.run("haxelib", ["run"].concat(args));
}

function install(lib:String, ?version:String):ExitCode {
	final args = ["install", lib];
	if (version != null) {
		args.push(version);
	}
	args.push("--quiet");
	return Command.run("haxelib", args);
}

function git(user:String, lib:String, ?branch:String, ?path:String):ExitCode {
	final args = ["git", lib, 'https://github.com/$user/$lib'];
	if (branch != null) {
		args.push(branch);
	}
	if (path != null) {
		args.push(path);
	}
	args.push("--quiet");
	return Command.run("haxelib", args);
}
