import Command.ExitCode;
import Main.LibVersion;

function run(args:Array<String>):ExitCode {
	return Command.run("haxelib", ["run"].concat(args));
}

function fromVersion(defaultUser:String, lib:String, version:LibVersion):ExitCode {
	return switch (version) {
		case Dev:
			Haxelib.git(defaultUser, lib);
		case Release | "" | null:
			Haxelib.install(lib);
		case version:
			Haxelib.install(lib, cast version);
	}
}

function install(lib:String, ?version:String):ExitCode {
	final args = ["install", lib];
	if (version != null) {
		args.push(version);
	}
	args.push("--quiet");
	args.push("--global");
	return Command.run("haxelib", args);
}

function git(user:String, haxelib:String, ?githubLib:String, ?branch:String, ?path:String):ExitCode {
	if (githubLib == null) {
		githubLib = haxelib;
	}
	final args = ["git", haxelib, 'https://github.com/$user/$githubLib'];
	if (branch != null) {
		args.push(branch);
	}
	if (path != null) {
		args.push(path);
	}
	args.push("--quiet");
	args.push("--global");
	return Command.run("haxelib", args);
}
