# verified.installation

Convenient installation of R packages in Docker images.
Set of functions that stop R session in case of failed installation.

```
install_and_verify(
  installation_function - function that will be called to install function: installation_function(package_name, ...)
  package_name - e.g. "assertr"
  package_path - in case you install from github, e.g. "Appsilon/assertr"
  ... - any arguments that you want to pass to installation_function
)
```

This function checks:

* if package is installed
* if package has expected version
* if you install from github, `remotes::install_github` checks also `ref` (e.g. commit)

Convenient functions that use `install_and_verify`:

```
install_and_verify_version(package, version)
install_and_verify_github(package, package_path, ref)
```

# Error instead of stopping R session

If you don't want to stop R session on error, you can set the following option:

```
options(stop_session_on_error = FALSE)
```

# How to install this package

Usually it is the first package installed in your Docker image.
Instead using `devtools` you can use https://remotes.r-lib.org/ method:

```
source("https://install-github.me/Appsilon/verified.installation")
```
