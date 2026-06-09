# upcheckr — Homebrew formula. Installs the prebuilt native binary (no Java required).
#
#   brew install laurentiud/tap/upcheckr
#
# Binaries and checksums are served from the public releases repo
# (laurentiud/upcheckr-public-releases). CI bumps the version + sha256 on each tagged release.
class Upcheckr < Formula
  desc "Self-hosted live wall for pushed application metrics"
  homepage "https://upcheckr.co"
  version "0.2.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-macos-arm64"
      sha256 "b537f8b97a47a51105ba0ea08c41ecb29ea5b3a8bd04a006830d6a04a9c1b04c"
    end
    on_intel do
      odie "No native build for Intel macOS — download upcheckr.jar from " \
           "https://github.com/laurentiud/upcheckr-public-releases/releases and run `java -jar upcheckr.jar`."
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-arm64"
      sha256 "af15dea4c1471116752179fdb5a5d028a0d61483c725412d97202d4ce8d2ad0a"
    end
    on_intel do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-x64"
      sha256 "0ea1ee27a220e62936174d2b45d376633b617138b31f3b62d729ca68b5bc5a0a"
    end
  end

  def install
    bin.install Dir["upcheckr-*"].first => "upcheckr"
  end

  def caveats
    <<~EOS
      Start the wall with:  upcheckr
      The first run asks you to set an admin password, then serves http://localhost:7090.
      Change the port with `--port 9000` (or UPCHECKR_PORT); reset the password later with
      `upcheckr --reset-password` (keeps your data). Set UPCHECKR_ADMIN_PASSWORD to run unattended.
      Data is stored in SQLite at ~/.upcheckr/upcheckr.db (override with UPCHECKR_DB).
    EOS
  end

  test do
    port = free_port
    pid = spawn(
      {
        "UPCHECKR_PORT"           => port.to_s,
        "UPCHECKR_ADMIN_PASSWORD" => "brewtest",
        "UPCHECKR_DB"             => (testpath/"t.db").to_s,
      },
      bin/"upcheckr", out: File::NULL, err: File::NULL
    )
    begin
      sleep 3
      assert_match '"status":"ok"',
        shell_output("curl -s --retry 15 --retry-connrefused --retry-delay 1 http://localhost:#{port}/healthz")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
