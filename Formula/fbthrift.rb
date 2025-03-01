class Fbthrift < Formula
  desc "Facebook's branch of Apache Thrift, including a new C++ server"
  homepage "https://github.com/facebook/fbthrift"
  url "https://github.com/facebook/fbthrift/archive/v2022.10.24.00.tar.gz"
  sha256 "d390c4951c14f5f09fe05016dca005079a32589a924bc24550eac2c8b1b63aa9"
  license "Apache-2.0"
  head "https://github.com/facebook/fbthrift.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "6c6d3cf710a44956af801ae14bb237996eb9e7addddbfaf2755242243b60dc32"
    sha256 cellar: :any,                 arm64_monterey: "545984791dc0ca9ec1bfbbfebd043c96cd167de726a66b350e2fb170b3762e15"
    sha256 cellar: :any,                 arm64_big_sur:  "2faa7483b341ecbca7d39117af7ccfe5e494dbe1de2e8df06438151b4fd21639"
    sha256 cellar: :any,                 monterey:       "5d95749d5577bf4e949e1c840e83f0537e9233460e058a77b8019352de7e2941"
    sha256 cellar: :any,                 big_sur:        "59b8e8ab19fb6bb468777a25a778948c17530c79f2769319c0d3ee5cbdc2357a"
    sha256 cellar: :any,                 catalina:       "0fe10fa3837b9d08e33dc92168336b0801332c9a1125b374d9ab29b33d20f42d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "43b12515fa2d91a12eb9cf45c48012c5b3f2115883fc0078e606d2394484285f"
  end

  depends_on "bison" => :build # Needs Bison 3.1+
  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "fizz"
  depends_on "fmt"
  depends_on "folly"
  depends_on "gflags"
  depends_on "glog"
  depends_on "openssl@1.1"
  depends_on "wangle"
  depends_on "zstd"

  uses_from_macos "flex" => :build
  uses_from_macos "zlib"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1100
  end

  fails_with :clang do
    build 1100
    cause <<~EOS
      error: 'asm goto' constructs are not supported yet
    EOS
  end

  fails_with gcc: "5" # C++ 17

  def install
    ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)

    # The static libraries are a bit annoying to build. If modifying this formula
    # to include them, make sure `bin/thrift1` links with the dynamic libraries
    # instead of the static ones (e.g. `libcompiler_base`, `libcompiler_lib`, etc.)
    shared_args = ["-DBUILD_SHARED_LIBS=ON", "-DCMAKE_INSTALL_RPATH=#{rpath}"]
    shared_args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-undefined,dynamic_lookup" if OS.mac?

    system "cmake", "-S", ".", "-B", "build/shared", *std_cmake_args, *shared_args
    system "cmake", "--build", "build/shared"
    system "cmake", "--install", "build/shared"

    elisp.install "thrift/contrib/thrift.el"
    (share/"vim/vimfiles/syntax").install "thrift/contrib/thrift.vim"
  end

  test do
    (testpath/"example.thrift").write <<~EOS
      namespace cpp tamvm

      service ExampleService {
        i32 get_number(1:i32 number);
      }
    EOS

    system bin/"thrift1", "--gen", "mstch_cpp2", "example.thrift"
    assert_predicate testpath/"gen-cpp2", :exist?
    assert_predicate testpath/"gen-cpp2", :directory?
  end
end
