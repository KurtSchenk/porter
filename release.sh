# Create tags for release
delete_tag() {
  tag=$1
  git tag -d $1
  git push --delete origin $1
}

set_tag() {
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
    mage -v build

    # Publish native binaries
    # Not needed, they will be in ./bin folder

    # Cross-Compile
    # Leave out for now.
    mage -v XBuildAll

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
    
    gh auth login
    export PORTER_RELEASE_REPOSITORY=github.com/kurtschenk/porter # github.com/KurtSchenk/porter
    mage -v PublishPorter
    
    # Publish Mixins
    export PORTER_PACKAGES_REMOTE=https://github.com/KurtSchenk/packages.git
    mage -v PublishMixins
    
    # Publish Docker Images
    ## Download Cross-Compiled Porter Binaries
    ## Setup Binaries
    #  go run mage.go ConfigureAgent UseXBuildBinaries
    mage UseXBuildBinaries

    # Login to Container Registry
    # Not needed
    # docker login
    # TODO: Do this on shell that executes scripts
    # export GITHUB_TOKEN=ghp_i8K...# 
    echo $GITHUB_TOKEN | docker login ghcr.io -u KurtSchenk --password-stdin
    export PORTER_REGISTRY=ghcr.io/kurtschenk # docker.io/pisees/getporter
    mage PublishImages PublishServerMultiArchImages

}

run_porter_container()
{

    cmd='
mixins list
mixins install exec --version v1.1.1
'
     # porter image is not quite working
    # docker run -it ghcr.io/kurtschenk/porter:v1.1.4 version
    # docker run --rm -v ./.my-porter:/app/.porter ghcr.io/kurtschenk/porter:v1.1.4 version

    # Works. Can change entrypoint
    # docker run --rm -it --entrypoint '/app/bin/cat' -v /usr/bin/:/app/bin/ nginx /app/bin/hi.txt
    # docker run --rm -it --entrypoint '/app/.porter/mixins/exec/exec' -v /usr/bin/:/usr/bin/ ghcr.io/kurtschenk/porter-agent:v1.1.1-1 version
    
    # This works
    # docker run --rm -it --entrypoint '/app/bin/cat' -v /usr/bin/:/app/bin/ nginx /app/bin/hi.txt
    # But this does not
docker run --rm -it --entrypoint '/app/bin/cat' -v /usr/bin/:/app/bin/ ghcr.io/kurtschenk/porter-agent:v1.1.1-1 /app/bin/hi.txt

exit
    docker run --rm ghcr.io/kurtschenk/porter-agent:v1.1.1-1 mixins list # mixins are there. So agent is differen

exit
    docker run -it ghcr.io/kurtschenk/porter-agent:v1.1.1-1 mixins list #  could not list the contents of the mixins directory "/home/nonroot/.porter/mixins": open /home/nonroot/.porter/mixins: no such file or directory
    docker run -it ghcr.io/kurtschenk/porter-agent:v1.1.1-1 mixins 
    docker run -it ghcr.io/kurtschenk/porter:v1.1.1-1 mixins install exec --version v1.1.1

}

run_porter_download()
{
    # curl -fsSLo ./porterv1.1.1-1 https://github.com/kurtschenk/porter/releases/download/v1.1.1-1/porter-linux-amd64
    # chmod +x ./porterv1.1.1-1
    ./porterv1.1.1-1 version
    ./porterv1.1.1-1 mixins install exec
    # installed exec mixin v1.1.1 (f8faad1a)
    ./porterv1.1.1-1 mixins list
    # ---------------------------------
    # Name  Version  Author          
    # ---------------------------------
    # exec  v1.1.1   Porter Authors  
    
    # TODO: I cannot install exec v1.1.4 yet. Because not properly configured in https://github.com/kurtschenk/packages/blob/main/mixins/atom.xml
}

tag=v1.1.1-2
delete_tag $tag
set_tag $tag
build
# publish

# run_porter_container
# run_porter_download



