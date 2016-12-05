# Importing synckit frameworks into your own project

Here is some more detailed guidance on how to go about importing frameworks from SyncKit into your own project.


## 1. Build the frameworks

### EITHER: Use XCode to build

To build using XCode 7 or higher, simply open the workspace in Xcode, select the ```SyncKit``` scheme and build the workspace `synckit.xcworkspace`.

#### OR: Use command-line tools to build

To use the XCode command-line tool to build all the dynamic libraries: In the terminal, enter the following command whilst ensuring that you have replaced the code signing identity and keychain with your own:

    $ xcodebuild \
        -workspace synckit.xcworkspace \
        -scheme SyncKit \
        -sdk "iphoneos" \
        -configuration Release \
        CODE_SIGN_IDENTITY="iPhone Developer: John Smith(4176XXXX9)" \
        OTHER_CODE_SIGN_FLAGS="--keychain /Users/jsmith/Library/Keychains/login.keychain"

After a successful build, the dynamic libraries will be in the workspace's folder in  `DerivedData/synckit/Build/Products/Release-iphoneos/`. The ios frameworks are universal binaries; they are fit for iPhone and iPad architectures, as well as the iOS simulator.

## 2. Import frameworks into the project

In your own project, you need to import the iOS frameworks.

You will find them in their build location in the workspace's folder in `DerivedData/synckit/Build/Products/Release-iphoneos/`.

To import them, select your project's main target and go to the project's settings:

![XCode settings](img/xcode_settings_1.png)

Next, in the General tab, go to the Embedded Binaries and click on the [+] button to add the frameworks. In the dialog that follows, click on the *'Add Other...'* button:

![XCode settings](img/xcode_settings_2.png)

Now add the frameworks you need. Obtain them from this folder in the workspace folder: `DerivedData/synckit/Build/Products/Release-iphoneos/`

**Make sure that the 'Copy Items if needed' option is selected.** Once the iOS frameworks have been added, they will be shown in your project settings and copied to your project:

![XCode settings](img/xcode_settings_3.png)

Your project can now utilise these libraries.
