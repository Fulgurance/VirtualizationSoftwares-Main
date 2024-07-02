class Target < ISM::Software
    
    def configure
        super

        configureSource(arguments:  "#{option("Sdl2") ? "" : "--disable-sdl"}   \
                                    --disable-java                                                  \
                                    --disable-docs                                                  \
                                    --disable-vmmraw",#For full 64 bits
                        path:       buildDirectoryPath)
    end

    def build
        super

        localConfigKmkData = <<-CODE
        VBOX_PATH_APP_PRIVATE_ARCH := /usr/lib/virtualbox
        VBOX_PATH_SHARED_LIBS := $(VBOX_PATH_APP_PRIVATE_ARCH)
        VBOX_WITH_ORIGIN :=
        VBOX_WITH_RUNPATH := $(VBOX_PATH_APP_PRIVATE_ARCH)
        VBOX_PATH_APP_PRIVATE := /usr/share/virtualbox
        VBOX_PATH_APP_DOCS := /usr/share/doc/virtualbox
        VBOX_WITH_TESTCASES :=
        VBOX_WITH_TESTSUITE :=
        CODE
        fileWriteData("#{mainWorkDirectoryPath}/LocalConfig.kmk",localConfigKmkData)

        runFile(file:                   "kBuild/bin/linux.amd64/kmk all",
                path:                   mainWorkDirectoryPath,
                environmentFilePath:    "#{mainWorkDirectoryPath}/env.sh")

        #Then we need to build the modules !
    end
    
    def prepareInstallation
        super

        exit 1
    end

    def showInformations
        super

        showInfo("After the installation, if you wish a user able to use Virtualbox, add it in the vboxusers system group")
    end

end
