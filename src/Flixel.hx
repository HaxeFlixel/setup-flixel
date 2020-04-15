import Command.ExitCode;
import OpenFL.Target;

@:publicFields class Flixel {
	static function buildProjects(target:Target, args:Array<String>):ExitCode {
		return Haxelib.run(["flixel-tools", "bp", target].concat(args).concat(["-Dno-deprecation-warnings"]));
	}
}