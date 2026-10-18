FROM barichello/godot-ci:4.7.2@sha256:cdcca31e9194fd59a68a63f4b1b9c3981716819c520cd6f7966c5d72ca7246bd
RUN apt-get update && apt-get install -y --no-install-recommends libfontconfig1 && rm -rf /var/lib/apt/lists/* && useradd --uid 10001 --create-home authority
WORKDIR /app/game
COPY --chown=authority:authority game/ ./
RUN chown authority:authority /app/game
USER authority
ENV HOME=/home/authority
RUN godot --headless --path /app/game --import --quit > /tmp/authority-import.log 2>&1; \
    import_status=$?; cat /tmp/authority-import.log; \
    test "$import_status" -eq 0 && ! grep -E '^(SCRIPT ERROR|ERROR):' /tmp/authority-import.log
EXPOSE 9080
ENTRYPOINT ["godot", "--headless", "--path", "/app/game", "res://v2/network/authority.tscn"]
