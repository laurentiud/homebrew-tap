# upcheckr — Homebrew formula. Installs the prebuilt native binary (no Java required).
#
#   brew install laurentiud/tap/upcheckr
#
# Binaries and checksums are served from the public releases repo
# (laurentiud/upcheckr-public-releases). CI bumps the version + sha256 on each tagged release.
class Upcheckr < Formula
  desc "Self-hosted live wall for pushed application metrics"
  homepage "https://upcheckr.co"
  version "0.1.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-macos-arm64"
      sha256 "b64f49eb31fd270fba76196876bf7615c537229af07ef9a1a76144795990242a"
    end
    on_intel do
      odie "No native build for Intel macOS — download upcheckr.jar from " \
           "https://github.com/laurentiud/upcheckr-public-releases/releases and run `java -jar upcheckr.jar`."
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-arm64"
      sha256 "b9ac48b66bc6bafb432e4a9c573f2381426c8953460e6497a2c249257f726263"
    end
    on_intel do
      url "https://github.com/laurentiud/upcheckr-public-releases/releases/download/v#{version}/upcheckr-linux-x64"
      sha256 "b07b80b6d122beb4e10ca9ebb1b60086025cff5f4995de2012a08dc872178e26"
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
