FROM kylef/swiftenv
RUN swiftenv install DEVELOPMENT-SNAPSHOT-2016-08-18-a

WORKDIR /package
VOLUME /package

CMD swift build && swift test
