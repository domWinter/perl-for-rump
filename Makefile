UPSTREAM=http://search.cpan.org/CPAN/authors/id/M/ML/MLEHMANN/App-Staticperl-1.44.tar.gz
wget=http://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/7.1/All/wget-1.19.1nb2.tgz
git=http://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/7.1/All/git-2.14.3.tgz
gmake=http://ftp.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/7.1/All/gmake-4.1nb3.tgz

all: install_packages build_staticperl build_rumprun build_perl bake_binary 

install_packages:
	pkg_add $(wget)
	pkg_add $(git)
	pkg_add $(gmake)

build_staticperl:
	mkdir -p build
	wget -O build/staticperl.tar.gz $(UPSTREAM)
	(cd build && tar -xzvf staticperl.tar.gz)
	(cd build && mv App-Staticperl-1.44/* ./ && rm -r App-Staticperl-1.44)
	patch ./build/bin/staticperl < ./patches/staticperl.patch  
	(cd build && ./bin/staticperl configure)
	patch ~/.staticperl/src/perl-5.26.1/Makefile < ./patches/makefile.patch	
	(cd ~/.staticperl/src/perl-5.26.1/ && make -f Makefile)

build_rumprun:
	export GIT_SSL_NO_VERIFY=true
	(cd build && git clone http://repo.rumpkernel.org/rumprun)
	(cd build/rumprun && git submodule update --init)
	(cd build/rumprun && CC=cc ./build-rr.sh hw)

build_perl:
	(cd ~/.staticperl/src/perl-5.26.1/ && ~/perl-for-rump/build/rumprun/rumprun/bin/x86_64-rumprun-netbsd-gcc -o perl -static -static-libgcc  perlmain.o  lib/auto/B/B.a lib/auto/Compress/Raw/Bzip2/Bzip2.a lib/auto/Compress/Raw/Zlib/Zlib.a lib/auto/Cwd/Cwd.a lib/auto/DB_File/DB_File.a lib/auto/Data/Dumper/Dumper.a lib/auto/Devel/PPPort/PPPort.a lib/auto/Devel/Peek/Peek.a lib/auto/Digest/MD5/MD5.a lib/auto/Digest/SHA/SHA.a lib/auto/Encode/Encode.a lib/auto/Fcntl/Fcntl.a lib/auto/File/DosGlob/DosGlob.a lib/auto/File/Glob/Glob.a lib/auto/Filter/Util/Call/Call.a lib/auto/Hash/Util/Util.a lib/auto/Hash/Util/FieldHash/FieldHash.a lib/auto/I18N/Langinfo/Langinfo.a lib/auto/IO/IO.a lib/auto/List/Util/Util.a lib/auto/MIME/Base64/Base64.a lib/auto/Math/BigInt/FastCalc/FastCalc.a lib/auto/NDBM_File/NDBM_File.a lib/auto/Opcode/Opcode.a lib/auto/POSIX/POSIX.a lib/auto/PerlIO/encoding/encoding.a lib/auto/PerlIO/mmap/mmap.a lib/auto/PerlIO/scalar/scalar.a lib/auto/PerlIO/via/via.a lib/auto/SDBM_File/SDBM_File.a lib/auto/Socket/Socket.a lib/auto/Storable/Storable.a lib/auto/Sys/Hostname/Hostname.a lib/auto/Sys/Syslog/Syslog.a lib/auto/Tie/Hash/NamedCapture/NamedCapture.a lib/auto/Time/HiRes/HiRes.a lib/auto/Time/Piece/Piece.a lib/auto/Unicode/Collate/Collate.a lib/auto/Unicode/Normalize/Normalize.a lib/auto/arybase/arybase.a lib/auto/attributes/attributes.a lib/auto/mro/mro.a lib/auto/re/re.a lib/auto/threads/threads.a lib/auto/threads/shared/shared.a lib/auto/Encode/Byte/Byte.a lib/auto/Encode/CN/CN.a lib/auto/Encode/EBCDIC/EBCDIC.a lib/auto/Encode/JP/JP.a lib/auto/Encode/KR/KR.a lib/auto/Encode/Symbol/Symbol.a lib/auto/Encode/TW/TW.a lib/auto/Encode/Unicode/Unicode.a libperl.a -lm -lcrypt)
	cp ~/.staticperl/src/perl-5.26.1/perl ./

bake_binary:
	~/perl-for-rump/build/rumprun/rumprun/bin/rumprun-bake hw_generic perl.bin perl

clean:
	rm -rf build
	rm -rf ~/.staticperl
	rm -rf perl*
