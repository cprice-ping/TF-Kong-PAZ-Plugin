FROM kong:latest

USER root

# Install the plugin and its dependencies
RUN luarocks install kong-plugin-ping-auth

USER kong
