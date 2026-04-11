class Audiomix < Formula
  desc "Per-app volume, mute, and output device routing for macOS"
  homepage "https://github.com/mikevanl/audiomix"
  url "https://github.com/mikevanl/audiomix/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "b59d3977a725a094171212fbd644cfd46302ec706fd0fc7de784ec0a7b15f2fb"
  license "MIT"

  bottle do
    root_url "https://github.com/mikevanl/audiomix/releases/download/v0.1.2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8e409a4d2d46d27a2c502f64d9181c5ed457a7885f9d41c0e540db975e6e880c"
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
  end

  def post_install
    system "codesign", "--force", "--deep", "--sign", "-", prefix/"AudioMix.app"
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
