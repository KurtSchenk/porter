# Create tags for release
tag() {
  tag=$1
  git tag $1 -a -m ""
  git push $1
  git push --tags
}

build() {
    # Configure Agent
    # SKIP 
    # // ConfigureAgent sets up an Azure DevOps agent with EnsureMage and ensures that GOPATH/bin is in PATH.
    # go run mage.go ConfigureAgent
    # mage ConfigureAgent

    # Native build
    mage build

    # Publish native binaries
    # Not needed, they will be in ./bin folder

    # Cross-Compile
    # Leave out for now.
    mage XBuildAll

    # Publish Release Binaries
    # Not needed, will be in ./bin folder

    # Vet and Lint
    mage Vet
    mage Lint

    # Unit Test
    # done # mage TestUnit

    # func Test() {
    # 	mg.Deps(TestUnit, TestSmoke, TestIntegration)
    # }

    # Integration test?
    # SKIP
    # Long-running
    # mage TestIntegration

    # Smoke Test
    # mage UseXBuildBinaries
    # SKIP
    # mage -v TestSmoke
}

publish() {
    
    # gh auth login
    # export PORTER_RELEASE_REPOSITORY=github.com/KurtSchenk/porter # github.com/KurtSchenk/porter
    #DONE # mage -v PublishPorter
    
    # Publish Mixins
    # export PORTER_PACKAGES_REMOTE=https://github.com/KurtSchenk/packages.git
    # DONE # mage -v PublishMixins
    
    # Publish Docker Images
    ## Download Cross-Compiled Porter Binaries
    ## Setup Binaries
    ## go run mage.go ConfigureAgent UseXBuildBinaries
    # DONE # mage UseXBuildBinaries

    # Login to Container Registry
    # docker login
    # TODO: Do this on shell that executes scripts
    # export GITHUB_TOKEN=ghp_i8K...# 
    echo $GITHUB_TOKEN | docker login ghcr.io -u KurtSchenk --password-stdin
    export PORTER_REGISTRY=ghcr.io/kurtschenk # docker.io/pisees/getporter
    mage PublishImages PublishServerMultiArchImages

}

# tag v1.1.4
# build
publish




