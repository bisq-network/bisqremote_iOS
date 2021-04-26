# Bisq iOS App

For a documentation of Bisq Remote (Java, iOS and Android Apps) see the Bisq Remote [specification](https://github.com/joachimneumann/bisqremote/wiki/Specification)

To compile, you need to create your own push_certificate.production.p12 file

## Development Setup

[Carthage](https://github.com/Carthage/Carthage), a simple dependency manager, is required. It can be installed using [Homebrew](https://brew.sh/):
`brew install carthage`

Next, configure your command line tools to use Xcode: 
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

Finally, download and build the exact versions of required dependencies with:
`carthage bootstrap --platform iOS`
