FROM ibmcom/kitura-ubuntu
ADD . /Datalazy
WORKDIR /Datalazy
RUN swift build
EXPOSE 8080
ENTRYPOINT [".build/debug/Datalazy"]
