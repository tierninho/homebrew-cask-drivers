cask 'asix-ax88179' do
  version '2.9.0_20171130'
  sha256 'f625948935cdb80f3bdc6fbe56a99a77525bd62178104b4c8508d27cb5b8b8ef'

  module Utils
    def self.basename(version)
      "AX88179_178A_Macintosh_Driver_Installer_v#{version}"
    end
  end

  url "http://www.asix.com.tw/FrootAttach/driver/#{Utils.basename(version)}.zip"
  name 'AX88179'
  homepage 'http://www.asix.com.tw/download.php?sub=driverdetail&PItemID=131'

  pkg "AX88179_178A_v#{version.sub(%r{_.*}, '')}.pkg"

  # HACK: DMG needs to be extracted manually because it is using an MBR partition table.
  preflight do
    begin
      dmg_mount = `/usr/bin/hdiutil mount -readonly -noidme -nobrowse -mountrandom /tmp '#{staged_path.join(Utils.basename(version), 'AX88179_178A.dmg')}' | /usr/bin/cut -f3 -- - | /usr/bin/grep -- '.' -`.chop
      FileUtils.cp(Dir.glob("#{dmg_mount}/AX*"), staged_path)
    ensure
      system_command '/usr/bin/hdiutil',
                     args:         ['eject', dmg_mount],
                     print_stdout: false,
                     print_stderr: false
    end
  end

  postflight do
    system_command '/sbin/kextload',
                   args: ['-b', 'com.asix.driver.ax88179-178a'],
                   sudo: true
  end

  uninstall early_script: {
                            executable: "#{staged_path}/AX88179_178A_Uninstall_v150.command",
                          },
            kext:         'com.asix.driver.ax88179-178a',
            pkgutil:      'com.asix.pkg.ax88179-178a*'
end
