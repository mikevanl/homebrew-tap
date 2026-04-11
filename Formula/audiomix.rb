class Audiomix < Formula
  desc "Per-app volume, mute, and output device routing for macOS"
  homepage "https://github.com/mikevanl/audiomix"
  url "https://github.com/mikevanl/audiomix/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "94233531c4db6a584389381c27e4a193bd6083a1d1752bc95a041411d4e72f5b"
  license "MIT"

  bottle do
    root_url "https://github.com/mikevanl/audiomix/releases/download/v0.1.7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0399b9fef1a3f257a916b0db206480e6a98cec8997765eb23d7e50c00be786f2"
  end

  depends_on :macos => :sonoma
  depends_on xcode: ["16.0", :build]
  depends_on "xcodegen" => :build

  def install
    system "xcodegen", "generate"

    xcodebuild_args = %w[
      -configuration Release
      -derivedDataPath build
      CODE_SIGN_IDENTITY=-
    ]

    system "xcodebuild", "-scheme", "AudioMix",
           "-destination", "platform=macOS",
           "build", *xcodebuild_args
    system "xcodebuild", "-scheme", "audiomix",
           "-destination", "platform=macOS",
           "build", *xcodebuild_args

    bin.install "build/Build/Products/Release/audiomix"
    (prefix/"Frameworks").install "build/Build/Products/Release/AudioMixKit.framework"

    app_dir = prefix/"AudioMix.app"
    app_dir.mkpath
    cp_r Dir["build/Build/Products/Release/AudioMix.app/*"], app_dir
    cp "App/AudioMix.entitlements", prefix/".entitlements"
  end

  def post_install
    system "codesign", "--force", "--deep", "--sign", "-",
           "--entitlements", prefix/".entitlements",
           prefix/"AudioMix.app"
  end

  def caveats
    <<~EOS
      AudioMix.app has been installed to:
        #{prefix}/AudioMix.app

      To launch:
        open #{prefix}/AudioMix.app

      To install to /Applications (optional):
        cp -r #{prefix}/AudioMix.app /Applications/

      The CLI tool `audiomix` is available in your PATH.
      The app must be running for CLI commands to work.

      On first launch, grant Audio Capture permission when prompted.
    EOS
  end

  test do
    assert_match "audiomix", shell_output("#{bin}/audiomix --help")
  end
end
