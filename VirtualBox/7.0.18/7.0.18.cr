class Target < ISM::Software
    
    def configure
        super

        configureSource(arguments:  "#{option("Sdl2") ? "--enable-sdl" : "--disable-sdl"}   \
                                    --disable-docs                                          \
                                    --disable-vmmraw",#For full 64 bits
                        path:       buildDirectoryPath)
    end

    def build
        super

        runFile(file:   "kBuild/bin/linux.amd64/kmk",
                path:   mainWorkDirectoryPath)
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
