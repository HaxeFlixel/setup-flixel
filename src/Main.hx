import Command.ExitCode;
import Command.*;
import OpenFL.Target;

enum abstract FlixelVersions(String) {
	var Dev = "dev";
	var Release = "release";
}

@:jsRequire("@actions/core")
extern class Core {
	static function getInput(name:String):Dynamic;
}

class Main {
	static function main() {
		var haxeVersion:String = Core.getInput("haxe-version");
		var flixelVersions:FlixelVersions = Core.getInput("flixel-versions");
		var target:Target = Core.getInput("target");
		var runTests:Bool = Core.getInput("runTests");

		var installationResult = runUntilFailure([
			run.bind('lix install haxe $haxeVersion'),
			installHaxelibs,
			installHxcpp.bind(target)
		]);
		if (installationResult != Success) {
			Sys.exit(Failure);
		}
		run("haxelib list");
	}

	static function installHaxelibs():ExitCode {
		// @formatter:off
		return runUntilFailure([
			Haxelib.install.bind("munit"), 
			Haxelib.install.bind("systools"),
			Haxelib.install.bind("task"),
			Haxelib.install.bind("poly2trihx"),
			Haxelib.install.bind("nape-haxe4"),
			Haxelib.git.bind("HaxeFoundation", "hscript"),
			Haxelib.git.bind("larsiusprime", "firetongue"),
			Haxelib.git.bind("bendmorris", "spinehaxe"),
			Haxelib.git.bind("larsiusprime", "steamwrap"),

			Haxelib.install.bind("openfl"),
			Haxelib.install.bind("lime"),

			Haxelib.git.bind("HaxeFlixel", "flixel-tools"),
			Haxelib.git.bind("HaxeFlixel", "flixel-templates"),
			Haxelib.git.bind("HaxeFlixel", "flixel-demos"),
			Haxelib.git.bind("HaxeFlixel", "flixel-addons"),
			Haxelib.git.bind("HaxeFlixel", "flixel-ui"),
		]);
		// @formatter:on
	}

	static function installHxcpp(target:Target):ExitCode {
		if (target != Cpp) {
			return Success;
		}
		var hxcppDir = Sys.getEnv("HOME") + "/haxe/lib/hxcpp/git/";
		return runAll([
			Haxelib.git.bind("HaxeFoundation", "hxcpp"),
			runInDir.bind(hxcppDir + "tools/run", "haxe", ["compile.hxml"]),
			runInDir.bind(hxcppDir + "tools/hxcpp", "haxe", ["compile.hxml"]),
		]);
	}
}
