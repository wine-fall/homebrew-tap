# wine-fall/homebrew-tap

Homebrew formulae for [wine-fall](https://github.com/wine-fall)'s tools.

```sh
brew install wine-fall/tap/which-account
```

## which-account

Asks which Chrome account a link should open in, then remembers the answer.
See [wine-fall/which-account](https://github.com/wine-fall/which-account).

It is built from source on your machine. That takes about ten seconds, but it
means the binary matches your architecture and carries no quarantine flag — so
no code signing, notarization or Apple developer account is involved anywhere.

### Requirements

Current Xcode Command Line Tools. Homebrew refuses to build from source against
outdated ones:

```
Error: Your Command Line Tools are too outdated.
```

If you see that, `brew config` will show the version it found. Update them from
Software Update in System Settings, or:

```sh
sudo rm -rf /Library/Developer/CommandLineTools
sudo xcode-select --install
```

After installing, run `which-account --setup` to become the default browser;
macOS asks you to confirm. `which-account --restore` hands it back.
