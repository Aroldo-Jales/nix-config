{ pkgs, vars, ... }:

let
  keyName = "id_ed25519_github";

  ghkey = pkgs.writeShellScriptBin "ghkey" ''
    set -euo pipefail
    EMAIL="${vars.email}"

    KEY_PATH="$HOME/.ssh/${keyName}"
    PUB_PATH="$KEY_PATH.pub"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Agent está "disponível" se o SSH_AUTH_SOCK está setado e o ssh-add consegue falar com ele,
    # mesmo que não tenha identidades carregadas.
    have_agent() {
      [ -n "''${SSH_AUTH_SOCK:-}" ] && ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1 || true
      [ -n "''${SSH_AUTH_SOCK:-}" ]
    }

    add_key_to_agent() {
      if have_agent; then
        ${pkgs.openssh}/bin/ssh-add "$KEY_PATH" || true
      else
        echo "ssh-agent não detectado (SSH_AUTH_SOCK vazio). Rode: eval \"\$(ssh-agent -s)\""
      fi
    }

    if [ -f "$KEY_PATH" ] && [ -f "$PUB_PATH" ]; then
      echo "Key already exists: $KEY_PATH"
      add_key_to_agent
      echo
      echo "Public key (add in GitHub):"
      cat "$PUB_PATH"
      exit 0
    fi

    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""

    chmod 600 "$KEY_PATH"
    chmod 644 "$PUB_PATH"

    add_key_to_agent

    echo "Created key: $KEY_PATH"
    echo
    cat "$PUB_PATH"
  '';

  ghkeyRotate = pkgs.writeShellScriptBin "ghkey-rotate" ''
    set -euo pipefail
    EMAIL="${vars.email}"

    KEY_PATH="$HOME/.ssh/${keyName}"
    PUB_PATH="$KEY_PATH.pub"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    have_agent() {
      [ -n "''${SSH_AUTH_SOCK:-}" ] && ${pkgs.openssh}/bin/ssh-add -l >/dev/null 2>&1 || true
      [ -n "''${SSH_AUTH_SOCK:-}" ]
    }

    del_key_from_agent() {
      if have_agent && [ -f "$KEY_PATH" ]; then
        ${pkgs.openssh}/bin/ssh-add -d "$KEY_PATH" || true
      fi
    }

    add_key_to_agent() {
      if have_agent; then
        ${pkgs.openssh}/bin/ssh-add "$KEY_PATH" || true
      else
        echo "ssh-agent não detectado (SSH_AUTH_SOCK vazio). Rode: eval \"\$(ssh-agent -s)\""
      fi
    }

    del_key_from_agent
    rm -f "$KEY_PATH" "$PUB_PATH"

    ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""

    chmod 600 "$KEY_PATH"
    chmod 644 "$PUB_PATH"

    add_key_to_agent

    echo "Rotated key: $KEY_PATH"
    echo
    cat "$PUB_PATH"
  '';
in
{
  home.file.".ssh/config".text = ''
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/${keyName}
      IdentitiesOnly yes
  '';

  home.packages = [
    ghkey
    ghkeyRotate
  ];
}