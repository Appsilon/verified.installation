stop <- function(text = "") {
  message(paste("[error]", text, "\n"))
  quit(status = 1)
}

package_is_installed <- function(package, print_info = TRUE) {
  if (print_info) {
    cat(paste("[check]", package, "package_is_installed", "\n"))
  }
  if (!is.element(package, installed.packages()[,1])) {
    stop(paste("package", package, "is not installed!"))
  }
}

package_has_exact_version <- function(expected_version) {
  function(package) {
    cat(paste("[check]", package, "package_has_exact_version", expected_version, "\n"))
    package_is_installed(package, print_info = FALSE)
    current_version <- installed.packages()[package, "Version"]
    if (utils::compareVersion(current_version, expected_version) != 0) {
      stop(paste0("Package `", package, "` version `", current_version, "` is not equal to `", expected_version, "`"))
    }
  }
}

package_has_minimum_version <- function(expected_minimum_version) {
  function(package) {
    cat(paste("[check]", package, "package_has_minimum_version", expected_minimum_version, "\n"))
    package_is_installed(package, print_info = FALSE)
    current_version <- installed.packages()[package, "Version"]
    if (utils::compareVersion(current_version, expected_minimum_version) == -1) {
      stop(paste0("Package `", package, "` version `", current_version, "` is not >= `", expected_minimum_version, "`"))
    }
  }
}

install_and_verify <- function(install = install.packages, verify = package_is_installed, package = NULL, ...) {
  if (is.null(package)) stop("Package name is null")
  install(package, ...)
  for (v in c(verify)) v(package)
}
