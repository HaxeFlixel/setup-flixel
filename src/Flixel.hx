import Command.ExitCode;
import OpenFL.Target;

function buildProjects(target:Target, args:Array<String>):ExitCode {
	return Haxelib.run(["flixel-tools", "bp", target].concat(args).concat(["-Dno-deprecation-warnings"]));
}
