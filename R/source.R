message_ok <- function(message, ...) sprintf("%s %s\n", crayon::green(cli::symbol$tick), sprintf(message, ...))
message_info <- function(message, ...) sprintf("%s %s\n", crayon::cyan(cli::symbol$play), sprintf(message, ...))
message_error <- function(message, ...) sprintf("%s %s\n", crayon::red(cli::symbol$cross), sprintf(message, ...))

is_installed <- function(package) {
  is.element(package, installed.packages()[,1])
}

has_exact_version <- function(package, expected_version) {
  if (is_installed(package)) {
    current_version <- installed.packages()[package, "Version"]
    return(utils::compareVersion(current_version, expected_version) == 0)
  } else {
    return(FALSE)
  }
}

verify_installation <- function(package) {
  if (!is_installed(package)) {
    stop(sprintf("Package %s is not installed", package))
  }
}

verify_version <- function(package, version = NULL, ...) {
  if (!is.null(version)) {
    if (!has_exact_version(package, version)) {
      stop(sprintf("Package %s has version %s instead of expected %s", package, current_version, version))
    }
  }
}

skip_installation <- function(overwrite, package, version = NULL, ...) {
  version_is_ok <- ifelse(is.null(version), TRUE, has_exact_version(package, version))
  !overwrite && is_installed(package) && version_is_ok
}

handle_error <- function(message) {
  if (getOption("stop_session_on_error", default = TRUE)) {
    print(message)
    quit(status = 1)
  } else {
    stop(message)
  }
}

install_and_verify <- function(install = install.packages,
                               package = NULL,
                               package_path = package,
                               overwrite = FALSE,
                               ...) {
  tryCatch({

    if (skip_installation(overwrite, package, ...)) {
      cat(message_ok("Skipping installation for %s", crayon::cyan(package)))
    } else {
      cat(message_info("Installing %s...", crayon::cyan(package)))
      install(package_path, ...)
    }

    verify_installation(package)
    verify_version(package, ...)

    cat(message_ok("Package %s installed", crayon::cyan(package)))

  }, error = handle_error)
}

install_and_verify_version <- function(package, version) {
  install_and_verify(
    install = remotes::install_version,
    package = package,
    version = version,
    upgrade = "never"
  )
}

install_and_verify_github <- function(package, package_path, ref) {
  # Installing package from github must be always with overwrite = TRUE option.
  # We can't assume, that code on github hasn't changed. Version match is not enough to skip installation.
  install_and_verify(
    install = remotes::install_github,
    package = package,
    package_path = package_path,
    ref = ref,
    upgrade = "never",
    overwrite = TRUE
  )
}
