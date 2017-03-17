FROM ibmcom/swift-ubuntu
ADD . /Datalazy
WORKDIR /Datalazy
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/release/Datalazy"]
