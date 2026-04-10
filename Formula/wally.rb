class Wally < Formula
  desc "Native macOS video wallpaper manager with CLI"
  homepage "https://github.com/mikevanl/Wally"
  url "https://github.com/mikevanl/Wally/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "0509d31c68295eb580d67b54d7ff2aee305354209ed778f66d1be1ad734fc769"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    bin.install ".build/release/wallpaper"

    app_dir = prefix/"Wally.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Resources").mkpath
    (app_dir/"MacOS").install ".build/release/Wally"
    app_dir.install "Resources/Info.plist"
    app_dir.install "Resources/AppIcon.icns" => "Resources/AppIcon.icns"
  end

  def post_install
    system "codesign", "--force", "--sign", "-", prefix/"Wally.app"
  end

  def caveats
    <<~EOS
      To start Wally:
        open #{prefix}/Wally.app

      To install to /Applications (optional):
        cp -r #{prefix}/Wally.app /Applications/

      The CLI tool `wallpaper` has been installed to your PATH.
    EOS
  end
end
