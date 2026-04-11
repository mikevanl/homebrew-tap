class Audiomix < Formula
  desc "Per-app volume, mute, and output device routing for macOS"
  homepage "https://github.com/mikevanl/audiomix"
  url "https://github.com/mikevanl/audiomix/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "c579ca7e6901c4e257bc52b678dfd93561ff8612dca8abccff18e44cc5eefbef"
  license "MIT"

  bottle do
    root_url "https://github.com/mikevanl/audiomix/releases/download/v0.1.3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e27ff99b9e453314b628e484685d291d70575fae887c3ab9460d77343ef9e48a"
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
