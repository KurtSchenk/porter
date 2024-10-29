rm -f hello

# Define the local Go path
# vscode@85e9960f9cbe:/workspace/kurtsc/acr_build/src$ ls $HOME/go/pkg/mod
# cache  cloud.google.com  filippo.io  github.com  go.uber.org  golang.org  google.golang.org  gopkg.in  gotest.tools  k8s.io  sigs.k8s.io
LOCAL_GO_PATH="$HOME/go"

# Ensure the local Go path exists
mkdir -p "$LOCAL_GO_PATH"

# chown -R vscode:vscode "$LOCAL_GO_PATH"

# urt@DESKTOP-ML7A32M:~/src/GitHub/KurtSchenk/porter$ sudo su
# root@DESKTOP-ML7A32M:/home/kurt/src/GitHub/KurtSchenk/porter# chown -R kurt:kurt ~/src
# chown: cannot access '/root/src': No such file or directory
# root@DESKTOP-ML7A32M:/home/kurt/src/GitHub/KurtSchenk/porter# chown -R kurt:kurt /home/kurt/src

# chown -R kurt:kurt /home/kurt/

install_go() {
    version=1.22.0 #1.23.1

    # Remove any old versions of Go
    sudo rm -rf /usr/local/go*

    # Download the latest version of Go
    wget https://go.dev/dl/go$version.linux-amd64.tar.gz

    # Extract the downloaded file
    sudo tar -xvf go$version.linux-amd64.tar.gz
    sudo mv go /usr/local
    sudo rm go$version.linux-amd64.tar.gz

    # Update environment variables
    echo "export GOROOT=/usr/local/go" >> ~/.bashrc
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.bashrc

    # Refresh terminal
    source ~/.bashrc
}

# 20+ seconds to build
build_docker() {
    cmd='
go get github.com/KurtSchenk/cnab-go@v0.25.4
go mod tidy
go build -o hello
'
    docker run --rm -v "$PWD":/usr/src/hello -v "$LOCAL_GO_PATH":/go -w /usr/src/hello golang:1.22 sh -c "$cmd"
}

# 3 seconds to build
build_locally() {
    # Run the Go commands locally
    go get github.com/KurtSchenk/cnab-go@v0.25.4
    go mod tidy
    go build -o hello
}

go_run() { 
    cmd=$1
    docker run --rm -v "$PWD":/usr/src -v "$LOCAL_GO_PATH":/go -w /usr/src golang:1.22 sh -c "$cmd"
}

# build_docker

# install_go # Kill terminal can come back
# go version

# Kill terminal and start a new one to see the binary
cmd='
go run mage.go EnsureMage
'
go_run "$cmd"
