# upcheckr — Homebrew formula. Installs the prebuilt native binary (no Java required).
#
#   brew install laurentiud/tap/upcheckr
#
# Binaries and checksums are served from the public releases repo
# (laurentiud/upcheckr-public-releases). CI bumps the version + sha256 on each tagged release.
class Upcheckr < Formula
  desc "Self-hosted live wall for pushed application metrics"
  homepage "https://upcheckr.co"
  version "0.3.4"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-macos-arm64"
      sha256 "f270c5cf52103c55f25b6ff1c8302e288740d4fc642b2f2bd1c09e302419a0a2"
    end
    on_intel do
      odie "No native build for Intel macOS — download upcheckr.jar from " \
           "https://github.com/laurentiud/upcheckr-public-releases/releases and run `java -jar upcheckr.jar`."
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-arm64"
      sha256 "65ec99f83dc8a351c7c2f2faa596a214c6f3bd9e250690e4d23974db775cb7e0"
    end
    on_intel do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-x64"
      sha256 "f7c1406f47798e2e301dda410a64523912e4182e1a627b37104716397dcd4d38"
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
