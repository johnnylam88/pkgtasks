Package Tasks
=============


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
