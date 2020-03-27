# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import sys, os

# sys.path.insert(0, os.path.abspath('.'))

if os.getenv("USE_DOXYREST"):
    # path for doxyrest sphinx extensions
    sys.path.insert(
        1, "{:s}/share/doxyrest/sphinx".format(os.getenv("DOXYREST_PREFIX"))
    )

    import doxyrest

import sphinx_rtd_theme

# -- Project information -----------------------------------------------------

project = "Reed-Muller C"
copyright = "2020, ssraphost"
author = "ssraphost"

# The full version, including alpha/beta/rc tags
release = "1.2.0"


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx.ext.extlinks",
    "sphinx.ext.todo",
    "sphinx.ext.coverage",
    "sphinx.ext.viewcode",
    "sphinxcontrib.srclinks",
    "sphinx_rtd_theme",
]

if os.getenv("USE_DOXYREST"):
    extensions += ["doxyrest", "cpplexer"]
else:
    extensions += ["breathe", "exhale"]
    breathe_projects = {
        "Reed-Muller": "../doxybuild/xml/",
    }
    breathe_default_project = "Reed-Muller"

    # Setup the exhale extension
    exhale_args = {
        # These arguments are required
        "containmentFolder": "./api",
        "rootFileName": "library_root.rst",
        "rootFileTitle": "Library API",
        "doxygenStripFromPath": "..",
        # Suggested optional arguments
        "createTreeView": True,
        # TIP: if using the sphinx-bootstrap-theme, you need
        # "treeViewIsBootstrap": True,
        "exhaleExecutesDoxygen": True,
        "exhaleDoxygenStdin": "INPUT = ../../include",
    }

# Tell sphinx what the primary language being documented is.
primary_domain = "cpp"

# Tell sphinx what the pygments highlight language should be.
highlight_language = "cpp"


# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

html_context = {
    "display_gitlab": True,
    "gitlab_host": "gitlab.cern.ch",
    "gitlab_user": "cms-gem-daq-project",
    "gitlab_repo": "reedmuller-c",
    "gitlab_version": "master",
    "conf_py_path": "/docs/source/",
}

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = "sphinx_rtd_theme"

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]
