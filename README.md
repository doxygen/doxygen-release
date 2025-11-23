# doxygen-release
The goal of the repository is to automate the process of creating the official release assets for Doxygen using a Github action.

This includes building the external dependencies which consist of:
- libxapian (part of Xapian)
- libclang (part of LLVM)
- Qt6 (only the `qtbase` and `qtsvg` modules are needed)

The repository also includes some tools and files that are needed in the process.
