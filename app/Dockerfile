FROM scratch
COPY porter /porter
COPY bin/ /bin/
# COPY debian_libs/lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
# COPY debian_libs/lib64/ /lib64/
# ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:/lib64
ENTRYPOINT ["/bin/bash"]
