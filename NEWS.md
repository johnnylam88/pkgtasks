Package Tasks
=============


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
