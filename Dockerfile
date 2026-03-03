# Use busybox instead of scratch so we have a shell to run commands
FROM busybox

# Keep your label! It links the image to your GitHub repo UI
LABEL org.opencontainers.image.source="https://github.com/kmzet/my-package-project"

# Copy your file as before
COPY myfile.txt /myfile.txt

# This command keeps the container running so the Pod stays "Green"
CMD ["sh", "-c", "while true; do sleep 30; done"]
