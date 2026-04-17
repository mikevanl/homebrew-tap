class Sketchypicker < Formula
  desc "Native macOS picker/dropdown companion for sketchybar"
  homepage "https://github.com/mikevanl/SketchyPicker"
  url "https://github.com/mikevanl/SketchyPicker.git",
      using:    :git,
      tag:      "v0.1.0",
      revision: "ebab6b41e5026ed765d41a2044faa96c92dc189f"
  version "0.1.0"
  license "MIT"
  head "https://github.com/mikevanl/SketchyPicker.git", branch: "main"

  depends_on :macos
  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/sketchypicker"
  end

  test do
    system bin/"sketchypicker", "--help"
  end
end
