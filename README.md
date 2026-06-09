## wtf???

a new era of [mfos](https://github.com/knbn1/mfos) 

close to the first stable release!

pls open an issue or contact knb if you have any questions

also i spent an eternity chasing impossible dreams :c

## differences to original

sysmodules and packages have been split off from the main batch file, allowing for modular development

SHIT WILL HIT THE FUCKING FAN if you try to run stuff from the old OS (okay maybe we can try a compat mode for this lmao)

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

## neopkg

say goodbye to motherfuckin pkg we now have `neopkg`

commands are more or less the same but now packages are downloaded online!

go to the [knbn1/mfos-next-packages](https://github.com/knbn1/mfos-next-packages) repo for packages that are available 
