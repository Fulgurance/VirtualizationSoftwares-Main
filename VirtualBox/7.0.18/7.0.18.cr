class Target < ISM::Software
    
    def configure
        super

        configureSource( [  "#{option("Sdl2") ? "--enable-sdl" : "--disable-sdl"}",
                            #For full 64 bits
                            "--disable-vmmraw"],
                            path: buildDirectoryPath)
    end

    def build
        super

        #runKmkCommand(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        exit 1
        #makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

    def showInformations
        super

        showInfo("After the installation, if you wish a user able to use Virtualbox, add it in the vboxusers system group")
    end

end
