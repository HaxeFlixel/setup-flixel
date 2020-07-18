// Generated by Haxe 4.2.0-rc.1
module.exports =
/******/ (function(modules, runtime) { // webpackBootstrap
/******/ 	"use strict";
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	__webpack_require__.ab = __dirname + "/";
/******/
/******/ 	// the startup function
/******/ 	function startup() {
/******/ 		// Load entry module and return exports
/******/ 		return __webpack_require__(475);
/******/ 	};
/******/
/******/ 	// run startup
/******/ 	return startup();
/******/ })
/************************************************************************/
/******/ ({

/***/ 87:
/***/ (function(module) {

module.exports = require("os");

/***/ }),

/***/ 129:
/***/ (function(module) {

module.exports = require("child_process");

/***/ }),

/***/ 431:
/***/ (function(__unusedmodule, exports, __webpack_require__) {

"use strict";

var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const os = __importStar(__webpack_require__(87));
/**
 * Commands
 *
 * Command Format:
 *   ::name key=value,key=value::message
 *
 * Examples:
 *   ::warning::This is the message
 *   ::set-env name=MY_VAR::some value
 */
function issueCommand(command, properties, message) {
    const cmd = new Command(command, properties, message);
    process.stdout.write(cmd.toString() + os.EOL);
}
exports.issueCommand = issueCommand;
function issue(name, message = '') {
    issueCommand(name, {}, message);
}
exports.issue = issue;
const CMD_STRING = '::';
class Command {
    constructor(command, properties, message) {
        if (!command) {
            command = 'missing.command';
        }
        this.command = command;
        this.properties = properties;
        this.message = message;
    }
    toString() {
        let cmdStr = CMD_STRING + this.command;
        if (this.properties && Object.keys(this.properties).length > 0) {
            cmdStr += ' ';
            let first = true;
            for (const key in this.properties) {
                if (this.properties.hasOwnProperty(key)) {
                    const val = this.properties[key];
                    if (val) {
                        if (first) {
                            first = false;
                        }
                        else {
                            cmdStr += ',';
                        }
                        cmdStr += `${key}=${escapeProperty(val)}`;
                    }
                }
            }
        }
        cmdStr += `${CMD_STRING}${escapeData(this.message)}`;
        return cmdStr;
    }
}
function escapeData(s) {
    return (s || '')
        .replace(/%/g, '%25')
        .replace(/\r/g, '%0D')
        .replace(/\n/g, '%0A');
}
function escapeProperty(s) {
    return (s || '')
        .replace(/%/g, '%25')
        .replace(/\r/g, '%0D')
        .replace(/\n/g, '%0A')
        .replace(/:/g, '%3A')
        .replace(/,/g, '%2C');
}
//# sourceMappingURL=command.js.map

/***/ }),

/***/ 470:
/***/ (function(__unusedmodule, exports, __webpack_require__) {

"use strict";

var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = __webpack_require__(431);
const os = __importStar(__webpack_require__(87));
const path = __importStar(__webpack_require__(622));
/**
 * The code to exit an action
 */
var ExitCode;
(function (ExitCode) {
    /**
     * A code indicating that the action was successful
     */
    ExitCode[ExitCode["Success"] = 0] = "Success";
    /**
     * A code indicating that the action was a failure
     */
    ExitCode[ExitCode["Failure"] = 1] = "Failure";
})(ExitCode = exports.ExitCode || (exports.ExitCode = {}));
//-----------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------
/**
 * Sets env variable for this action and future actions in the job
 * @param name the name of the variable to set
 * @param val the value of the variable
 */
function exportVariable(name, val) {
    process.env[name] = val;
    command_1.issueCommand('set-env', { name }, val);
}
exports.exportVariable = exportVariable;
/**
 * Registers a secret which will get masked from logs
 * @param secret value of the secret
 */
function setSecret(secret) {
    command_1.issueCommand('add-mask', {}, secret);
}
exports.setSecret = setSecret;
/**
 * Prepends inputPath to the PATH (for this action and future actions)
 * @param inputPath
 */
function addPath(inputPath) {
    command_1.issueCommand('add-path', {}, inputPath);
    process.env['PATH'] = `${inputPath}${path.delimiter}${process.env['PATH']}`;
}
exports.addPath = addPath;
/**
 * Gets the value of an input.  The value is also trimmed.
 *
 * @param     name     name of the input to get
 * @param     options  optional. See InputOptions.
 * @returns   string
 */
function getInput(name, options) {
    const val = process.env[`INPUT_${name.replace(/ /g, '_').toUpperCase()}`] || '';
    if (options && options.required && !val) {
        throw new Error(`Input required and not supplied: ${name}`);
    }
    return val.trim();
}
exports.getInput = getInput;
/**
 * Sets the value of an output.
 *
 * @param     name     name of the output to set
 * @param     value    value to store
 */
function setOutput(name, value) {
    command_1.issueCommand('set-output', { name }, value);
}
exports.setOutput = setOutput;
//-----------------------------------------------------------------------
// Results
//-----------------------------------------------------------------------
/**
 * Sets the action status to failed.
 * When the action exits it will be with an exit code of 1
 * @param message add error issue message
 */
function setFailed(message) {
    process.exitCode = ExitCode.Failure;
    error(message);
}
exports.setFailed = setFailed;
//-----------------------------------------------------------------------
// Logging Commands
//-----------------------------------------------------------------------
/**
 * Gets whether Actions Step Debug is on or not
 */
function isDebug() {
    return process.env['RUNNER_DEBUG'] === '1';
}
exports.isDebug = isDebug;
/**
 * Writes debug message to user log
 * @param message debug message
 */
function debug(message) {
    command_1.issueCommand('debug', {}, message);
}
exports.debug = debug;
/**
 * Adds an error issue
 * @param message error issue message
 */
function error(message) {
    command_1.issue('error', message);
}
exports.error = error;
/**
 * Adds an warning issue
 * @param message warning issue message
 */
function warning(message) {
    command_1.issue('warning', message);
}
exports.warning = warning;
/**
 * Writes info to log with console.log.
 * @param message info message
 */
function info(message) {
    process.stdout.write(message + os.EOL);
}
exports.info = info;
/**
 * Begin an output group.
 *
 * Output until the next `groupEnd` will be foldable in this group
 *
 * @param name The name of the output group
 */
function startGroup(name) {
    command_1.issue('group', name);
}
exports.startGroup = startGroup;
/**
 * End an output group.
 */
function endGroup() {
    command_1.issue('endgroup');
}
exports.endGroup = endGroup;
/**
 * Wrap an asynchronous function call in a group.
 *
 * Returns the same type as the function itself.
 *
 * @param name The name of the group
 * @param fn The function to wrap in the group
 */
function group(name, fn) {
    return __awaiter(this, void 0, void 0, function* () {
        startGroup(name);
        let result;
        try {
            result = yield fn();
        }
        finally {
            endGroup();
        }
        return result;
    });
}
exports.group = group;
//-----------------------------------------------------------------------
// Wrapper action state
//-----------------------------------------------------------------------
/**
 * Saves state for current action, the state can only be retrieved by this action's post job execution.
 *
 * @param     name     name of the state to store
 * @param     value    value to store
 */
function saveState(name, value) {
    command_1.issueCommand('save-state', { name }, value);
}
exports.saveState = saveState;
/**
 * Gets the value of an state set by this action's main execution.
 *
 * @param     name     name of the state to get
 * @returns   string
 */
function getState(name) {
    return process.env[`STATE_${name}`] || '';
}
exports.getState = getState;
//# sourceMappingURL=core.js.map

/***/ }),

/***/ 475:
/***/ (function(__unusedmodule, __unusedexports, __webpack_require__) {

// Generated by Haxe 4.2.0-rc.1+f3b99c429
(function ($global) { "use strict";
function Command_runInDir(dir,cmd,args) {
	let cmd1 = cmd;
	let args1 = args;
	return Command_runCallbackInDir(dir,function() {
		return Command_run(cmd1,args1);
	});
}
function Command_runCallbackInDir(dir,func) {
	let oldCwd = process.cwd();
	Command_cd(dir);
	let result = func();
	Command_cd(oldCwd);
	return result;
}
function Command_cd(dir) {
	process.stdout.write(Std.string("cd " + dir));
	process.stdout.write("\n");
	if(!Command_dryRun) {
		process.chdir(dir);
	}
}
function Command_runUntilFailure(methods) {
	let _g = 0;
	while(_g < methods.length) if(methods[_g++]() != 0) {
		return 1;
	}
	return 0;
}
function Command_runAll(methods) {
	let result = 0;
	let _g = 0;
	while(_g < methods.length) if(methods[_g++]() != 0) {
		result = 1;
	}
	return result;
}
function Command_runAllNamed(methods) {
	let result = 0;
	let _g = 0;
	while(_g < methods.length) {
		let method = methods[_g];
		++_g;
		if(!method.active) {
			continue;
		}
		actions_Core.startGroup(method.name);
		if(method.run() != 0) {
			result = 1;
		}
		actions_Core.endGroup();
	}
	return result;
}
function Command_run(cmd,args) {
	let v = args == null ? "" : args.join(" ");
	process.stdout.write(Std.string("> " + cmd + " " + v));
	process.stdout.write("\n");
	if(Command_dryRun) {
		return 0;
	}
	if(args == null) {
		return js_node_ChildProcess.spawnSync(cmd,{ shell : true, stdio : "inherit"}).status;
	} else {
		return js_node_ChildProcess.spawnSync(cmd,args,{ stdio : "inherit"}).status;
	}
}
function Command_putEnv(s,v) {
	process.stdout.write(Std.string("Sys.putEnv(\"" + s + "\", \"" + v + "\")"));
	process.stdout.write("\n");
	if(!Command_dryRun) {
		process.env[s] = v;
	}
}
function Flixel_buildProjects(target,args) {
	return Haxelib_run(["flixel-tools","bp",target].concat(args).concat(["-Dno-deprecation-warnings"]));
}
function Haxelib_run(args) {
	return Command_run("haxelib",["run"].concat(args));
}
function Haxelib_install(lib,version) {
	let args = ["install",lib];
	if(version != null) {
		args.push(version);
	}
	args.push("--quiet");
	return Command_run("haxelib",args);
}
function Haxelib_git(user,lib,branch,path) {
	let args = ["git",lib,"https://github.com/" + user + "/" + lib];
	if(branch != null) {
		args.push(branch);
	}
	if(path != null) {
		args.push(path);
	}
	args.push("--quiet");
	return Command_run("haxelib",args);
}
class HxOverrides {
	static cca(s,index) {
		let x = s.charCodeAt(index);
		if(x != x) {
			return undefined;
		}
		return x;
	}
	static now() {
		return Date.now();
	}
}
HxOverrides.__name__ = true;
class haxe_io_Path {
	static join(paths) {
		let _g = [];
		let _g1 = 0;
		while(_g1 < paths.length) {
			let v = paths[_g1];
			++_g1;
			if(v != null && v != "") {
				_g.push(v);
			}
		}
		if(_g.length == 0) {
			return "";
		}
		let path = _g[0];
		let _g2 = 1;
		let _g3 = _g.length;
		while(_g2 < _g3) {
			path = haxe_io_Path.addTrailingSlash(path);
			path += _g[_g2++];
		}
		return haxe_io_Path.normalize(path);
	}
	static normalize(path) {
		let slash = "/";
		path = path.split("\\").join(slash);
		if(path == slash) {
			return slash;
		}
		let target = [];
		let _g = 0;
		let _g1 = path.split(slash);
		while(_g < _g1.length) {
			let token = _g1[_g];
			++_g;
			if(token == ".." && target.length > 0 && target[target.length - 1] != "..") {
				target.pop();
			} else if(token == "") {
				if(target.length > 0 || HxOverrides.cca(path,0) == 47) {
					target.push(token);
				}
			} else if(token != ".") {
				target.push(token);
			}
		}
		let acc_b = "";
		let colon = false;
		let slashes = false;
		let _g2_offset = 0;
		let _g2_s = target.join(slash);
		while(_g2_offset < _g2_s.length) {
			let s = _g2_s;
			let index = _g2_offset++;
			let c = s.charCodeAt(index);
			if(c >= 55296 && c <= 56319) {
				c = c - 55232 << 10 | s.charCodeAt(index + 1) & 1023;
			}
			let c1 = c;
			if(c1 >= 65536) {
				++_g2_offset;
			}
			let c2 = c1;
			switch(c2) {
			case 47:
				if(!colon) {
					slashes = true;
				} else {
					let i = c2;
					colon = false;
					if(slashes) {
						acc_b += "/";
						slashes = false;
					}
					acc_b += String.fromCodePoint(i);
				}
				break;
			case 58:
				acc_b += ":";
				colon = true;
				break;
			default:
				let i = c2;
				colon = false;
				if(slashes) {
					acc_b += "/";
					slashes = false;
				}
				acc_b += String.fromCodePoint(i);
			}
		}
		return acc_b;
	}
	static addTrailingSlash(path) {
		if(path.length == 0) {
			return "/";
		}
		let c1 = path.lastIndexOf("/");
		let c2 = path.lastIndexOf("\\");
		if(c1 < c2) {
			if(c2 != path.length - 1) {
				return path + "\\";
			} else {
				return path;
			}
		} else if(c1 != path.length - 1) {
			return path + "/";
		} else {
			return path;
		}
	}
}
haxe_io_Path.__name__ = true;
function Main_main() {
	let haxeVersion = actions_Core.getInput("haxe-version");
	let flixelVersions = actions_Core.getInput("flixel-versions");
	let target = actions_Core.getInput("target");
	let runTests = actions_Core.getInput("run-tests") == "true";
	if(runTests) {
		if(target == "hl" && StringTools.startsWith(haxeVersion,"3")) {
			return;
		}
		if(haxeVersion == "nightly") {
			return;
		}
	}
	actions_Core.startGroup("Installing Haxe Dependencies");
	let haxeVersion1 = haxeVersion;
	let cmd = "sudo apt install neko";
	let flixelVersions1 = flixelVersions;
	let target1 = target;
	if(Command_runUntilFailure([function() {
		return Main_setupLix(haxeVersion1);
	},function() {
		return Command_run(cmd);
	},function() {
		return Main_installHaxelibs(flixelVersions1);
	},function() {
		return Main_installHxcpp(target1);
	}]) != 0) {
		process.exit(1);
	}
	actions_Core.exportVariable("HAXELIB_REPO",Main_HaxelibRepo);
	actions_Core.endGroup();
	actions_Core.startGroup("Listing Dependencies");
	Command_run("lix -v");
	Command_run("haxe -version");
	Command_run("neko -version");
	Command_run("haxelib version");
	Command_run("haxelib config");
	Command_run("haxelib list");
	actions_Core.endGroup();
	if(runTests) {
		actions_Core.startGroup("Test Preparation");
		Command_cd(haxe_io_Path.join([Main_HaxelibRepo,"flixel/git/tests"]));
		Command_putEnv("HXCPP_SILENT","1");
		Command_putEnv("HXCPP_COMPILE_CACHE",process.env["HOME"] + "/hxcpp_cache");
		Command_putEnv("HXCPP_CACHE_MB","5000");
		actions_Core.endGroup();
		let code = Command_runAllNamed(Tests_make(target));
		process.exit(code);
	}
}
function Main_setupLix(haxeVersion) {
	js_node_ChildProcess.spawnSync("lix scope",{ shell : true, stdio : "inherit"});
	let path = haxe_io_Path.join([process.env["HOME"],"haxe/.haxerc"]);
	if(!sys_FileSystem.exists(path)) {
		return 1;
	}
	js_node_Fs.writeFileSync(path,"{\"version\": \"stable\", \"resolveLibs\": \"haxelib\"}");
	return Command_run("lix install haxe " + haxeVersion + " --global");
}
function Main_installHaxelibs(flixelVersions) {
	let lib = "munit";
	let lib1 = "hamcrest";
	let lib2 = "systools";
	let lib3 = "task";
	let lib4 = "poly2trihx";
	let lib5 = "nape-haxe4";
	let user = "HaxeFoundation";
	let lib6 = "hscript";
	let user1 = "larsiusprime";
	let lib7 = "firetongue";
	let user2 = "bendmorris";
	let lib8 = "spinehaxe";
	let user3 = "larsiusprime";
	let lib9 = "steamwrap";
	let lib10 = "openfl";
	let lib11 = "lime";
	let libs = [function() {
		return Haxelib_install(lib);
	},function() {
		return Haxelib_install(lib1);
	},function() {
		return Haxelib_install(lib2);
	},function() {
		return Haxelib_install(lib3);
	},function() {
		return Haxelib_install(lib4);
	},function() {
		return Haxelib_install(lib5);
	},function() {
		return Haxelib_git(user,lib6);
	},function() {
		return Haxelib_git(user1,lib7);
	},function() {
		return Haxelib_git(user2,lib8);
	},function() {
		return Haxelib_git(user3,lib9);
	},function() {
		return Haxelib_install(lib10);
	},function() {
		return Haxelib_install(lib11);
	}];
	let libs1;
	if(flixelVersions == "dev") {
		let user = "HaxeFlixel";
		let lib = "flixel";
		let user1 = "HaxeFlixel";
		let lib1 = "flixel-tools";
		let user2 = "HaxeFlixel";
		let lib2 = "flixel-templates";
		let user3 = "HaxeFlixel";
		let lib3 = "flixel-demos";
		let user4 = "HaxeFlixel";
		let lib4 = "flixel-addons";
		let user5 = "HaxeFlixel";
		let lib5 = "flixel-ui";
		libs1 = [function() {
			return Haxelib_git(user,lib);
		},function() {
			return Haxelib_git(user1,lib1);
		},function() {
			return Haxelib_git(user2,lib2);
		},function() {
			return Haxelib_git(user3,lib3);
		},function() {
			return Haxelib_git(user4,lib4);
		},function() {
			return Haxelib_git(user5,lib5);
		}];
	} else {
		let lib = "flixel";
		let lib1 = "flixel-tools";
		let lib2 = "flixel-templates";
		let lib3 = "flixel-demos";
		let lib4 = "flixel-addons";
		let lib5 = "flixel-ui";
		libs1 = [function() {
			return Haxelib_install(lib);
		},function() {
			return Haxelib_install(lib1);
		},function() {
			return Haxelib_install(lib2);
		},function() {
			return Haxelib_install(lib3);
		},function() {
			return Haxelib_install(lib4);
		},function() {
			return Haxelib_install(lib5);
		}];
	}
	libs = libs.concat(libs1);
	return Command_runUntilFailure(libs);
}
function Main_installHxcpp(target) {
	if(target != "cpp") {
		return 0;
	}
	let hxcppDir = haxe_io_Path.join([Main_HaxelibRepo,"hxcpp/git/"]);
	let user = "HaxeFoundation";
	let lib = "hxcpp";
	let dir = hxcppDir + "/tools/run";
	let cmd = "haxe";
	let args = ["compile.hxml"];
	let dir1 = hxcppDir + "/tools/hxcpp";
	let cmd1 = "haxe";
	let args1 = ["compile.hxml"];
	return Command_runAll([function() {
		return Haxelib_git(user,lib);
	},function() {
		return Command_runInDir(dir,cmd,args);
	},function() {
		return Command_runInDir(dir1,cmd1,args1);
	}]);
}
Math.__name__ = true;
function OpenFL_build(path,target,define) {
	return OpenFL_run("build",path,target,define);
}
function OpenFL_run(operation,path,target,define) {
	let args = ["openfl",operation,path,target];
	if(define != null) {
		args.push("-D" + define);
	}
	return Haxelib_run(args);
}
class Std {
	static string(s) {
		return js_Boot.__string_rec(s,"");
	}
}
Std.__name__ = true;
class StringTools {
	static startsWith(s,start) {
		if(s.length >= start.length) {
			return s.lastIndexOf(start,0) == 0;
		} else {
			return false;
		}
	}
}
StringTools.__name__ = true;
function Tests_make(target) {
	let target1 = target;
	let tmp = function() {
		return Tests_runUnitTests(target1);
	};
	let target2 = target;
	let tmp1 = function() {
		return Tests_buildCoverageTests(target2);
	};
	let target3 = target;
	let tmp2 = function() {
		return Tests_buildSwfVersionTests(target3);
	};
	let target4 = target;
	let demos = target == "cpp" ? Tests_ImportantDemos : [];
	let tmp3 = function() {
		return Tests_buildDemos(target4,demos);
	};
	let target5 = target;
	let tmp4 = function() {
		return Tests_buildSnippetsDemos(target5);
	};
	return [{ name : "Running Unit Tests", run : tmp, active : true},{ name : "Building Coverage Tests", run : tmp1, active : true},{ name : "Building SWF Version Tests", run : tmp2, active : target == "flash"},{ name : "Building flixel-demos", run : tmp3, active : true},{ name : "Building snippets.haxeflixel.com Demos", run : tmp4, active : target != "cpp"}];
}
function Tests_runUnitTests(target) {
	let args = ["munit","gen"];
	Command_runCallbackInDir("unit",function() {
		return Haxelib_run(args);
	});
	if(target == "flash" || target == "html5" || target == "hl") {
		process.stdout.write("Building unit tests...\n");
		process.stdout.write("\n");
		return OpenFL_build("unit",target);
	} else {
		process.stdout.write("Running unit tests...\n");
		process.stdout.write("\n");
		return OpenFL_run("test","unit",target,"travis");
	}
}
function Tests_buildCoverageTests(target) {
	process.stdout.write("\nBuilding coverage tests...\n");
	process.stdout.write("\n");
	let path = "coverage";
	let target1 = target;
	let define = "coverage1";
	let path1 = "coverage";
	let target2 = target;
	let define1 = "coverage2";
	return Command_runAll([function() {
		return OpenFL_build(path,target1,define);
	},function() {
		return OpenFL_build(path1,target2,define1);
	}]);
}
function Tests_buildDemos(target,demos) {
	process.stdout.write("\nBuilding demos...\n");
	process.stdout.write("\n");
	return Flixel_buildProjects(target,demos);
}
function Tests_buildSnippetsDemos(target) {
	process.stdout.write("\nBuilding mechanics demos...\n");
	process.stdout.write("\n");
	Command_run("git",["clone","https://github.com/HaxeFlixel/haxeflixel-mechanics"]);
	return Flixel_buildProjects(target,["-dir","haxeflixel-mechanics"]);
}
function Tests_buildSwfVersionTests(target) {
	process.stdout.write("\nBuilding swf version tests...\n");
	process.stdout.write("\n");
	let path = "swfVersion/11";
	let target1 = target;
	let path1 = "swfVersion/11_2";
	let target2 = target;
	return Command_runAll([function() {
		return OpenFL_build(path,target1);
	},function() {
		return OpenFL_build(path1,target2);
	}]);
}
var actions_Core = __webpack_require__(470);
class haxe_iterators_ArrayIterator {
	constructor(array) {
		this.current = 0;
		this.array = array;
	}
	hasNext() {
		return this.current < this.array.length;
	}
	next() {
		return this.array[this.current++];
	}
}
haxe_iterators_ArrayIterator.__name__ = true;
class js_Boot {
	static __string_rec(o,s) {
		if(o == null) {
			return "null";
		}
		if(s.length >= 5) {
			return "<...>";
		}
		let t = typeof(o);
		if(t == "function" && (o.__name__ || o.__ename__)) {
			t = "object";
		}
		switch(t) {
		case "function":
			return "<function>";
		case "object":
			if(((o) instanceof Array)) {
				let str = "[";
				s += "\t";
				let _g = 0;
				let _g1 = o.length;
				while(_g < _g1) {
					let i = _g++;
					str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
				}
				str += "]";
				return str;
			}
			let tostr;
			try {
				tostr = o.toString;
			} catch( _g ) {
				return "???";
			}
			if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
				let s2 = o.toString();
				if(s2 != "[object Object]") {
					return s2;
				}
			}
			let str = "{\n";
			s += "\t";
			let hasp = o.hasOwnProperty != null;
			let k = null;
			for( k in o ) {
			if(hasp && !o.hasOwnProperty(k)) {
				continue;
			}
			if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
				continue;
			}
			if(str.length != 2) {
				str += ", \n";
			}
			str += s + k + " : " + js_Boot.__string_rec(o[k],s);
			}
			s = s.substring(1);
			str += "\n" + s + "}";
			return str;
		case "string":
			return o;
		default:
			return String(o);
		}
	}
}
js_Boot.__name__ = true;
var js_node_ChildProcess = __webpack_require__(129);
var js_node_Fs = __webpack_require__(747);
class sys_FileSystem {
	static exists(path) {
		try {
			js_node_Fs.accessSync(path);
			return true;
		} catch( _g ) {
			return false;
		}
	}
}
sys_FileSystem.__name__ = true;
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
{
	String.__name__ = true;
	Array.__name__ = true;
}
js_Boot.__toStr = ({ }).toString;
var Command_dryRun = false;
var Main_HaxelibRepo = haxe_io_Path.join([process.env["HOME"],"haxe/haxelib"]);
var Tests_ImportantDemos = ["Mode"];
Main_main();
})({});


/***/ }),

/***/ 622:
/***/ (function(module) {

module.exports = require("path");

/***/ }),

/***/ 747:
/***/ (function(module) {

module.exports = require("fs");

/***/ })

/******/ });