FROM mcr.microsoft.com/dotnet/sdk:9.0-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git curl ca-certificates sudo openssh-client \
 && rm -rf /var/lib/apt/lists/*

COPY containers/fix-ssh-runtime.sh /etc/profile.d/fix-ssh-runtime.sh
RUN chmod 755 /etc/profile.d/fix-ssh-runtime.sh

COPY containers/ssh-wrapper.sh /usr/local/bin/ssh
RUN chmod 755 /usr/local/bin/ssh

USER 1000:100
CMD ["bash"]
