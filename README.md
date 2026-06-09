## wtf???

experimental build of [mfos](https://github.com/knbn1/mfos) 
buggy and painful to debug

best to treat this as a devkit for future development, it serves no practical use for end users

pls open an issue or contact knb if you have any questions

also i spent an eternity chasing impossible dreams :c

## differences to original

sysmodules and packages have been split off from the main batch file, allowing for modular development

SHIT WILL HIT THE FUCKING FAN if you try to run stuff from the old OS

also a lot of stuff from the old mfos is not present here like the updater and package installer stuff (some packages are bundled in here as a result)

## installing this

1. `git clone` this repo
2. `mfos-latest.bat`
3. ?????
4. proft

## developer notes

porting for dumdumz

- replace all the command "endings" with `goto :eof` (will add execdone in future)
- remove all the dependency checks (everything that gotos `:nocommand` except maybe devtools checks)
- remove `:cmdok`s
- packages will need to bundle their own shit instead of relying on `compact.mcm` consolidations (to be fixed!!)
- `%~dp0` needs to be changed to `%mfosLocation%` wherever used
- reboots MUST be indirectly called via `set enforcereboot=true && goto :eof`
- also add help sections???
- uwu
