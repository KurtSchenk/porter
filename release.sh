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
    export PORTER_MIRROR=https://github.com/kurtschenk/porter/releases/download
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
    # Define a function to call the porter binary
    porter() {
        ./porter "$@"
    }
    version=v1.1.1-2
    curl -fsSLo ./porter https://github.com/kurtschenk/porter/releases/download/$version/porter-linux-amd64
    chmod +x ./porter
    porter version
    porter install -r test -d test # will have output from cnab-go "My lookup: Aha!"
    porter mixins list # does not havve v1.1.1-2 in this case because not installed locally. However, the docker image above has the correct exec mixin in it.
    porter mixin install exec --version $version --url https://github.com/kurtschenk/porter/releases/download/ --verbosity debug
    porter mixins list
    # After creating a fork of azure plugin and use url like above for mixin
    version=v1.2.3-1    
    porter plugins install azure --version $version --url https://github.com/kurtschenk/azure-plugins/releases/download/ --verbosity debug
    porter plugins list
}

run_porter_download_cdn() {

    dash_version=$1

    # Hve to be existing released verstion to download scripts
    export VERSION=v1.1.0
    export PORTER_HOME=${PORTER_HOME:-~/.porter}
    export PORTER_VERSION=$VERSION

    curl -L https://cdn.porter.sh/$VERSION/install-linux.sh -o porter-install-linux.sh
    chmod +x porter-install-linux.sh


    if [ -n "$dash_version" ]; then
        # now updated to the version you want
        export VERSION=v1.1.1$dash_version
        export PORTER_VERSION=$VERSION
        export PORTER_MIRROR=https://github.com/kurtschenk/porter/releases/download
    fi

     ./porter-install-linux.sh
    
    # if there is a dash version then need to install exec mixin from fork
    if [ -n "$dash_version" ]; then
       ~/.porter/porter mixin install exec --version $VERSION --url $PORTER_MIRROR  
    fi  

}

# tag=v1.1.1-2
# delete_tag $tag
# set_tag $tag
# build
# publish

# run_porter_container
# run_porter_download
dash_version="-2"
run_porter_download_cdn $dash_version



