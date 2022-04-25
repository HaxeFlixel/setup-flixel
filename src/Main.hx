import Command;
import OpenFL.Target;
import actions.Core;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using StringTools;

enum abstract FlixelVersions(String) from String {
	final Dev = "dev";
	final Release = "release";
}

enum abstract HaxeVersion(String) from String to String {
	final Latest = "latest";
	final Stable = "stable";
	final Nightly = "nightly";
}

private final HaxelibRepo = Path.join([Sys.getEnv("HOME"), "haxe/haxelib"]);

function main() {
	final haxeVersion:HaxeVersion = Core.getInput("haxe-version");
	final flixelVersions:FlixelVersions = Core.getInput("flixel-versions");
	final target:Target = Core.getInput("target");
	final runTests:Bool = Core.getInput("run-tests") == "true";

	if (runTests) {
		if (target == Hl && haxeVersion.startsWith("3")) {
			return; // OpenFL's HL target and Haxe 3 don't work together
		}
	}

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
	Core.exportVariable("HAXELIB_REPO", HaxelibRepo);
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
		Core.startGroup("Test Preparation");
		cd(Path.join([HaxelibRepo, "flixel/git/tests"]));
		putEnv("HXCPP_SILENT", "1");
		putEnv("HXCPP_COMPILE_CACHE", Sys.getEnv("HOME") + "/hxcpp_cache");
		putEnv("HXCPP_CACHE_MB", "5000");
		Core.endGroup();

		Sys.exit(runAllNamed(Tests.make(target)));
	}
}

private function setupLix(haxeVersion):ExitCode {
	Sys.command("lix scope");
	final path = Path.join([Sys.getEnv("HOME"), "haxe/.haxerc"]);
	if (!FileSystem.exists(path)) {
		return Failure;
	}
	File.saveContent(path, '{"version": "stable", "resolveLibs": "haxelib"}');
	return run('lix install haxe $haxeVersion --global');
}

private function installHaxelibs(flixelVersions):ExitCode {
	// @formatter:off
	var libs = [
		Haxelib.install.bind("munit"), 
		Haxelib.git.bind("Geokureli", "hamcrest-haxe"), 
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

private function installHxcpp(target:Target):ExitCode {
	if (target != Cpp) {
		return Success;
	}
	final hxcppDir = Path.join([HaxelibRepo, "hxcpp/git/"]);
	return runAll([
		Haxelib.git.bind("HaxeFoundation", "hxcpp"),
		runInDir.bind(hxcppDir + "/tools/run", "haxe", ["compile.hxml"]),
		runInDir.bind(hxcppDir + "/tools/hxcpp", "haxe", ["compile.hxml"]),
	]);
}
