class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.0.420",
      revision: "977028ba41a19da88e55928a2454a23f62dc177f"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ef6de4afb3c74125f7af4875b21956d96fdba7cea6a4aef26a9e9051c471b53a"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "ef6de4afb3c74125f7af4875b21956d96fdba7cea6a4aef26a9e9051c471b53a"
    sha256 cellar: :any_skip_relocation, monterey:       "8c6273661cf9a2e4ba46269ea07db6dd338e577f489355690c1f91290f99ece3"
    sha256 cellar: :any_skip_relocation, big_sur:        "8c6273661cf9a2e4ba46269ea07db6dd338e577f489355690c1f91290f99ece3"
    sha256 cellar: :any_skip_relocation, catalina:       "8c6273661cf9a2e4ba46269ea07db6dd338e577f489355690c1f91290f99ece3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "58a150e6ecf956abf7721776dcab48dfe7bac91ce1bfdab53d3a69a94c4dfd50"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("flyctl status 2>&1", 1)
    assert_match "Error No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
