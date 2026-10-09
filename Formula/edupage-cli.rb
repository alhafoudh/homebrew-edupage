class EdupageCli < Formula
  desc "Read-only Edupage access: Ruby library, CLI, REST API and MCP server"
  homepage "https://github.com/alhafoudh/edupage-cli"
  url "https://github.com/alhafoudh/edupage-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "3a15bbea1e224e38e68f5404abbfb75a3aa85394b81852e48b4fb078b8e4940f"
  license "MIT"
  head "https://github.com/alhafoudh/edupage-cli.git", branch: "main"

  depends_on "ruby"

  deny_network_access!

  def fetch
    ENV["BUNDLE_PATH"] = ".bundle"
    ENV["BUNDLE_WITHOUT"] = "development:test"

    # Use nokogiri's precompiled platform gem instead of compiling libxml2 from source.
    system "bundle", "config", "set", "--local", "force_ruby_platform", "false"
    system "bundle", "cache", "--no-install"
  end

  def install
    ENV["GEM_HOME"] = libexec
    ENV["BUNDLE_WITHOUT"] = "development:test"

    system "bundle", "install", "--local"
    system "gem", "build", "edupage-cli.gemspec"
    system "gem", "install", "--ignore-dependencies", "edupage-cli-#{version}.gem"

    bin.install libexec/"bin/edupage"
    # EDUPAGE_EXECUTABLE is what `edupage mcp-config` registers with MCP clients; the opt
    # path survives upgrades, the Cellar path the wrapper execs does not.
    bin.env_script_all_files libexec/"bin",
      GEM_HOME:           ENV["GEM_HOME"],
      EDUPAGE_EXECUTABLE: opt_bin/"edupage"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/edupage version").strip
    assert_match "mcpServers", shell_output("#{bin}/edupage mcp-config")
  end
end
