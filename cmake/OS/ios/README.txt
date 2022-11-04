cmake-ios
=========

A platform file and toolchain files for cmake for iOS target.

Install
-------

* Copy `Platform/iOS.cmake` to Platform folder of CMake. It would be `<CMake App Folder>/Contents/share/cmake-2.8/Modules/Platform`.

Use
---

* `cmake -DCMAKE_TOOLCHAIN_FILE=<Toolchain Dir>/iOS-Device.cmake <Your Project Source Dir>` to setup for iOS device target.
* Use `iOS-Simulator.cmake` to target simulator.

[link-google-code]: http://code.google.com/p/ios-cmake/

