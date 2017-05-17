Package Tasks
=============


Changes in version 1.5
----------------------
**Released on 2017-05-17.**

* Support `~[string]` (tilde string) in a version string to sort
  before a release version, e.g., 1.2~rc1 sorts before 1.2.

* When invoking a meta-task, only be verbose when invoking tasks
  that typically affect system files and directories.  This
  makes the output a bit more friendly for the typicaly user,
  who is no longer bombarded with every trivial GNU info file
  registration.

* Bug fixes.


Changes in version 1.4
----------------------
**Released on 2017-05-14.**

* Allow duplicate logging of task output to a file through the
  `echo` task.

* Added `tee` task to duplicate standard input to standard output
  and into additional files.


Changes in version 1.3
----------------------
**Released on 2017-05-13.**

* Generalized refcount API so the refcount-file implementation
  may be deprecated in the future.

* Added option to suppress duplicate lines to the `sort` task.

* Added `valid_options` task to simplify checking for valid flags.

* Added `function` task as a generic hook for user-written tasks
  into the `preinstall`, `postinstall`, `preremove`, and
  `postremove` meta-tasks.

* Bug fixes.


Changes in version 1.2
----------------------
**Released on 2017-05-07.**

* Be more consistent with using `maketemp` to generate internal
  temporary files and directories.

* Added the `sort` task to sort lines from standard input.

* Sort input when performing `add` action of `directories` task,
  and reverse sort when performing `remove` action.  This causes
  path components to be created and removed in the correct order.


Changes in version 1.1
----------------------

**Released on 2017-05-05**

* Added the `which` task to locate a program in the search path.

* Changed the `fonts` task to search for indexing commands in the
  search path before falling back to defaults.  This makes the
  task more resilient to differences in how the X11 directories
  are laid out across different systems.

* Be more consistent with preserving standard error from commands
  used to perform tasks so that errors are visible for logging and
  debugging purposes.


Changes in version 1.0
----------------------

**Released on 2017-05-03**

* Initial release of pkgtasks-1-1.0.
