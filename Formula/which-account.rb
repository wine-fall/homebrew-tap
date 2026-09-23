class WhichAccount < Formula
  desc "Ask which Chrome account a link should open in, then remember the answer"
  homepage "https://github.com/wine-fall/which-account"
  url "https://github.com/wine-fall/which-account/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "9e1b1985744ba7a7890c14b37331c5cf0f1e583ab4e78467ac6eb450fc27b1d5"
  license "MIT"
  head "https://github.com/wine-fall/which-account.git", branch: "main"

  depends_on macos: :ventura

  # Built from source on the installing machine, so the binary matches the local
  # architecture and carries no quarantine flag. That is what lets an unsigned,
  # un-notarized app be installed this way at all.
  def install
    system "swift", "build", "--configuration", "release", "--disable-sandbox"

    app = prefix/"which-account.app"
    (app/"Contents/MacOS").mkpath
    (app/"Contents/MacOS").install ".build/release/which-account"
    (app/"Contents").install "Resources/Info.plist"

    # The linker's ad-hoc signature covers the executable only and names it after
    # the binary, so the bundle fails validation and LaunchServices refuses to make
    # it the default browser. Signing the bundle ad-hoc fixes that and still needs
    # no developer account.
    system "codesign", "--force", "--sign", "-",
           "--identifier", "dev.wine-fall.which-account", app
    system "codesign", "--verify", "--strict", app

    # NOT a symlink: invoked through one, Bundle.main resolves to the directory
    # holding the symlink, and --setup would register that instead of the app.
    (bin/"which-account").write <<~SH
      #!/bin/bash
      exec "#{opt_prefix}/which-account.app/Contents/MacOS/which-account" "\$@"
    SH
    chmod 0755, bin/"which-account"
  end

  # LaunchServices has to know the bundle exists before macOS will offer it as a
  # browser. opt_prefix rather than prefix, so this survives `brew upgrade`.
  def post_install
    system "/System/Library/Frameworks/CoreServices.framework/Frameworks/" \
           "LaunchServices.framework/Support/lsregister",
           "-f", opt_prefix/"which-account.app"
  end

  def caveats
    <<~EOS
      which-account is installed but not yet in charge of anything. To make it
      your default browser:

        which-account --setup

      macOS will show its own confirmation; nothing changes until you accept.
      Your current browser is recorded first, and every link is handed to it.

      To hand the browser back:

        which-account --restore

      Try it without changing any setting:

        which-account --dry-run https://github.com/login/device
    EOS
  end

  test do
    # Not compared against version.to_s: a --HEAD build's version is "HEAD-<sha>",
    # while the binary always reports its own release number.
    assert_match(/^\d+\.\d+\.\d+$/, shell_output("#{bin}/which-account --version").strip)
    # A non-http(s) URL must pass straight through rather than open a picker.
    assert_match "pass through", shell_output("#{bin}/which-account --dry-run mailto:someone@example.com")
  end
end
