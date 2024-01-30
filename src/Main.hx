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

enum abstract TestLocation(String) from String {
	final Local = "local";
	final Git = "git";
}

enum abstract HaxeVersion(String) from String to String {
	final Latest = "latest";
	final Stable = "stable";
	final Nightly = "nightly";
	// use the version already installed (no lix)
	final Current = "current";
}

private final HaxelibRepo = Path.join([Sys.getEnv("HOME"), "haxe/haxelib"]);

function main() {
	final haxeVersion:HaxeVersion = Core.getInput("haxe-version");
	final flixelVersions:FlixelVersions = Core.getInput("flixel-versions");
	final testLocation:TestLocation = Core.getInput("test-location");
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
		run.bind("sudo add-apt-repository ppa:haxe/snapshots -y"), // for nekotools
		run.bind("sudo apt-get install --fix-missing"), // for nekotools
		run.bind("sudo apt-get upgrade"), // for nekotools
		run.bind("sudo apt-get install neko -y"), // for nekotools
		// run.bind("haxelib install haxelib 4.0.3"), // 4.1.0 is failing on unit tests
		installHaxelibs.bind(flixelVersions),
		installHxcpp.bind(target)
	]);
	if (installationResult != Success) {
		Sys.exit(Failure);
	}
	Core.exportVariable("HAXELIB_REPO", HaxelibRepo);
	Core.endGroup();

	Core.startGroup("Listing Dependencies");
	if (haxeVersion != Current)
		run("lix -v");
	run("haxe -version");
	run("neko -version");
	run("haxelib version");
	run("haxelib config");
	run("haxelib fixrepo");
	run("haxelib list");
	Core.endGroup();

	if (runTests) {
		Core.startGroup("Test Preparation");

		if (testLocation == Local)
			// When testing changes to flixel, flixel is set to the dev version
			cd("tests");
		else
			// otherwise use git version
			cd(Path.join([HaxelibRepo, "flixel/git/tests"]));

		putEnv("HXCPP_SILENT", "1");
		putEnv("HXCPP_COMPILE_CACHE", Sys.getEnv("HOME") + "/hxcpp_cache");
		putEnv("HXCPP_CACHE_MB", "5000");
		Core.endGroup();

		Sys.exit(runAllNamed(Tests.make(target)));
	}
}

private function setupLix(haxeVersion):ExitCode {
	if (haxeVersion == Current)
		return Success;

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
		// TODO: fix git version failing on nightly
		// Haxelib.git.bind("massive-oss", "munit", "MassiveUnit", "master", "src"),
		Haxelib.git.bind("GeoKureli", "munit", "MassiveUnit", "haxe4-3", "src"),
		Haxelib.git.bind("GeoKureli", "hamcrest", "hamcrest-haxe", "master", "src"), 
		Haxelib.install.bind("systools"),
		Haxelib.install.bind("task"),
		Haxelib.install.bind("poly2trihx"),
		Haxelib.install.bind("nape-haxe4"),
		Haxelib.install.bind("haxeui-core"),
		Haxelib.install.bind("haxeui-flixel"),
		Haxelib.git.bind("HaxeFoundation", "hscript"),
		Haxelib.git.bind("larsiusprime", "firetongue"),
		Haxelib.git.bind("Geokureli", "spinehaxe", "spinehaxe", "haxe4.3.1"),
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
