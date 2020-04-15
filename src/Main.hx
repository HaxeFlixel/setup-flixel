import Command.*;
import Command.ExitCode;
import OpenFL.Target;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

enum abstract FlixelVersions(String) {
	final Dev = "dev";
	final Release = "release";
}

class Main {
	static function main() {
		final haxeVersion:String = Core.getInput("haxe-version");
		final flixelVersions:FlixelVersions = Core.getInput("flixel-versions");
		final target:Target = Core.getInput("target");
		final runTests:Bool = Core.getInput("runTests");

		Core.startGroup("Installing Haxe Dependencies");
		final installationResult = runUntilFailure([
			setupLix.bind(haxeVersion),
			run.bind("sudo apt install neko"), // for nekotools
			installHaxelibs.bind(flixelVersions),
			installHxcpp.bind(target)
		]);
		if (installationResult != Success) {
			Sys.exit(Failure);
		}
		final haxelibRepo = Path.join([Sys.getEnv("HOME"), "haxe/haxelib"]);
		Core.exportVariable("HAXELIB_REPO", haxelibRepo);
		Core.endGroup();

		Core.startGroup("Listing Dependencies");
		run("lix -v");
		run("haxe -version");
		run("neko -version");
		run("haxelib version");
		run("haxelib config");
		run("haxelib list");
		Core.endGroup();

		if (runTests) {
			cd(Path.join([haxelibRepo, "flixel/git"]));

			putEnv("HXCPP_SILENT", "1");
			putEnv("HXCPP_COMPILE_CACHE", Sys.getEnv("HOME") + "/hxcpp_cache");
			putEnv("HXCPP_CACHE_MB", "5000");

			Sys.exit(runAllNamed(Tests.make(target)));
		}
	}

	static function setupLix(haxeVersion):ExitCode {
		Sys.command("lix scope");
		final path = Path.join([Sys.getEnv("HOME"), "haxe/.haxerc"]);
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
		final hxcppDir = Sys.getEnv("HOME") + "/haxe/lib/hxcpp/git/";
		return runAll([
			Haxelib.git.bind("HaxeFoundation", "hxcpp"),
			runInDir.bind(hxcppDir + "tools/run", "haxe", ["compile.hxml"]),
			runInDir.bind(hxcppDir + "tools/hxcpp", "haxe", ["compile.hxml"]),
		]);
	}
}
