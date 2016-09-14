FROM kylef/swiftenv
RUN swiftenv install 3.0-RELEASE

WORKDIR /package
VOLUME /package

CMD swift build && swift test
