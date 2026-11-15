# Wadiup hostile-build probe: tries, during the build and at run time, to reach what a tenant must never reach.
# Every line should say BLOCKED except "internet". Nothing here changes or reads anyone's data.
FROM alpine:3.20
RUN apk add --no-cache curl netcat-openbsd
COPY probe.sh /probe.sh
RUN sh /probe.sh build
EXPOSE 8080
CMD ["sh", "-c", "sh /probe.sh run; while true; do printf 'HTTP/1.1 200 OK\\r\\nContent-Type: text/plain\\r\\n\\r\\n%s' \"$(cat /tmp/probe.txt)\" | nc -l 8080 >/dev/null; done"]
