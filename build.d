import std.stdio, std.array, std.string, std.range, std.algorithm, std.exception, std.conv, std.regex,
       std.file, std.path, std.datetime, std.json, std.concurrency, std.parallelism, std.container,
       std.experimental.logger;
import std.process;

/*******************************************************************************
 * 
 */
struct Config
{
	///
	bool forceBuild;
	///
	string compiler = r"ldc2";
	///
	string linker   = r"arm-none-eabi-ld";
	///
	string elf2bin  = r"arm-none-eabi-objcopy";
	///
	string obj2asm  = r"arm-none-eabi-objdump";
	///
	string[] sourceDirs = [r"src"];
	///
	File stdin;
	///
	File stdout;
	///
	File stderr;
	///
	string[] dflags = [
		r"-betterC",
		r"-mtriple=thumb-none-eabi",
		r"-mcpu=cortex-m4",
		r"-relocation-model=static",
		r"-release",
		r"-O",
		r"-output-s",
		r"-output-o",
		r"-boundscheck=off",
		r"-c",
		r"-of",
		r"out.o"
	];
	///
	string[] lflags = [
		"--gc-sections",
		"-T",
		"stm32f401re.ld",
		"-Map",
		"out.map",
		"out.o",
		"-o",
		"out.elf"
	];
	///
	string[] elf2binflags = [
		"-O",
		"binary",
		"out.elf"
	];
	///
	string[] obj2asmflags = [
		"-D",
		"out.elf"
	];
	///
	string outBin = "out.bin";
	///
	string[string] env = null;
	///
	string workDir;
	///
	bool build = true;
	///
	string copyTo;
	///
	string asmdumpTo;
}

/*******************************************************************************
 * 
 */
void addPathAfter(ref string[string] env, string path)
{
	if (auto p = "PATH" in env)
	{
		env["PATH"] = *p ~ ";" ~ path;
	}
	else if (auto p = "Path" in env)
	{
		env["Path"] = *p ~ ";" ~ path;
	}
	else if (auto p = "path" in env)
	{
		env["path"] = *p ~ ";" ~ path;
	}
	else if (auto p = environment.get("PATH", null))
	{
		env["PATH"] = p ~ ";" ~ path;
	}
	else if (auto p = environment.get("Path", null))
	{
		env["Path"] = p ~ ";" ~ path;
	}
	else if (auto p = environment.get("path", null))
	{
		env["path"] = p ~ ";" ~ path;
	}
	else
	{
		env["PATH"] = path;
	}
}

/*******************************************************************************
 * 
 */
void addPathBefore(ref string[string] env, string path)
{
	if (auto p = "PATH" in env)
	{
		env["PATH"] = path ~ ";" ~ *p;
	}
	else if (auto p = "Path" in env)
	{
		env["Path"] = path ~ ";" ~ *p;
	}
	else if (auto p = "path" in env)
	{
		env["path"] = path ~ ";" ~ *p;
	}
	else if (auto p = environment.get("PATH", null))
	{
		env["PATH"] = path ~ ";" ~ p;
	}
	else if (auto p = environment.get("Path", null))
	{
		env["Path"] = path ~ ";" ~ p;
	}
	else if (auto p = environment.get("path", null))
	{
		env["path"] = path ~ ";" ~ p;
	}
	else
	{
		env["PATH"] = path;
	}
}

/*******************************************************************************
 * 
 */
void execCmd(Config cfg, string[] args, string[string] env = null)
{
	writefln("%s> %-(%s %)", cfg.workDir, args);
	auto res = spawnProcess(args, cfg.stdin, cfg.stdout, cfg.stderr, env, std.process.Config.none, cfg.workDir);
	enforce(res.wait() == 0);
	writeln();
}


/*******************************************************************************
 * 
 */
void copyFile(string src, string target)
{
	string targetFile;
	targetFile = target;
	if (!targetFile.dirName.exists)
		mkdirRecurse(targetFile.dirName);
	if (target.exists && target.isDir)
		targetFile = target.buildPath(src.baseName);
	enforce(src.exists && src.isFile);
//	if (targetFile.exists && targetFile.isFile)
//		std.file.remove(targetFile);
//	enforce(!targetFile.exists, "Cannot remove target file");
	std.file.copy(src, targetFile);
	writefln("%s ... copied to ... %s", src, targetFile);
}

/*******************************************************************************
 * 
 */
void copyFiles(string srcDir, string blobFilter, string dstDir)
{
	foreach (de; dirEntries(srcDir, blobFilter, SpanMode.shallow))
	{
		auto relPath = relativePath(de.name.absolutePath.buildNormalizedPath, srcDir.absolutePath.buildNormalizedPath);
		auto targetPath = dstDir.buildNormalizedPath(relPath);
		if (de.isDir)
		{
			mkdirRecurse(targetPath);
			writefln("%s ... copied to ... %s", de.name, targetPath);
		}
		else
		{
			if (!targetPath.dirName.exists)
				mkdirRecurse(targetPath.dirName);
			enforce(targetPath.dirName.isDir, "Cannot make target directory");
			if (targetPath.exists)
				std.file.remove(targetPath);
			copyFile(de.name, targetPath);
		}
	}
}


/// ditto
void copyFiles(string srcDir, string targetDir)
{
	foreach (de; dirEntries(srcDir, SpanMode.breadth))
	{
		auto relPath = relativePath(de.name.absolutePath.buildNormalizedPath, srcDir.absolutePath.buildNormalizedPath);
		auto targetPath = targetDir.buildNormalizedPath(relPath);
		if (de.name.isDir)
		{
			targetPath.mkdirRecurse();
			writefln("%s ... copied to ... %s", de.name, targetPath);
		}
		else
		{
			if (!targetPath.dirName.exists)
				targetPath.dirName.mkdirRecurse();
			enforce(targetPath.dirName.isDir, "Cannot make target directory");
			if (targetPath.exists)
				std.file.remove(targetPath);
			std.file.copy(de.name, targetPath);
			writefln("%s ... copied to ... %s", de.name, targetPath);
		}
	}
}

/*******************************************************************************
 * 
 */
void removeFiles(string path)
{
	if (!path.exists)
		return;
	if (path.isFile)
	{
		std.file.remove(path);
		writefln("%s ... removed", path);
	}
	else
	{
		rmdirRecurse(path);
		writefln("%s ... removed", path);
	}
}

/*******************************************************************************
 * 
 */
void replaceDir(string src, string dst)
{
	removeFiles(dst);
	copyFiles(src, dst);
}

/*******************************************************************************
 * 
 */
string[] sourceFiles(Config cfg)
{
	string[] ret;
	foreach (sourceDir; cfg.sourceDirs)
		ret ~= dirEntries(sourceDir, "*.d", SpanMode.breadth).map!(a => a.name).array();
	return ret;
}
/*******************************************************************************
 * 
 */
void build(Config cfg)
{
	immutable dubFlgForce = cfg.forceBuild ? "-f" : null;
	string[] args;
	
	if (cfg.build)
	{
		args ~= cfg.compiler;
		args ~= cfg.dflags;
		args ~= cfg.sourceFiles();
		cfg.execCmd(args);
		
		args = null;
		args ~= cfg.linker;
		args ~= cfg.lflags;
		cfg.execCmd(args);
		
		args = null;
		args ~= cfg.elf2bin;
		args ~= cfg.elf2binflags;
		args ~= cfg.outBin;
		cfg.execCmd(args);
	}
	if (cfg.copyTo.exists && cfg.copyTo.isDir)
	{
		copyFile(cfg.outBin, cfg.copyTo);
	}
	
	if (cfg.asmdumpTo.length > 0)
	{
		args = null;
		args ~= cfg.obj2asm;
		args ~= cfg.obj2asmflags;
		cfg.stdout = File(cfg.asmdumpTo, "w+");
		cfg.execCmd(args);
	}
}

/*******************************************************************************
 * 
 */
void main(string[] args)
{
	Config cfg;
	import std.getopt: getopt;
	getopt(args,
		"f|force", &cfg.forceBuild,
		"copy-to", &cfg.copyTo,
		"asmdump-to", &cfg.asmdumpTo
		);
	if (cfg.workDir is null)
		cfg.workDir = getcwd();
	cfg.stdin  = std.stdio.stdin;
	cfg.stdout = std.stdio.stdout;
	cfg.stderr = std.stdio.stderr;
	build(cfg);
}
