FROM barichello/godot-ci:4.3 as builder

WORKDIR /game

COPY . .

RUN mkdir -p ./build/web
RUN godot --headless --verbose --export-release "Web" ./build/web/index.html

FROM nginx:alpine as runner

COPY --from=builder /game/build/web /usr/share/nginx/html

EXPOSE 80
