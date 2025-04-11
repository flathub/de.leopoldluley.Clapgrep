manifest := "de.leopoldluley.Clapgrep.json"
builddir := "builddir"
repo := "repo"
remote := "clapgrep-release"

# List available commands
@help:
  just --list

# Configure flathub remote and install flatpak-builder
setup:
  flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install --user -y flathub org.flatpak.Builder

# Update manifest and cargo-sources to the latest GitHub release
update:
  ./update.sh

# Build the app like Flathub will do
build:
  flatpak run org.flatpak.Builder --force-clean --sandbox --user --install-deps-from=flathub --ccache --mirror-screenshots-url=https://dl.flathub.org/media/ --repo={{repo}} {{builddir}} {{manifest}}

# Run the Flathub linters
lint: build
  flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest {{manifest}}
  flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo {{repo}}

# Install the release build
install:
  flatpak remote-add --user --if-not-exists --no-gpg-verify {{remote}} file://$(pwd)/{{repo}}
  flatpak install --user -y {{remote}} de.leopoldluley.Clapgrep

# Uninstall the release build
uninstall:
  flatpak uninstall --user -y de.leopoldluley.Clapgrep//master
  flatpak remote-delete --user clapgrep-release

# Remove build files
clean:
  rm -rf .flatpak-builder
  rm -rf {{builddir}}
  rm -rf {{repo}}
