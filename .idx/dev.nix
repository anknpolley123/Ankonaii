{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-23.11";

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk17
    pkgs.git-lfs
    pkgs.gh 
    pkgs.android-studio
    pkgs.android-tools
    pkgs.gradle
    pkgs.git
    pkgs.nodejs_20
    pkgs.firebase-tools
  ];

  # Sets environment variables in the workspace
  env = {
    ANDROID_HOME = "/home/user/.android";
    JAVA_HOME = "${pkgs.jdk17}/";
  };

  # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
  idx.extensions = [
    "vscjava.vscode-java-pack"
    "fwcd.kotlin"
    "mathiasfrohlich.Kotlin"
    "naco-siren.gradle-language"
    "google.android-studio"
  ];

  # Enable previews and custom configuration
  idx.previews = {
    enable = true;
    previews = {
      android = {
        command = ["flutter" "run" "--machine" "-d" "android"];
        manager = "flutter";
      };
    };
  };
}