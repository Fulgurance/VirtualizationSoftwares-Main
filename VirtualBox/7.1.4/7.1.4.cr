class Target < ISM::Software
    
    def configure
        super

        configureSource(arguments:  "#{option("Sdl2") ? "" : "--disable-sdl"}   \
                                    #{option("Qt") ? "" : "--disable-qt"}       \
                                    --disable-java                              \
                                    --disable-docs                              \
                                    --disable-vmmraw",
                        path:       buildDirectoryPath)
    end

    def build
        super

        localConfigKmkData = <<-CODE
        VBOX_PATH_APP_PRIVATE_ARCH := /usr/lib64/virtualbox
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

        makeSource( path:                   "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/src",
                    environmentFilePath:    "#{mainWorkDirectoryPath}/env.sh")
    end
    
    def prepareInstallation
        super

        virtualboxLibFiles =    [   "components",
                                    "DbgPlugInDiggers.so",
                                    "ExtensionPacks",
                                    "sdk",
                                    "UICommon.so",
                                    "VBox.sh",
                                    "VBoxAuth.so",
                                    "VBoxAuthSimple.so",
                                    "VBoxAutostart",
                                    "VBoxBalloonCtrl",
                                    "VBoxBugReport",
                                    "VBoxCpuReport",
                                    "VBoxDD.so",
                                    "VBoxDD2.so",
                                    "VBoxDDR0.r0",
                                    "VBoxDDU.so",
                                    "VBoxDbg.so",
                                    "VBoxDragAndDropSvc.so",
                                    "VBoxDxVk.so",
                                    "VBoxEFI32.fd",
                                    "VBoxEFI64.fd",
                                    "VBoxExtPackHelperApp",
                                    "VBoxGuestControlSvc.so",
                                    "VBoxGuestPropSvc.so",
                                    "VBoxHeadless",
                                    "VBoxHeadless.so",
                                    "VBoxHostChannel.so",
                                    "VBoxKeyboard.so",
                                    "VBoxManage",
                                    "VBoxNetAdpCtl",
                                    "VBoxNetDHCP",
                                    "VBoxNetDHCP.so",
                                    "VBoxNetNAT",
                                    "VBoxNetNAT.so",
                                    "VBoxRT.so",
                                    "VBoxSVC",
                                    "VBoxSVGA3D.so",
                                    "VBoxSharedClipboard.so",
                                    "VBoxSharedFolders.so",
                                    "VBoxVMM.so",
                                    "VBoxVMMPreload",
                                    "VBoxVMMPreload.so",
                                    "VBoxVolInfo",
                                    "VBoxXPCOM.so",
                                    "VBoxXPCOMC.so",
                                    "VMMR0.r0",
                                    "VirtualBox",
                                    "VirtualBoxVM",
                                    "VirtualBoxVM.so",
                                    "vboximg-mount",
                                    "vboxshell.py",
                                    "vboxdrv.sh",
                                    "vboxweb-service.sh"]

        virtualboxSymlinks = [  "VBoxAutostart",
                                "VBoxBalloonCtrl",
                                "VBoxBugReport",
                                "VBoxHeadless",
                                "VBoxManage",
                                "VBoxVRDP",
                                "VirtualBox",
                                "VirtualBoxVM",
                                "vboxautostart",
                                "vboxballoonctrl",
                                "vboxbugreport",
                                "vboxheadless",
                                "vboxmanage",
                                "vboxsdl",
                                "vboxwebsrv",
                                "virtualbox",
                                "virtualboxvm"]
        if option("Sdl2")
            virtualboxSymlinks.push("VBoxSDL")
        end

        moduleDirectory = "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/lib/modules/#{mainKernelVersion}"

        makeDirectory(moduleDirectory)
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/bin")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/udev/rules.d/")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/virtualbox")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/icons")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/pixmaps")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/virtualbox")
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/applications")

        #Generate temporary symlink for kernel module installation

        makeLink(   target: "/lib/modules/#{mainKernelVersion}/modules.order",
                    path:   "#{moduleDirectory}/modules.order",
                    type:   :symbolicLinkByOverwrite)

        makeLink(   target: "/lib/modules/#{mainKernelVersion}/modules.builtin",
                    path:   "#{moduleDirectory}/modules.builtin",
                    type:   :symbolicLinkByOverwrite)

        makeLink(   target: "/lib/modules/#{mainKernelVersion}/modules.builtin.modinfo",
                    path:   "#{moduleDirectory}/modules.builtin.modinfo",
                    type:   :symbolicLinkByOverwrite)

        #Prepare kernel module installation

        makeSource( arguments:              "install",
                    path:                   "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/src",
                    environment:            {"INSTALL_MOD_PATH" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"},
                    environmentFilePath:    "#{mainWorkDirectoryPath}/env.sh")

        #Prepare file installation

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/VBoxCreateUSBNode.sh",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/udev/VBoxCreateUSBNode.sh")

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/icons",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/icons/hicolor")

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/VBox.png",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/pixmaps/virtualbox.png")

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/nls",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/virtualbox/nls")

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/UnattendedTemplates",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/virtualbox/UnattendedTemplates")

        moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/virtualbox.desktop",
                    newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/share/applications/virtualbox.desktop")


        #Prepare library installation

        virtualboxLibFiles.each do |filename|

            moveFile(   path:       "#{mainWorkDirectoryPath}/out/linux.amd64/release/bin/#{filename}",
                        newPath:    "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/virtualbox/#{filename}")

        end

        makeLink(   target: "VBoxAuth.so",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/virtualbox/VRDPAuth.so",
                    type:   :symbolicLinkByOverwrite)

        #Prepare binary installation

        virtualboxSymlinks.each do |filename|

            makeLink(   target: "/usr/lib/virtualbox/#{filename}",
                        path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/bin/#{filename}",
                        type:   :symbolicLinkByOverwrite)

        end

        makeLink(   target: "/usr/lib/virtualbox/VBoxVolInfo",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/bin/VBoxVolInfo",
                    type:   :symbolicLinkByOverwrite)

        makeLink(   target: "/usr/lib/virtualbox/vbox-img",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/bin/vbox-img",
                    type:   :symbolicLinkByOverwrite)

        makeLink(   target: "/usr/lib/virtualbox/vboximg-mount",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/bin/vboximg-mount",
                    type:   :symbolicLinkByOverwrite)

        #Prepare udev rules installation

        udevData = <<-CODE
        SUBSYSTEM=="usb_device", ACTION!="remove", RUN="/usr/lib/udev/VBoxCreateUSBNode.sh $major $minor $attr{bDeviceClass}"
        SUBSYSTEM=="usb", ACTION!="remove", ENV{DEVTYPE}=="usb_device", RUN="/usr/lib/udev/VBoxCreateUSBNode.sh $major $minor $attr{bDeviceClass}"
        SUBSYSTEM=="usb_device", ACTION=="remove", RUN="/usr/lib/udev/VBoxCreateUSBNode.sh --remove $major $minor"
        SUBSYSTEM=="usb", ACTION=="remove", ENV{DEVTYPE}=="usb_device", RUN="/usr/lib/udev/VBoxCreateUSBNode.sh --remove $major $minor"
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/usr/lib/udev/rules.d/10-virtualbox.rules",udevData)

        #Delete generated temporary symlink for kernel module installation

        deleteFile("#{moduleDirectory}/modules.order")
        deleteFile("#{moduleDirectory}/modules.builtin")
        deleteFile("#{moduleDirectory}/modules.builtin.modinfo")
    end

    def install
        super

        runDepmodCommand

        runChmodCommand("4755 /usr/lib64/virtualbox/VirtualBoxVM")
    end

    def showInformations
        super

        showInfo("After the installation, if you wish a user able to use Virtualbox, add it in the vboxusers system group")
        showInfo("Please notice as well the module vboxdrv will need to be load")
    end

end
