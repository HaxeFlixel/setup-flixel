import Command;
import Main;
import OpenFL.Target;

private final CppDemos = ["Mode", "Flixius", "MinimalistTD", "TurnBasedRPG"];

function make(target):Array<NamedExecution>
{
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
			run: buildDemos.bind(target),
			active: true
		},
		{
			name: "Building snippets.haxeflixel.com Demos",
			run: buildSnippetsDemos.bind(target),
			active: target != Cpp
		}
	];
}

private function runUnitTests(target:Target):ExitCode
{
	runCallbackInDir("unit", Haxelib.run.bind(["munit", "gen"]));
	
	// can't run / display results without a browser,
	// this at least checks if the tests compile
	// also, neko fails randomly for some reason... (#2148)
	var runTests = target == Cpp;
	
	if (runTests)
	{
		Sys.println("Running unit tests...\n");
		return OpenFL.run("test", "unit", target, "travis");
	}
	else
	{
		Sys.println('Cannot run tests on $target, building instead\n');
		Sys.println("Building unit tests...\n");
		return OpenFL.build("unit", target);
	}
}

private function buildCoverageTests(target:Target):ExitCode
{
	Sys.println("\nBuilding coverage tests...\n");
	return runAll([
		OpenFL.build.bind("coverage", target, "coverage1"),
		OpenFL.build.bind("coverage", target, "coverage2"),
		OpenFL.build.bind("coverage", target, "coverage3")
	]);
}

private function buildDemos(target:Target, ?demos:Array<String>, ?args:Array<String>):ExitCode
{
	args = args ?? [];
	if (demos != null)
	{
		Sys.println('\nBuilding ${demos.length} demo(s)...\n');
	}
	else if (target == Cpp)
	{
		demos = CppDemos;
		Sys.println('\nSkipping some demos due to cpp build times\nBuilding ${demos.length} demo(s)...\n');
		// args.push('-DHXCPP_COMPILE_CACHE=\'${Sys.getEnv("HOME") + "/hxcpp_cache"}\''); // Already added to env in Main
	}
	else
	{
		Sys.println('\nBuilding all demos...\n');
		demos = [];
	}
	return Flixel.buildProjects(target, demos.concat(args));
}

private function buildSnippetsDemos(target:Target):ExitCode
{
	Sys.println("\nBuilding spnippets demos...\n");
	run("git", ["clone", "https://github.com/HaxeFlixel/snippets.haxeflixel.com"]);
	
	return Flixel.buildProjects(target, ["-dir", "snippets.haxeflixel.com"]);
}

private function buildSwfVersionTests(target:Target):ExitCode
{
	Sys.println("\nBuilding swf version tests...\n");
	return runAll([
		OpenFL.build.bind("swfVersion/11", target),
		OpenFL.build.bind("swfVersion/11_2", target)
	]);
}
