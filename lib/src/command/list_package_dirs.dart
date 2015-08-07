// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub.command.list_package_dirs;

import 'package:path/path.dart' as p;

import '../command.dart';
import '../log.dart' as log;
import '../utils.dart';

/// Handles the `list-package-dirs` pub command.
class ListPackageDirsCommand extends PubCommand {
  String get name => "list-package-dirs";
  String get description => "Print local paths to dependencies.";
  String get invocation => "pub list-package-dirs";
  bool get takesArguments => false;
  bool get hidden => true;

  ListPackageDirsCommand() {
    argParser.addOption("format",
        help: "How output should be displayed.",
        allowed: ["json"]);
  }

  void run() {
    log.json.enabled = true;

    if (!entrypoint.lockFileExists) {
      dataError('Package "myapp" has no lockfile. Please run "pub get" first.');
    }

    var output = {};

    // Include the local paths to all locked packages.
    var packages = mapMap(entrypoint.lockFile.packages, value: (name, package) {
      var source = entrypoint.cache.sources[package.source];
      var packageDir = source.getDirectory(package);
      // Normalize paths and make them absolute for backwards compatibility
      // with the protocol used by the analyzer.
      return p.normalize(p.absolute(p.join(packageDir, "lib")));
    });

    // Include the self link.
    packages[entrypoint.root.name] =
        p.normalize(p.absolute(entrypoint.root.path("lib")));

    output["packages"] = packages;

    // Include the file(s) which when modified will affect the results. For pub,
    // that's just the pubspec and lockfile.
    output["input_files"] = [
      p.normalize(p.absolute(entrypoint.lockFilePath)),
      p.normalize(p.absolute(entrypoint.pubspecPath))
    ];

    log.json.message(output);
  }
}

