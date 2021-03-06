log_print <- function(mode = "info", text = "", ...) {
  cat(sprintf("[%s] %s\n", mode, sprintf(text, ...)))
}

log_check <- function(text = "", ...) {
  log_print("check", text, ...)
}

log_info <- function(text = "", ...) {
  log_print("info", text, ...)
}

log_error <- function(text = "", ...) {
  log_print("error", text, ...)
}

stop_session <- function(text = "", ...) {
  log_error(text, ...)
  quit(status = 1)
}



package_is_installed <- function(package, print_info = TRUE, stop_session_on_error = TRUE) {
  if (print_info) {
    log_check("%s package_is_installed", package)
  }
  if (!is.element(package, installed.packages()[,1])) {
    message = sprintf("Package %s is not installed!", package)
    if (stop_session_on_error) {
      stop_session(message)
    } else {
      stop(message)
    }
  }
}

package_has_exact_version <- function(expected_version) {
  function(package, stop_session_on_error = TRUE) {
    log_check("%s package_has_exact_version %s", package, expected_version)
    package_is_installed(package, print_info = FALSE)
    current_version <- installed.packages()[package, "Version"]
    if (utils::compareVersion(current_version, expected_version) != 0) {
      message = sprintf("Package %s version %s is not equal to %s", package, current_version, expected_version)
      if (stop_session_on_error) {
        stop_session(message)
      } else {
        stop(message)
      }
    }
  }
}

package_has_minimum_version <- function(expected_minimum_version) {
  function(package, stop_session_on_error = TRUE) {
    log_check("%s package_has_minimum_version %s", package, expected_minimum_version)
    package_is_installed(package, print_info = FALSE)
    current_version <- installed.packages()[package, "Version"]
    if (utils::compareVersion(current_version, expected_minimum_version) == -1) {
      message = sprintf("Package %s version %s is not >= %s", package, current_version, expected_minimum_version)
      if (stop_session_on_error) {
        stop_session(message)
      } else {
        stop(message)
      }
    }
  }
}

install_and_verify <- function(install = install.packages,
                               verify = NULL,
                               package = NULL,
                               package_path = package,
                               overwrite = FALSE, ...) {

  if (is.null(package)) stop_session("Package name is null")

  package_is_not_installed <- tryCatch({
    for (v in c(package_is_installed, verify)) v(package, stop_session_on_error = FALSE)
    log_check("%s is already installed with provided requirements.", package)
    FALSE
  }, error = function(e) {
    TRUE
  })

  if (package_is_not_installed || overwrite) {
    log_info("Installing %s...", package)
    install(package_path, ...)
  } else {
    log_info("Skipping installation...")
  }

  for (v in c(verify)) v(package)
}
