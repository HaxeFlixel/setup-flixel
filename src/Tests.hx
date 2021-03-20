import Command;
import OpenFL.Target;

private final ImportantDemos = ["Mode"];

function make(target):Array<NamedExecution> {
	return [
		{
			name: "Running Unit Tests",
			run: runUnitTests.bind(target),
			active: true
		},
		{
			name: "Building Coverage Tests",
			run: buildCoverageTests.bind(target),
			active: true
		},
		{
			name: "Building SWF Version Tests",
			run: buildSwfVersionTests.bind(target),
			active: target == Flash
		},
		{
			name: "Building flixel-demos",
			run: buildDemos.bind(target, if (target == Cpp) ImportantDemos else []),
			active: true
		},
		{
			name: "Building snippets.haxeflixel.com Demos",
			run: buildSnippetsDemos.bind(target),
			active: target != Cpp
		}
	];
}

private function runUnitTests(target:Target):ExitCode {
	runCallbackInDir("unit", Haxelib.run.bind(["munit", "gen"]));

	if (target == Cpp) {
		Sys.println("Running unit tests...\n");
		return OpenFL.run("test", "unit", target, "travis");
	} else {
		// can't run / display results without a browser,
		// this at least checks if the tests compile
		// also, neko fails randomly for some reason... (#2148)
		Sys.println("Building unit tests...\n");
		return OpenFL.build("unit", target);
	}
}

private function buildCoverageTests(target:Target):ExitCode {
	Sys.println("\nBuilding coverage tests...\n");
	return runAll([
		OpenFL.build.bind("coverage", target, "coverage1"),
		OpenFL.build.bind("coverage", target, "coverage2")
	]);
}

private function buildDemos(target:Target, demos):ExitCode {
	Sys.println("\nBuilding demos...\n");
	return Flixel.buildProjects(target, demos);
}

private function buildSnippetsDemos(target:Target):ExitCode {
	Sys.println("\nBuilding mechanics demos...\n");
	run("git", ["clone", "https://github.com/HaxeFlixel/haxeflixel-mechanics"]);

	return Flixel.buildProjects(target, ["-dir", "haxeflixel-mechanics"]);
}

private function buildSwfVersionTests(target:Target):ExitCode {
	Sys.println("\nBuilding swf version tests...\n");
	return runAll([
		OpenFL.build.bind("swfVersion/11", target),
		OpenFL.build.bind("swfVersion/11_2", target)
	]);
}
