import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
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
	static function startGroup(name:String):Void;
	static function endGroup():Void;
}

class Main {
	static function main() {
		var haxeVersion:String = Core.getInput("haxe-version");
		var flixelVersions:FlixelVersions = Core.getInput("flixel-versions");
		var target:Target = Core.getInput("target");
		var runTests:Bool = Core.getInput("runTests");

		Core.startGroup("Installing Haxelibs");
		var installationResult = runUntilFailure([
			setupLix.bind(haxeVersion),
			installHaxelibs.bind(flixelVersions),
			installHxcpp.bind(target)
		]);
		if (installationResult != Success) {
			Sys.exit(Failure);
		}
		Core.endGroup();

		Core.startGroup("Listing Haxelibs");
		run("haxelib list");
		Core.endGroup();
	}

	static function setupLix(haxeVersion):ExitCode {
		Sys.command("lix scope");
		var path = Path.join([Sys.getEnv("HOME"), "haxe/.haxerc"]);
		if (!FileSystem.exists(path)) {
			return Failure;
		}
		File.saveContent(path, '{"version": "stable", "resolveLibs": "haxelib"}');
		return run('lix install haxe $haxeVersion --global');
	}

	static function installHaxelibs(flixelVersions):ExitCode {
		// @formatter:off
		var libs = [
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
		];
		// @formatter:on
		libs = libs.concat(if (flixelVersions == Dev) {
			[
				Haxelib.git.bind("HaxeFlixel", "flixel"),
				Haxelib.git.bind("HaxeFlixel", "flixel-tools"),
				Haxelib.git.bind("HaxeFlixel", "flixel-templates"),
				Haxelib.git.bind("HaxeFlixel", "flixel-demos"),
				Haxelib.git.bind("HaxeFlixel", "flixel-addons"),
				Haxelib.git.bind("HaxeFlixel", "flixel-ui"),
			];
		} else {
			[
				Haxelib.install.bind("flixel"),
				Haxelib.install.bind("flixel-tools"),
				Haxelib.install.bind("flixel-templates"),
				Haxelib.install.bind("flixel-demos"),
				Haxelib.install.bind("flixel-addons"),
				Haxelib.install.bind("flixel-ui")
			];
		});
		return runUntilFailure(libs);
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
