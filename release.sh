# Create tags for release
tag() {
  git tag v1.1.3 -a -m ""
  git push v1.1.3
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


# Publish
# TODO: Change repo
# github.com/getporter/porter
# Set this outside of script
# run gh auth login before this
gh auth login
export PORTER_RELEASE_REPOSITORY=github.com/KurtSchenk/porter
mage -v PublishPorter
# Tagged Release: true
# Permalink: latest-dev
# Version: v1.1.3
# Commit: 52c05ef4
# Repository: getporter/porter

exit



# Publish Mixins
# releases.PublishMixinFeed("exec")
# DONE # mage -v PublishMixins
# Tagged Release: false

# Publish Docker Images
## Download Cross-Compiled Porter Binaries
## Should be in ./bin
## Setup Binaries
## go run mage.go ConfigureAgent UseXBuildBinaries
# DONE mage UseXBuildBinaries

# Login to Container Registry
docker login
PORTER_REGISTRY=docker.io/pisees/getporter
mage PublishImages PublishServerMultiArchImages


